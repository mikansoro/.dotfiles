{ lib, buildNpmPackage, fetchFromGitHub }:

# Pinned build of mikansoro/pi-mcp-adapter (fork of nicobailon/pi-mcp-adapter)
# for use as a pi-coding-agent extension.
#
# Why a fork?
#
# Upstream gitignores package-lock.json (intentional — they ship via npm where
# the published tarball is sufficient). That makes every `pi install` /
# `npm install` re-resolve the entire transitive dep tree from npm, which we
# want to avoid from a supply-chain audit standpoint. The fork commits the
# lockfile and tags pinned revisions; nix then builds against an
# `npmDepsHash`-verified tree.
#
# Re-audit on each upstream sync:
#   git remote add upstream https://github.com/nicobailon/pi-mcp-adapter.git
#   git fetch upstream && git diff v<old>-pinned..upstream/main
# Then re-tag, bump the version below, and refresh both hashes.
#
# pi-mcp-adapter has no build step — package.json#pi.extensions points at
# ./index.ts and pi loads it via jiti at runtime. So `dontNpmBuild = true`
# and the install phase just copies the source tree (with hashed
# node_modules) into $out, same shape as pi-lens.
#
# in fork, i had to: 
#   Drop @earendil-works/pi-coding-agent devDep to eliminate its
#   hasShrinkwrap subtree, which left three nested @earendil-works/*
#   entries without integrity hashes and broke prefetch-npm-deps in
#   buildNpmPackage. Types come from the host pi installation at
#   runtime, so this devDep is unnecessary for the extension to load.

buildNpmPackage rec {
  pname = "pi-mcp-adapter";
  version = "2.10.0-pinned-1";

  src = fetchFromGitHub {
    owner = "mikansoro";
    repo = "pi-mcp-adapter";
    rev = "v${version}";
    hash = "sha256-btwv77zyeMza+j0BLC/vcHFBnI+qLpWbQ4+nteSQigE=";
  };

  # Nix will tell us on first build.
  npmDepsHash = "sha256-5zNe2tQ8ANwKBRRewEmiC+DWxN9Nppc42xOhxMDmNPE=";

  # No build script in package.json — pi loads index.ts directly.
  dontNpmBuild = true;

  # We want the whole tree (source + node_modules), not just dist/ — pi
  # loads the package directory and follows package.json#pi.extensions.
  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r . $out/
    runHook postInstall
  '';

  meta = with lib; {
    description = "Token-efficient MCP adapter for pi (pinned/audited fork)";
    homepage = "https://github.com/mikansoro/pi-mcp-adapter";
    license = licenses.mit;
  };
}
