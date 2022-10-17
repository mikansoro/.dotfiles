{ config, lib, pkgs, ... }:

{
  imports = [
    ../modules/common
    ../modules/shell
    ../modules/git
    # ../modules/emacs
  ];

  programs.home-manager.enable = true;

  home = {
    username = "mrowland";
    homeDirectory = "/Users/mrowland";
    stateVersion = "22.05";

    packages = with pkgs; [
      argocd
      awscli2
      aws-iam-authenticator
      aws-sam-cli
      conftest
      eksctl
      # docker-machine-hyperkit #darwin-only
      kind
      kubeconform
      # mongosh # unknown variable
      mysql-shell
      open-policy-agent
      saml2aws
      skaffold
      skopeo
      sqlite
      # upx #golang-tooling
      pinentry_mac
    ];
  };

  # gpg-agent with pinentry_mac workaround - START
  # inispiration: https://github.com/jwiegley/nix-config/blob/master/config/home.nix
  #
  services.gpg-agent.enable = false;
  xdg = {
    enable = true;

    configFile."gnupg/gpg-agent.conf".text = ''
      enable-ssh-support
      default-cache-ttl 60
      max-cache-ttl 120
      pinentry-program ${pkgs.pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac
    '';
  };
  programs.zsh.profileExtra = ''
    export GPG_TTY=$(tty)
    if ! pgrep -x "gpg-agent" > /dev/null; then
        ${pkgs.gnupg}/bin/gpgconf --launch gpg-agent
    fi
  '';
  home.sessionVariables = {
    SSH_AUTH_SOCK = "${config.xdg.configHome}/gnupg/S.gpg-agent.ssh";
  };
  # gpg-agent with pinentry_mac workaround - END

  programs.zsh = {
    shellAliases = {
      kconftest = "conftest test -p $HOME/git/foursquare/kubernetes-manifests/policy $1";
      kconfcombined = "conftest test -p $HOME/git/foursquare/kubernetes-manifests/policy --namespace combined --combine $1";
      kconform = "kubeconform -summary -skip AnalysisTemplate,Application,AppProject,Kustomization,Rollout,TCPMapping -strict -schema-location default -schema-location '$HOME/git/foursquare/kubernetes-manifests/crd_schemas/{{ .ResourceKind }}-{{ .ResourceAPIVersion }}.json' -kubernetes-version 1.21.0";
      ktestall = "kconform && kconftest && kconfcombined";
      flushdns = "sudo dscacheutil -flushcache;sudo killall -HUP mDNSResponder";
    };
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
      }
      {
        condition = "gitdir:~/git/factual/";
        contents = {
          user = {
            email = "mrowland@foursquare.com";
            name = "Michael Rowland";
          };
        };
      }
      {
        condition = "gitdir:~/git/placed/";
        contents = {
          user = {
            email = "mrowland@foursquare.com";
            name = "Michael Rowland";
          };
        };
      }
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

  targets.darwin.defaults = {
      "com.apple.desktopservices" = {
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };
    };
}
