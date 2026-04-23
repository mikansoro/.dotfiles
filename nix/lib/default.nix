{ lib }:

{
  # importSubmodules: path -> [path]
  # Scans `dir` for immediate subdirectories that contain a default.nix,
  # returns a list of paths suitable for use in `imports = [...]`.
  importSubmodules = dir:
    let
      entries = builtins.readDir dir;
      isImportable = name: type:
        type == "directory"
        && builtins.pathExists (dir + "/${name}/default.nix");
    in
      lib.mapAttrsToList (name: _: dir + "/${name}")
        (lib.filterAttrs isImportable entries);
}
