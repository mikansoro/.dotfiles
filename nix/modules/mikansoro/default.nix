{ lib, ... }:

{
  options.mikansoro = {
    machineUsage = lib.mkOption {
      type = lib.types.enum [ "personal" "work" ];
      description = ''
        Whether this machine is used for personal or work purposes.
        Use this for usage-context gating (e.g. which API backend to use,
        which apps to install). Use pkgs.stdenv.isDarwin for
        platform-specific concerns (e.g. build deps, audio backends).
      '';
      example = "personal";
    };
  };
}
