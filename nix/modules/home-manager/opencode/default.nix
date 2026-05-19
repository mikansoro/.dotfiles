{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.mikansoro.opencode.enable (lib.mkMerge [
    {
      #home.packages = with pkgs; [
      #  really-unstable.nono
      #  really-unstable.beans
      #];

      programs.opencode = {
        enable = true;
        package = pkgs.unstable.opencode;
        
        # Make LSP binaries available to opencode without auto-download.
        #extraPackages = with pkgs; [
        #  go
        #  gopls                        # Go
        #  nixd                         # Nix  (use `nil` if you prefer)
        #  basedpyright                 # Python (or `pyright`, `python3Packages.python-lsp-server`)
        #  python315
        #  typescript-language-server   # TypeScript / JavaScript
        #  typescript                   # tsserver, required by ts-language-server
        #  mcp-searxng
        #];
        
        settings = {
          model = "qwen3.6-35b-code";
          
          provider = {
            llamacpp = {
              npm = "@ai-sdk/openai-compatible";
              name = "llama.cpp server";
              options = {
                baseURL = "http://ollama.int.mikansystems.com:11395/v1";
                # llama-swap and llama.cpp don't require api keys
                apiKey = "not-required";
              };
              models = {
                "qwen3.6-35b-code" = {
                  name = "Qwen3.6 35b-A3B Code";
                  limit = {
                    context = 131072;
                    output = 32768;
                  };
                };
                "qwen3.6-35b-precise" = {
                  name = "Qwen3.6 35b-A3B Precise Code";
                  limit = {
                    context = 131072;
                    output = 32768;
                  };
                };
              };
            };
          };

          lsp = {
            go = {
              command    = [ (lib.getExe pkgs.gopls) ];
              extensions = [ ".go" ];
            };
            
            nix = {
              command    = [ (lib.getExe pkgs.nixd) ];
              extensions = [ ".nix" ];
            };
            
            python = {
              command    = [ "${pkgs.basedpyright}/bin/basedpyright-langserver" "--stdio" ];
              extensions = [ ".py" ".pyi" ];
            };
            
            typescript = {
              command    = [ (lib.getExe pkgs.typescript-language-server) "--stdio" ];
              extensions = [ ".ts" ".tsx" ".js" ".jsx" ".mjs" ".cjs" ];
              # initialization options are server-specific; example:
              initialization = {
                preferences.importModuleSpecifierPreference = "relative";
              };
            };
          };

          mcp = {
            searxng = {
              type = "local";
              command = [ (lib.getExe pkgs.mcp-searxng) ];
              environment = {
                "SEARXNG_URL" = "https://searx.int.mikansystems.com/";
              };
            };
          };
        };
      };
      
    }
  ]);
}
  
  
