# kubectl direct binary grab overlay
# found here: https://github.com/cideM/dotfiles/blob/9c304d36eddaebb9f8e2b2d10d48676df3e1d393/flake.nix
self: super: {
  kubectl =
    let
      urls = {
        "x86_64-darwin" = "darwin_amd64";
        "x86_64-linux" = "linux_amd64";
      };
      shas = {
        "x86_64-darwin" = "c902b3c12042ac1d950637c2dd72ff19139519658f69290b310f1a5924586286";
        "x86_64-linux" = "9d2d8a89f5cc8bc1c06cb6f34ce76ec4b99184b07eb776f8b39183b513d7798a";
      };
    in
      super.stdenv.mkDerivation rec {
        name = "terraform";
        version = "1.1.9";
        src = super.fetchurl {
          url = "https://releases.hashicorp.com/terraform/${version}/terraform_${version}_${urls."${super.system}"}.zip";
          sha256 = shas."${super.system}";
        };
        nativeBuildInputs = [ pkgs.unzip ];
        dontConfigure = true;
        dontUnpack = false;
        dontBuild = true;
        installPhase = ''
          mkdir -p $out/bin
          cp $src $out/bin/terraform
          chmod +x $out/bin/terraform
        '';
      };
}
