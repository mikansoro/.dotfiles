self: super: {
  # found here: https://github.com/nubank/nixpkgs/blob/master/default.nix
  # cant just call overrideAttrs and replace version, since version is hard-coded in mkTerraform in nixpkgs
  # grab shas from the nixpkgs commits for upgrades to tf
  terraform = (pkgs.mkTerraform {
    version = "1.1.9";
    sha256 = "sha256-6dyP3Y5cK+/qLoC2QPZW3QNgqOeVXegC06Pa7pSv1iE=";
    vendorSha256 = "sha256-YI/KeoOIxgCAS3Q6SXaW8my0PyFD+pyksshQEAknsz4=";
  });
}
