{ mLib, ... }:

{
  imports = [
    ./options.nix
  ] ++ mLib.importSubmodules ./.;
}
