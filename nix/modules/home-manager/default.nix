{ ... }:

{
  imports = [
    ./options.nix
    ./common
    ./shell
    ./git
    ./emacs
    ./claude
    ./firefox
    ./gpg-agent
    ./server
  ];
}
