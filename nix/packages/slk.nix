{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "slk";
  version = "0.26.2";

  src = fetchFromGitHub {
    owner = "gammons";
    repo = "slk";
    rev = "v${version}";
    hash = "sha256-wp4c37c4BMKJzszI1pl751+ATe21Azr4gNN4g7xgkx8=";
  };

  vendorHash = "sha256-/J4gr4m9v6Y0Be8BU4wepIdl2sjoPh0pFCvJL2kIeLk=";

  subPackages = [ "cmd/slk" ];

  # Matches upstream linux release builds (static, no X11 clipboard).
  env.CGO_ENABLED = 0;

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];

  meta = with lib; {
    description = "Terminal UI client for Slack";
    homepage = "https://getslk.sh";
    license = licenses.mit;
    mainProgram = "slk";
  };
}
