{ config, lib, pkgs, ... }:

let
  # Build the .lsp.json content
  lspConfig = {
    go = {
      command = "${pkgs.gopls}/bin/gopls";
      args = [ "serve" ];
      extensionToLanguage.".go" = "go";
    };
    python = {
      command = "${pkgs.basedpyright}/bin/basedpyright-langserver";
      args = [ "--stdio" ];
      extensionToLanguage = {
        ".py" = "python";
        ".pyi" = "python";
      };
    };
    typescript = {
      command = "${pkgs.vtsls}/bin/vtsls";
      args = [ "--stdio" ];
      extensionToLanguage = {
        ".ts" = "typescript";
        ".tsx" = "typescriptreact";
        ".js" = "javascript";
        ".jsx" = "javascriptreact";
      };
    };
    yaml = {
      command = "${pkgs.yaml-language-server}/bin/yaml-language-server";
      args = [ "--stdio" ];
      extensionToLanguage = {
        ".yaml" = "yaml";
        ".yml" = "yaml";
      };
    };
  };

  # Replicate what the unstable module does internally
  lspPluginDir = pkgs.runCommand "claude-code-lsp-plugin" { } ''
    install -Dm644 ${
      pkgs.writeText "plugin.json" (builtins.toJSON {
        name = "claude-code-lsp";
      })
    } $out/.claude-plugin/plugin.json

    install -Dm644 ${
      pkgs.writeText "lsp.json" (builtins.toJSON lspConfig)
    } $out/.lsp.json
  '';

  # Wrap the base package with --plugin-dir
  claudeWithLsp = pkgs.symlinkJoin {
    name = "claude-code";
    paths = [ pkgs.unstable.claude-code ];
    postBuild = ''
      mv $out/bin/claude $out/bin/.claude-wrapped
      cat > $out/bin/claude <<EOF
      #! ${pkgs.bash}/bin/bash -e
      exec -a "\$0" "$out/bin/.claude-wrapped" --plugin-dir ${lspPluginDir} "\$@"
      EOF
      chmod +x $out/bin/claude
    '';
    inherit (pkgs.unstable.claude-code) meta;
  };
in
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
          package = claudeWithLsp;
          
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
          # NOTE: only on home-manager unstable, see let block for workaround until then
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
          exec claude "$@"
        '')
      ];
    })
  ]);
}
  
  
