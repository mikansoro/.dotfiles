{ config, lib, pkgs, ... }:

{
  imports = [
    ../../home/modules/common
    ../../home/modules/shell
    ../../home/modules/git
    # ../../home/modules/gpg-agent
    ../../home/modules/gpg
    ../../home/modules/emacs
  ];

  programs.home-manager.enable = true;

  home = {
    # username = "mrowland";
    # homeDirectory = "/Users/mrowland";
    stateVersion = "22.05";

    packages = with pkgs; [
      argocd
      awscli2
      aws-iam-authenticator
      aws-sam-cli
      conftest
      eksctl
      # docker-machine-hyperkit #darwin-only - from brew installed list
      kind
      kubeconform
      # mongosh # unknown variable
      # mysql-shell # build fail, ld fatal warning - libs were build for newer macos version than linked (10.12 vs 10.10)
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
  # programs.gpg in module above
  services.gpg-agent.enable = false;
  xdg.configFile."gnupg/gpg-agent.conf".text = ''
    enable-ssh-support
    default-cache-ttl 60
    max-cache-ttl 120
    pinentry-program ${pkgs.pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac
  '';
  programs.zsh.profileExtra = ''
    export GPG_TTY=$(tty)
    if ! pgrep -x "gpg-agent" > /dev/null; then
        ${pkgs.gnupg}/bin/gpgconf --launch gpg-agent
    fi
  '';
  home.sessionVariables = {
    SSH_AUTH_SOCK = "$(${pkgs.gnupg}/bin/gpgconf --list-dirs agent-ssh-socket)";
  };
  # gpg-agent with pinentry_mac workaround - END

  xdg = {
    enable = true;
  };

  programs.zsh = {
    shellAliases = {
      kconftest = "conftest test -p $HOME/git/foursquare/kubernetes-manifests/policy $1";
      kconfcombined = "conftest test -p $HOME/git/foursquare/kubernetes-manifests/policy --namespace combined --combine $1";
      kconform = "kubeconform -summary -skip AnalysisTemplate,Application,AppProject,Kustomization,Rollout,TCPMapping -strict -schema-location default -schema-location '$HOME/git/foursquare/kubernetes-manifests/crd_schemas/{{ .ResourceKind }}-{{ .ResourceAPIVersion }}.json' -kubernetes-version 1.21.0";
      ktestall = "kconform && kconftest && kconfcombined";
      flushdns = "sudo dscacheutil -flushcache;sudo killall -HUP mDNSResponder";
    };
    initExtraBeforeCompInit = "PATH='/Users/mrowland/bin':$PATH";
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