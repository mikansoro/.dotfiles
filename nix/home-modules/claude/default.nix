{ config, lib, pkgs, ... }:

{
  home = {
    packages = with pkgs; [
      mcp-searxng
    ];
  };
  
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
    
    # TODO: base this off some "iswork" key later
    (lib.mkIf (!pkgs.stdenv.isDarwin) {
      mcpServers = {
        searxng = {
          command = "${pkgs.mcp-searxng}/bin/mcp-searxng";
          env.SEARXNG_URL = "https://searx.int.mikansystems.com/";
        };
      };
      settings = {
        env = {
          # local settings
          ANTHROPIC_AUTH_TOKEN = "ollama";
          ANTHROPIC_API_KEY = "";
          #ANTHROPIC_BASE_URL = "http://ollama.int.mikansystems.com:11434";
          ANTHROPIC_BASE_URL = "http://ollama.int.mikansystems.com:11395";
          ANTHROPIC_DEFAULT_OPUS_MODEL = "qwen3.5-27b-code";
          ANTHROPIC_DEFAULT_SONNET_MODEL = "qwen3.5-27b-code";
          ANTHROPIC_DEFAULT_HAIKU_MODEL = "qwen3.5-27b-code";
          CLAUDE_CODE_SUBAGENT_MODEL = "qwen3.5-27b-code";
          
        };
        permissions = {
          deny = [
            #"WebSearch(*)"
            "WebFetch(domain:*)"
          ];
        };
      };
    })

    (lib.mkIf pkgs.stdenv.isDarwin { 
      settings = {
        alwaysThinkingEnabled = true;
        model = "opus";
      };
    })
  ];
}
