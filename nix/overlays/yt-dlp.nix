# overlays/yt-dlp.nix
let
  newVer = "2025.08.11";
  rev    = "refs/tags/${newVer}";
  sha256 = "sha256-VNUkCdrzbOwD+iD9BZUQFJlWXRc0tWJAvLnVKNZNPhQ=";
in
final: prev:

let
  src = final.fetchFromGitHub {
    owner  = "yt-dlp";
    repo   = "yt-dlp";
    inherit rev sha256;
  };

  # Python package override
  py3 = prev.python3.override {
    packageOverrides = pyf: pyp: {
      yt-dlp = pyp.yt-dlp.overridePythonAttrs (old: {
        inherit src;
        version = newVer;
      });
    };
  };
in
{
  # top-level wrapper
  yt-dlp = prev.yt-dlp.overrideAttrs (old: {
    inherit src;
    version = newVer;
  });

  # interpreter whose package set contains the new yt-dlp
  python3 = py3;
  python3Packages = py3.pkgs;
}
