{ lib, buildNpmPackage, fetchFromGitHub }:

buildNpmPackage rec {
  pname = "mcp-searxng";
  version = "0.9.2";

  src = fetchFromGitHub {
    owner = "ihor-sokoliuk";
    repo = "mcp-searxng";
    rev = "v${version}";
    hash = "sha256-pYYMAAdVwQm2nfaGgCZLExj/MmA1VICbkwylHOEtxck="; 
  };

  npmDepsHash = "sha256-jEgPkg9mTq51pn2gJKIDMzWzLmnRGEFJS5BwI8uAgtU=";

  # The package builds to dist/ via tsc
  npmBuildScript = "build";

  meta = with lib; {
    description = "MCP Server for SearXNG";
    homepage = "https://github.com/ihor-sokoliuk/mcp-searxng";
    license = licenses.mit;
    mainProgram = "mcp-searxng";
  };
}
