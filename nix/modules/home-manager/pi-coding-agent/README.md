# pi-coding-agent

https://pi.dev

## external plugins

### For extensions I own

- add as a flake input
- add to overlay
- referenceable under `pkgs.piExtensions`

### For extensions I don't own 

 nix/packages/pi-someoneelses-thing.nix:

 ```nix
   { runCommandLocal, fetchFromGitHub }:

   runCommandLocal "pi-someoneelses-thing" {
     src = fetchFromGitHub {
       owner = "someoneelse";
       repo  = "pi-cool-extension";
       rev   = "v0.3.1";
       hash  = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
     };
   } ''
     mkdir -p $out
     cp -r $src/. $out/
   ''
 ```

 If the repo has actual npm dependencies (not just peers), use buildNpmPackage:

 ```nix
   { buildNpmPackage, fetchFromGitHub }:

   buildNpmPackage {
     pname = "pi-cool-extension";
     version = "0.3.1";

     src = fetchFromGitHub {
       owner = "someoneelse";
       repo  = "pi-cool-extension";
       rev   = "v0.3.1";
       hash  = "sha256-...";
     };

     npmDepsHash = "sha256-...";  # nix will tell you on first build
     dontNpmBuild = true;

     # We want the whole tree (source + node_modules), not just dist/.
     installPhase = ''
       runHook preInstall
       mkdir -p $out
       cp -r . $out/
       runHook postInstall
     '';
   }
 ```

 Then in the flake.nix overlay section:

 ```diff
   custom-packages = final: prev: {
     mcp-searxng = final.callPackage ./nix/packages/mcp-searxng.nix { };
+     pi-cool-extension =
+       final.callPackage ./nix/packages/pi-cool-extension.nix { };
   };
 ```
