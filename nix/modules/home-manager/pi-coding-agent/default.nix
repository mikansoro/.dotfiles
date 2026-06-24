# Pi (the coding agent) -- declarative home-manager module.
#
# Design notes
# ------------
#   * Settings files (~/.pi/agent/{settings,searxng,llama-swap,...}.json) are
#     mutable regular files, not /nix/store symlinks. A jq-based activation
#     script merges declarative defaults into them on every `home-manager
#     switch`: keys declared here are authoritative; keys pi writes that we
#     don't manage are preserved. That lets pi own `lastChangelogVersion`,
#     remember the user's `/model` selection (if `defaultModel` is left
#     undeclared), and persist per-extension state, while still pinning the
#     things we care about.
#
#   * Extensions are passed as a list of derivations or store paths. Each
#     path is added to settings.json's `packages` array as a local-path
#     package source. Pi treats local paths as already-installed and never
#     runs `npm install` at activation time -- fully offline, fully pinned.
#
#     Build extension derivations however you like:
#       - `runCommandLocal` to vendor a directory (pure-source extensions).
#       - `buildNpmPackage` for extensions with real npm runtime deps.
#       - flake inputs that expose `packages.<system>.default`, for repos
#         you keep separately (recommended for your own extensions).
#
#   * `auth.json` is intentionally untouched. It contains credentials and
#     is owned by pi (written via `/login`).
#
#   * Secrets do NOT belong in this module. Anything passed to `settings`
#     or `extraConfigFiles` ends up world-readable in /nix/store. For files
#     that mix secrets and non-secrets (e.g. searxng.json with an apiKey),
#     declare only the non-secret keys here; the merge leaves the rest
#     untouched.

{ config, lib, pkgs, ... }:

let
  cfg = config.mikansoro.pi-coding-agent;

  # Merge a Nix-built JSON value into ~/.pi/agent/<name>. Keys present in
  # `value` win on every switch; keys present in the existing file but
  # absent from `value` are preserved. Object values are merged recursively
  # (jq's `*` operator); arrays are replaced wholesale.
  mkMergedConfig = name: value:
    let
      safeName = lib.replaceStrings [ "." "/" ] [ "-" "-" ] name;
      declFile = pkgs.writeText "pi-${safeName}-decl.json"
        (builtins.toJSON value);
    in
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      target="$HOME/.pi/agent/${name}"
      $DRY_RUN_CMD mkdir -p "$(dirname "$target")"

      # If a previous configuration used home.file (read-only /nix/store
      # symlink), drop it so we can write a real, mutable file.
      if [ -L "$target" ]; then
        $DRY_RUN_CMD rm -f "$target"
      fi

      if [ -f "$target" ]; then
        tmp="$(mktemp)"
        if ${lib.getExe pkgs.jq} -S -s '.[0] * .[1]' \
             "$target" ${declFile} > "$tmp"; then
          $DRY_RUN_CMD mv "$tmp" "$target"
          $DRY_RUN_CMD chmod 644 "$target"
        else
          # Existing file isn't valid JSON. Back it up, install fresh.
          echo "pi-coding-agent: $target is not valid JSON, backing up" >&2
          $DRY_RUN_CMD mv "$target" "$target.bak"
          $DRY_RUN_CMD install -m 644 ${declFile} "$target"
          $DRY_RUN_CMD rm -f "$tmp"
        fi
      else
        $DRY_RUN_CMD install -m 644 ${declFile} "$target"
      fi
    '';

  # `packages` is computed from `extensions`. If the user also supplies
  # `settings.packages`, the two are unioned -- declarative paths first,
  # then anything else they listed.
  computedSettings =
    let
      extensionPackages = map toString cfg.extensions;
      userPackages = cfg.settings.packages or [ ];
    in
    cfg.settings // {
      packages = lib.unique (extensionPackages ++ userPackages);
    };
in
{
  options.mikansoro.pi-coding-agent = {
    enable = lib.mkEnableOption "pi coding agent with vendored extensions";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.unstable.pi-coding-agent;
      defaultText = lib.literalExpression "pkgs.pi-coding-agent";
      description = ''
        The pi-coding-agent package to install. 
      '';
    };

    extensions = lib.mkOption {
      type = with lib.types; listOf (oneOf [ package path str ]);
      default = [ ];
      example = lib.literalExpression ''
        [
          pkgs.piExtensions.llama-swap
          pkgs.piExtensions.searxng
        ]
      '';
      description = ''
        Pi extensions to vendor. Each entry must resolve to a directory
        containing a pi-package layout: a `package.json` with a `pi`
        manifest, or one of the convention directories (`extensions/`,
        `skills/`, `prompts/`, `themes/`).

        Each path is written into `settings.json`'s `packages` array as a
        local-path package source. Because pi treats local paths as
        already-installed, no `npm install` ever runs at activation time.
      '';
    };

    settings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      example = lib.literalExpression ''
        {
          defaultProvider = "anthropic";
          defaultThinkingLevel = "xhigh";
          transport = "auto";
          enabledModels = [
            "anthropic/claude-opus-4-7"
            "llama-swap/qwen3.6-35b-precise"
          ];
        }
      '';
      description = ''
        Declarative content for ~/.pi/agent/settings.json. Keys set here
        are reasserted on every home-manager switch. Keys NOT set here
        are preserved across rebuilds, so pi remains free to write things
        like `lastChangelogVersion` -- and if you omit `defaultModel`,
        the user's `/model` selection sticks.

        The `packages` array is computed from `extensions` and unioned
        with anything passed here.
      '';
    };

    extraConfigFiles = lib.mkOption {
      type = with lib.types; attrsOf attrs;
      default = { };
      example = lib.literalExpression ''
        {
          "searxng.json" = {
            baseUrl = "https://searx.int.mikansystems.com";
            defaultCategories = "general";
            timeoutMs = 15000;
          };
          "llama-swap.json" = {
            baseUrl = "http://ollama.int.mikansystems.com:11395";
          };
        }
      '';
      description = ''
        Additional JSON files to manage under ~/.pi/agent/, keyed by
        filename. Each file uses the same merge semantics as
        settings.json: declared keys win, unmanaged keys are preserved.

        Use this for per-extension config (searxng.json, llama-swap.json,
        ...). Do NOT include secrets -- values end up world-readable in
        /nix/store. For files that mix secrets and non-secrets, declare
        only the non-secret keys; the merge leaves the rest untouched.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    home.activation = lib.mkMerge [
      {
        piCodingAgentSettings =
          mkMergedConfig "settings.json" computedSettings;
      }
      (lib.mapAttrs'
        (name: value:
          lib.nameValuePair
            ("piCodingAgentConfig-"
              + lib.replaceStrings [ "." "/" ] [ "-" "-" ] name)
            (mkMergedConfig name value))
        cfg.extraConfigFiles)
    ];
  };
}
