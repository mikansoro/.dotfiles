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

                # stop running find -- exec damnit. use ripgrep.
                "Bash(find *-exec grep*)"
                "Bash(find *-exec egrep*)"
                "Bash(find *-exec fgrep*)"
                "Bash(find *|*xargs *grep*)"
                "Bash(find *|*xargs *egrep*)"
                "Bash(find *|*xargs *fgrep*)"
                "Bash(grep -r*)"
                "Bash(grep -R*)"
                "Bash(grep -nr*)"
                "Bash(grep -nR*)"
                "Bash(grep -lr*)"
                "Bash(grep -lR*)"
                "Bash(grep --recursive*)"
                "Bash(xargs -I{} sh*)"
              ];
            };
            spinnerTipsEnabled = false;
          };
          # NOTE: only on home-manager unstable
          #lspServers = {
          #  go = {
          #    command = "${pkgs.gopls}/bin/gopls"; 
          #    args = [ "serve" ];
          #    extensionToLanguage = {
          #      ".go" = "go";
          #    };
          #  };
          #  python = {
          #    command = "${pkgs.basedpyright}/bin/basedpyright-langserver";
          #    args = [ "--stdio" ];
          #    extensionToLanguage = {
          #      ".py" = "python";
          #      ".pyi" = "python";
          #    };
          #  };
          #  typescript = {
          #    command = "${pkgs.vtsls}/bin/vtsls";
          #    args = [ "--stdio" ];
          #    extensionToLanguage = {
          #      ".ts" = "typescript";
          #      ".tsx" = "typescriptreact";
          #      ".js" = "javascript";
          #      ".jsx" = "javascriptreact";
          #    };
          #  };
          #  yaml = {
          #    command = "${pkgs.yaml-language-server}/bin/yaml-language-server";
          #    args = [ "--stdio" ];
          #    extensionToLanguage = {
          #      ".yaml" = "yaml";
          #      ".yml" = "yaml";
          #    };
          #  };
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
          export CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS="1"
          exec claude "$@"
        '')
      ];
    })
  ]);
}
  
  
