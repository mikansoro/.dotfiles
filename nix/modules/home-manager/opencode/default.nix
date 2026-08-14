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
          model = "llamacpp/qwen3.6-27b";

          # Fast model for lightweight tasks (session titles, housekeeping)
          # and the default for subagents spawned without an explicit model.
          small_model = "llamacpp/qwen3.6-35b-a3b";

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
                "qwen3.6-27b" = {
                  name = "Qwen3.6-27B (Build)";
                  limit = {
                    context = 131072;
                    output = 32768;
                  };
                };
                "qwen3.6-35b-a3b" = {
                  name = "Qwen3.6-35B-A3B (Plan/Review)";
                  limit = {
                    context = 131072;
                    output = 32768;
                  };
                };
              };
            };
          };

          # Compaction: tune for long agentic sessions.
          compaction = {
            auto = true;      # always on -- prevents hard overflows mid-step
            prune = true;     # drop old tool outputs when context pressure builds (default: false)
            reserved = 8000;  # slightly lower than the 10000 default = more usable space
          };

          # Agent routing: Plan uses the MoE model, Build uses the dense model.
          agent = {
            build = {
              model = "llamacpp/qwen3.6-27b";
              temperature = 0.6;
              permission = {
                read = "allow";
                edit = "allow";
                glob = "allow";
                grep = "allow";
                list = "allow";
                lsp = "allow";
                bash = "ask";
                task = {
                  "*" = "deny";
                  explorer = "allow";
                  reviewer = "allow";
                  tester = "ask";
                };
                todowrite = "allow";
              };
            };
            plan = {
              model = "llamacpp/qwen3.6-35b-a3b";
              temperature = 0.7;
              permission = {
                read = "allow";
                glob = "allow";
                grep = "allow";
                list = "allow";
                lsp = "allow";
                edit = "deny";
                bash = "deny";
                task = "deny";
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

        # Global subagents: run on the MoE model (qwen3.6-35b-a3b), invoked by Build.
        agents = {
          explorer = ''
            ---
            description: >
              Searches the repository to find relevant files, symbols, definitions, call
              sites, or patterns. Returns file paths, line ranges, and brief summaries.
              Never edits files or runs commands.
            mode: subagent
            model: llamacpp/qwen3.6-35b-a3b
            temperature: 0.3
            permission:
              edit: deny
              bash: deny
              lsp: deny
              glob: allow
              grep: allow
              read: allow
              list: allow
            ---

            Locate and summarize relevant code. Return:
            - File paths and specific line ranges
            - Brief explanation of relevance
            - Any interfaces, types, or function signatures the caller needs to know

            Be concise. Your output becomes a single tool-call result in the Build agent's
            context -- keep it under 500 tokens where possible. Do not include reasoning chains.
          '';

          reviewer = ''
            ---
            description: >
              Reviews a code diff or description of changes for correctness, missing tests,
              regressions, and plan adherence. Use after producing a patch, before running
              tests. Never edits files.
            mode: subagent
            model: llamacpp/qwen3.6-35b-a3b
            temperature: 0.3
            permission:
              edit: deny
              bash: deny
              lsp: allow
              read: allow
              glob: allow
              grep: allow
            ---

            You are a code reviewer. Review the provided diff or change description for:

            1. Correctness relative to the stated goal
            2. Regressions or breakage in adjacent code
            3. Missing or inadequate test coverage
            4. Security or data-integrity risks
            5. Consistency with the existing codebase style

            Return a structured verdict only:
            - verdict: accept | revise | escalate
            - issues: list of concrete problems (empty list if none)
            - suggestions: optional improvements (brief)

            Do not praise the code. Do not reproduce the diff. Be direct and brief.
          '';

          tester = ''
            ---
            description: >
              Runs the project's test suite or a focused subset and returns a concise
              summary. Use after edits are reviewed and ready for verification. Reports
              pass/fail counts and failing test output only -- nothing else.
            mode: subagent
            model: llamacpp/qwen3.6-35b-a3b
            temperature: 0.1
            permission:
              edit: deny
              lsp: deny
              bash: allow
              read: allow
            ---

            Run the relevant tests using the commands listed in AGENTS.md.

            Return only:
            - Pass/fail count
            - Names and error output of failing tests (only)
            - Total duration

            Do not include passing test output. Do not explain results. Be brief.
            If AGENTS.md has no test command, report that and stop.
          '';
        };
      };

    }
  ]);
}
  
  
