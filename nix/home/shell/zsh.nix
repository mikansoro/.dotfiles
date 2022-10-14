{ config, pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      g = "git";
      k = "kubectl";
      kg = "kubectl get";
      kd = "kubectl describe";
      ka = "kubectl apply";
      kdel = "kubectl delete";
      klogs = "kubectl logs";
      kexec = "kubectl exec -it";
      kcl = "kubectl ctx";
      kns = "kubectl ns";
      kapir = "kubectl api-resources";
      kbuild = "kustomize build";
      kv = "kubeval --skip-kinds Application,AppProject --strict --kubernetes-version 1.15.5 $1";
      #  alias kconftest='conftest test -p ${KUBERNETES_MANIFESTS_DIRECTORY}/policy $1';
      #  alias kconfcombined='conftest test -p ${KUBERNETES_MANIFESTS_DIRECTORY}/policy --namespace combined --combine $1';
      #  alias kconform="kubeconform -summary -skip AnalysisTemplate,Application,AppProject,Kustomization,Rollout,TCPMapping -strict -schema-location default -schema-location '${KUBERNETES_MANIFESTS_DIRECTORY}/crd_schemas/{{ .ResourceKind }}-{{ .ResourceAPIVersion }}.json' -kubernetes-version 1.21.0";
      #   alias ktestall='kconform && kconftest && kconfcombined';
      # hacky embed function in alias, just to not define a full function to have params;
      # if command_exists kubeseal; then;
      kubeseal = "f() {kubeseal --controller-namespace sealed-secrets <$1 >$2};f";
      # fi;
      # if [ $MACOS ]; then;
      #   alias flushdns="sudo dscacheutil -flushcache;sudo killall -HUP mDNSResponder";
      # fi;
      tf = "terraform";
      mk = "minikube";
      rg = "ripgrep";
      ll = "ls -al";
      la = "ls -al";
      ssha = "ssh -A";
      # whitelist old algos for working with old cisco switches;
      sshcisco = "ssh -oKexAlgorithms=+diffie-hellman-group1-sha1 -c aes128-cbc -l";
    };
    initExtraBeforeCompInit = """
""";
  };
}
