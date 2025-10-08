let
  newVer = "2025.08.11";
in
final: prev: {
  yt-dlp = prev.yt-dlp.overrideAttrs (old: {
    version = newVer;
    src = prev.fetchFromGitHub {
        owner = "yt-dlp";
        repo = "yt-dlp";
        tag = newVer;
        hash = "sha256-VNUkCdrzbOwD+iD9BZUQFJlWXRc0tWJAvLnVKNZNPhQ=";
    };
  });

  python3Packages = prev.python3Packages // {
    yt-dlp = prev.python3Packages.yt-dlp.overridePythonAttrs (old: {
      version = newVer;
      src = prev.fetchFromGitHub {
        owner  = "yt-dlp";
        repo   = "yt-dlp";
        rev    = "refs/tags/${newVer}";
        hash   = "sha256-VNUkCdrzbOwD+iD9BZUQFJlWXRc0tWJAvLnVKNZNPhQ=";
      };
    });
  };
}
