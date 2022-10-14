inputs: let
  inherit (inputs) self;
  inherit (self.lib) mkHome extraSpecialArgs;

  sharedModules = [
    ../shell
  ];

  homeImports = {
    "mrowland@work" = sharedModules;
    "michael@home" = sharedModules;
    "server" = sharedModules;
  };

in {
  inherit homeImports extraSpecialConfigs;

  homeConfigurations = {
    "mrowland@foursquare" = ""; #lib.mkhome {modules = homeImports."mrowland@foursquare";};
    "michael@home" = "";
    "server" = "";
  };
}
