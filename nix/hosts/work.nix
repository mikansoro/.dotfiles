{ config, pkgs, lib, ... }:
{
  home = {
    packages = with pkgs; [
      argocd
      aws
      aws-iam-authenticator
      aws-sam-cli
      conftest
      eksctl
      # docker-machine-hyperkit #darwin-only
      kind
      kubeconform
      mongosh
      mysql-shell
      open-policy-agent
      saml2aws
      skaffold
      # skopeo
      sqlite
      # upx #golang-tooling
    ];
  };

  programs.git = {
    includes = [
      {
        condition = "gitdir:~/git/foursquare/";
        contents = {
          user = {
            email = "mrowland@foursquare.com";
            name = "Michael Rowland";
          };
        };
      },
      {
        condition = "gitdir:~/git/factual/";
        contents = {
          user = {
            email = "mrowland@foursquare.com";
            name = "Michael Rowland";
          };
        };
      },
      {
        condition = "gitdir:~/git/placed/";
        contents = {
          user = {
            email = "mrowland@foursquare.com";
            name = "Michael Rowland";
          };
        };
      },
      {
        condition = "gitdir:~/git/unfolded/";
        contents = {
          user = {
            email = "mrowland@foursquare.com";
            name = "Michael Rowland";
          };
        };
      }
    ];
  };
};
