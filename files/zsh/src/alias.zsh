
if command_exists git; then
  alias g="git"
fi

if command_exists kubectl; then
  alias k="kubectl"
  alias kg="kubectl get"
  alias kd="kubectl describe"
  alias ka="kubectl apply"
  alias kdel="kubectl delete"
  alias klogs="kubectl logs"
  alias kexec="kubectl exec -it"
  alias kcl="kubectl ctx"
  alias kns="kubectl ns"
  alias kapir="kubectl api-resources"
  alias kpodw="kubectl get pods -w"
fi

if command_exists kustomize; then
  alias kbuild="kustomize build"
fi

if command_exists kubeval; then
  alias kv='kubeval --skip-kinds Application,AppProject --strict --kubernetes-version 1.15.5 $1'
fi

if command_exists conftest; then
  alias kconftest='conftest test -p ${KUBERNETES_MANIFESTS_DIRECTORY}/policy $1'
  alias kconfcombined='conftest test -p ${KUBERNETES_MANIFESTS_DIRECTORY}/policy --namespace combined --combine $1'
fi

if command_exists kubeconform; then
  alias kconform="kubeconform -summary -skip AnalysisTemplate,Application,AppProject,Kustomization,Rollout,TCPMapping -strict -schema-location default -schema-location '${KUBERNETES_MANIFESTS_DIRECTORY}/crd_schemas/{{ .ResourceKind }}-{{ .ResourceAPIVersion }}.json' -kubernetes-version 1.21.0"
fi

# if command_exists kubeconform && command_exists conftest; then
#   alias ktestall='kconform && kconftest && kconfcombined'
# fi

# hacky embed function in alias, just to not define a full function to have params
if command_exists kubeseal; then
  alias kseal="f() {kubeseal --controller-namespace sealed-secrets <$1 >$2};f"
fi

if command_exists saml2aws; then
  alias saml='saml2aws login -a'
  alias samlexec='saml2aws exec -a'
fi

if [ $MACOS ]; then
  alias flushdns="sudo dscacheutil -flushcache;sudo killall -HUP mDNSResponder"
fi

alias edit="${EDITOR}"

if command_exists terraform; then
  alias tf="terraform"
fi

if command_exists minikube; then
  alias mk="minikube"
fi

if command_exists ripgrep; then
  alias rg='ripgrep'
fi

alias ll="ls -al"
alias la="ls -al"

alias ssha="ssh -A"
# whitelist old algos for working with old cisco switches
alias sshcisco="ssh -oKexAlgorithms=+diffie-hellman-group1-sha1 -c aes128-cbc -l"
