{ config, lib, ... }:

let
  skillsDir = ./skills;

  # { skill-name = ./skills/skill-name; ... }
  discoverSkills =
    let
      entries = builtins.readDir skillsDir;
    in
    lib.mapAttrs (name: _: skillsDir + "/${name}")
      (lib.filterAttrs (_: type: type == "directory") entries);
in
{
  config = lib.mkIf config.programs.claude-code.enable {
    programs.claude-code.skills = discoverSkills;
  };
}
