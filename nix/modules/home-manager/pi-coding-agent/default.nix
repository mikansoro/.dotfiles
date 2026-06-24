{ config, lib, pkgs, ... }:

let
  cfg = config.mikansoro.pi-coding-agent;
  
  extensionPaths = lib.attrValues pkgs.piExtensions;
  
  # Declarative settings. Anything you put here wins over what pi writes.
  # Anything you OMIT is preserved across rebuilds (e.g. lastChangelogVersion,
  # or defaultModel if you want /model selection to stick).
  settings = {
    defaultProvider      = "anthropic";
    defaultThinkingLevel = "xhigh";
    transport            = "auto";
    
    enabledModels = [
      "anthropic/claude-opus-4-7"
      "anthropic/claude-opus-4-6"
      "anthropic/claude-sonnet-4-6"
      "llama-swap/qwen3.6-35b-precise"
      "llama-swap/qwen3.6-35b-code"
      "llama-swap/qwen3.5-122b-code"
    ];
    
    packages = map toString extensionPaths;
    
    # Intentionally NOT setting defaultModel — let `/model` persist.
  };
  
  searxngConfig = {
    baseUrl           = "http://searx.lan:8080";
    defaultLanguage   = "en";
    defaultCategories = "general";
    timeoutMs         = 15000;
    maxFetchChars     = 60000;
    # apiKey: intentionally omitted; pi's /searxng menu sets it.
  };
  
  llamaSwapConfig = {
    baseUrl = "http://ollama.int.mikansystems.com:11395";
  };
  
  # Build an activation entry that merges a Nix-built JSON file into
  # ~/.pi/agent/<name>, preserving any keys pi writes that we don't manage.
  mkMergedConfig = name: declarative:
    let
      declFile = pkgs.writeText "pi-${name}-decl.json"
        (builtins.toJSON declarative);
    in lib.hm.dag.entryAfter [ "writeBoundary" ] ''
                             TARGET="$HOME/.pi/agent/${name}"
                             run mkdir -p "$(dirname "$TARGET")"
                             
                             # Clean up any leftover read-only symlink from previous (home.file) setups.
                             if [ -L "$TARGET" ]; then
                             run rm -f "$TARGET"
                             fi
                             
                             if [ -f "$TARGET" ]; then
                             # Merge: existing first, declarative second so declarative wins on
                             # any shared key. jq's `*` operator does a recursive object merge;
                             # arrays are replaced wholesale (which is what we want for `packages`
                             # and `enabledModels`).
                             TMP="$(mktemp)"
                             ${lib.getExe pkgs.jq} -S -s '.[0] * .[1]' \
                             "$TARGET" ${declFile} > "$TMP"
                             run mv "$TMP" "$TARGET"
                             run chmod 644 "$TARGET"
                             else
                             run install -m 644 ${declFile} "$TARGET"
                             fi
                             '';
in {
  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.unstable.pi-coding-agent ];
    
    home.activation = {
      piSettings  = mkMergedConfig "settings.json"  settings;
      piSearxng   = mkMergedConfig "searxng.json"   searxngConfig;
      piLlamaSwap = mkMergedConfig "llama-swap.json" llamaSwapConfig;
    };
    
    # auth.json: never touched. Pi owns it, user writes via /login.
  };
}
