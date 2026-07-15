{ lib, buildNpmPackage, fetchFromGitHub }:

# Pinned build of apmantza/pi-lens for use as a pi-coding-agent extension.
#
# pi-lens has real runtime npm dependencies AND a build step (tsc -> dist/),
# so we use buildNpmPackage (the second template in
# nix/modules/home-manager/pi-coding-agent/README.md).
#
# On first build, nix will report the real value for npmDepsHash — copy it
# back into this file. Same drill for the src hash if the tag ever changes.

buildNpmPackage rec {
  pname = "pi-lens";
  version = "3.8.60";

  src = fetchFromGitHub {
    owner = "apmantza";
    repo = "pi-lens";
    rev = "v${version}";
    hash = "sha256-UPhiPT5FPoKLps+8TgAuX5c7yGvkwx7F9nPXGNfSuL8=";
  };

  # Nix will tell us on first build.
  npmDepsHash = lib.fakeHash;

  # `npm install`'s postinstall in this repo runs scripts/download-grammars.js,
  # which fetches tree-sitter wasm grammars over the network. That fails in
  # the nix sandbox, so skip scripts during install. The grammars are an
  # opt-in capability — pi-lens still loads without them.
  npmFlags = [ "--ignore-scripts" ];

  # `build:dist` is the script pi-lens uses to produce its shipped dist/
  # (wipes dist/, runs `tsc --project tsconfig.dist.json --noCheck`).
  npmBuildScript = "build:dist";

  # We want the whole tree (source + node_modules + built dist/), not just
  # dist/ — pi loads the package directory and follows package.json#pi.extensions.
  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r . $out/
    runHook postInstall
  '';

  meta = with lib; {
    description = "Real-time code feedback for pi — LSP, linters, formatters, structural analysis";
    homepage = "https://github.com/apmantza/pi-lens";
    license = licenses.mit;
  };
}
