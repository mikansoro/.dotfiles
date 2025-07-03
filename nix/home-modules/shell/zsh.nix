{ config, pkgs, ... }:
let
  emacs_editor = "emacsclient";
in
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      edit = "${emacs_editor}";
      emcs = "${emacs_editor}";
      g = "git";
      jqish = "jq -R \"fromjson? | .\""; # for reading a file that's only partially jsonlines, ignore any line that isnt jsonlines format
      k = "kubectl";
      kg = "kubectl get";
      kd = "kubectl describe";
      ka = "kubectl apply";
      kdel = "kubectl delete";
      klogs = "kubectl logs";
      kexec = "kubectl exec -it";
      kcl = "kubectx";
      kns = "kubens";
      kapir = "kubectl api-resources";
      kbuild = "kustomize build";
      kv = "kubeval --skip-kinds Application,AppProject --strict --kubernetes-version 1.15.5 $1";
      # hacky embed function in alias, just to not define a full function to have params;
      kubeseal = "f() {kubeseal --controller-namespace sealed-secrets <$1 >$2};f";
      kread = "f() {kubectl get $1 $2 -o yaml | less};f";
      tf = "terraform";
      mk = "minikube";
      ll = "ls -al";
      la = "ls -al";
      ssha = "ssh -A";
      # whitelist old algos for working with old cisco switches;
      sshcisco = "ssh -oKexAlgorithms=+diffie-hellman-group1-sha1 -oHostKeyAlgorithms=+ssh-rsa -c aes128-cbc -l";

      # cut stern's output to remove which pod returned the log, leaving the raw log output (usually to pipe to jq)
      unstern = "tr -s ' ' ' ' | cut -d' ' -f3-";
    };
    sessionVariables = {
      EDITOR = "${emacs_editor}";
      ALTERNATE_EDITOR = "emacs -nw $@";
      VISUAL = "${emacs_editor}";
    };
    initExtraBeforeCompInit = builtins.concatStringsSep "\n" [
      (builtins.readFile ./functions.zsh)
      "bindkey \"^[[3~\" delete-char"
      # (builtins.readFile ./zshrc-extra.zsh)
    ];
    initExtra = builtins.concatStringsSep "\n" [
      "source <(${pkgs.kubectl}/bin/kubectl completion zsh)"
    ];
  };
}
