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
  config = {
    programs.claude-code.skills = lib.mkIf config.mikansoro.claude.enable discoverSkills;
    programs.opencode.skills = lib.mkIf config.mikansoro.opencode.enable discoverSkills;
    home.file."./pi/agent/skills".source = lib.mkIf config.mikansoro.pi-coding-agent.enable ./skills;
  };
}
