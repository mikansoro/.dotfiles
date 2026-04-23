{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.mikansoro.claude.enable (lib.mkMerge [
    {
      home.packages = with pkgs; [
        really-unstable.nono
        really-unstable.beans
      ];

      programs.claude-code = lib.mkMerge [
      {
        enable = true;
        package = pkgs.unstable.claude-code;

        memory.source = ./claude-memory.md;

        settings = {
          env = {
            CLAUDE_CODE_ATTRIBUTION_HEADER = "0";
            CLAUDE_CODE_ENABLE_TELEMETRY = "0";
            CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1";
            CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS = "1";
          };
          attribution = {
            pullRequests = false;
            commits = false;
          };
          permissions = {
            deny = [
              "Bash(sops:*)"
              "Read(./.env)"
              "Read(./secrets/**)"
            ];
          };
          spinnerTipsEnabled = false;
        };
        hooks = {
          SessionStart = ''
            beans prime
          '';
           PreCompact = ''
            beans prime
          '';
         };
        #hooks = {
        #  no-command-chaining = ''
        #    #!/usr/bin/env bash
        #    input=$(cat)
        #    command=$(echo "$input" | ${pkgs.jq}/bin/jq -r '.tool_input.command // empty')

        #    if echo "$command" | grep -qE '\||\&\&|[^|]\&[[:space:]]*$'; then
        #      echo "Error: Command chaining is not allowed. Run one command at a time." >&2
        #      exit 2
        #    fi

        #    exit 0
        #  '';
        #};
      }

      (lib.mkIf (config.mikansoro.machineUsage == "personal") {
        mcpServers = {
          searxng = {
            command = "${pkgs.mcp-searxng}/bin/mcp-searxng";
            env.SEARXNG_URL = "https://searx.int.mikansystems.com/";
          };
        };
        settings = {
          permissions = {
            deny = [
              #"WebSearch(*)"
              "WebFetch(domain:*)"
            ];
          };
        };
      })

      (lib.mkIf (config.mikansoro.machineUsage == "work") {
        settings = {
          alwaysThinkingEnabled = true;
          model = "opus";
        };
      })
    ];
    }

    (lib.mkIf (config.mikansoro.machineUsage == "personal") {
      home.packages = with pkgs; [
        mcp-searxng
        (pkgs.writeShellScriptBin "claude-local" ''
          export ANTHROPIC_AUTH_TOKEN="ollama"
          export ANTHROPIC_API_KEY=""
          export ANTHROPIC_BASE_URL="http://ollama.int.mikansystems.com:11395"
          export ANTHROPIC_DEFAULT_OPUS_MODEL="qwen3.5-27b-code"
          export ANTHROPIC_DEFAULT_SONNET_MODEL="qwen3.5-27b-code"
          export ANTHROPIC_DEFAULT_HAIKU_MODEL="qwen3.5-27b-code"
          export CLAUDE_CODE_SUBAGENT_MODEL="qwen3.5-27b-code"
          exec claude "$@"
        '')
      ];
    })
  ]);
}
