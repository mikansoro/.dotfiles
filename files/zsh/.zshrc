
typeset -U path cdpath fpath manpath

autoload -U compinit && compinit

HISTSIZE="10000"
SAVEHIST="10000"

HISTFILE="$HOME/.zsh_history"
mkdir -p "$(dirname "$HISTFILE")"

setopt HIST_FCNTL_LOCK
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
unsetopt HIST_EXPIRE_DUPS_FIRST
setopt SHARE_HISTORY
unsetopt EXTENDED_HISTORY

# Functions
# ---------

function _bim() {
    echo "Hey Bim! Guess what?"
    echo "The Shijo-Ohashi bridge is a bridge representative of Kyoto that crosses the Kamo River over Shijo Street. It is also called Gionbashi."
    [[ ! -z "$1" ]] && read -k1 -s && vim "$1"
}

# chpwd: zsh hook that fires on directory change
function chpwd() {
    changeKubernetesContext
}

function changeKubernetesContext() {
    if [[ $PWD =~ '/kubernetes-manifests/' ]]; then
        pwdArr=($(echo $PWD | sed -e "s/\// /g"))

        currentContext="$(kubectl config view -o jsonpath='{.current-context}')"
        excludedContexts=( "minikube" "kind" )
        excludedDirectories=( "eks-default" "policy" "docs" "crd_schemas" )

        # Optional: associative array to match cluster directory names to kubernetes contexts of differing names
        # Only supported in zsh, and in bash Version 4.
        #
        #declare -A contextDefaultNameMap
        #contextDefaultNameMap["colo"]="cluster.domain.local"

        len="${#pwdArr[@]}"
        context=""
        # grab cluster directory name from path for current context
        for ((i=0; i<$len; i++)); do
            if [[ $pwdArr[i] =~ 'kubernetes-manifests' ]]; then
                context=$pwdArr[i+1]
                break
            fi
        done

        # if directory (context) is in excludedDirectories or excludedContexts, skip
        # if context is defined in the contextDefaultNameMap, use that value. else use $context
        if ! containsElement $context "${excludedDirectories[@]}"; then
            if ! containsElement $currentContext "${excludedContexts[@]}"; then
                if [ -z $contextDefaultNameMap["$context"] ]; then
                    kubectl config use-context "${context}" 1>/dev/null
                else
                    kubectl config use-context "${contextDefaultNameMap["$context"]}" 1>/dev/null
                fi
            fi
        fi
    fi
}

# grabbed shamelessly from https://stackoverflow.com/a/8574392
function containsElement() {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

function ksecret64() {
  echo -n "${1}" | base64
}

# signature: ksecretval [-n namespace] secretname [...]
function ksecretval() {
  local usage='Function Usage: ksecretval [-n namespace] secretname [...]'
  local namespace=$(kubectl config view --minify --output 'jsonpath={..namespace}')

  while getopts ":n:" opt; do
    [[ $OPTARG == -* ]] && { echo "Missing argument for -${opt}\n${usage}" >&2; return 1; }
    case $opt in
      n)
        local namespace=$OPTARG
        ;;
      *)
        echo "Unknown argument -${opt}\n$usage" >&2
        return 1
        ;;
    esac
  done
  shift "$((OPTIND-1))"

  [[ -z ${@} ]] && { echo "No secret names provided. At least one secret name must be present.\n${usage}" >&2; return 1; }

  for secret in ${@}; do
    secretJson=$(kubectl get -n $namespace secret $secret -o json)
    echo "Secret: ${secret} from Namespace ${namespace}"
    jq '.data | walk( if type == "object" then with_entries( .value |= @base64d ) else . end )' <<< $secretJson && echo
  done
}

function appendTextBeforeExtension() {
  for file in "${1}"; do ext="${file##*.}"; filename="${file%.*}"; mv "$file" "${filename}${2}.${ext}"; done
}

# grabbed shamelessly from https://github.com/drduh/YubiKey-Guide
function secret() {
        output=~/"${1}".$(date +%s).enc
        gpg --encrypt --armor --output ${output} -r 0x0000 -r 0x0001 -r 0x0002 "${1}" && echo "${1} -> ${output}"
}

function reveal() {
        output=$(echo "${1}" | rev | cut -c16- | rev)
        gpg --decrypt --output ${output} "${1}" && echo "${1} -> ${output}"
}

# Aliases
# -------

alias bim="_bim"

alias g="git"
alias gcm="git commit -m"
alias gcam="git commit -am"
alias ga="git add"
alias gc="git checkout"
alias gcb="git checkout -b"
alias gb="git branch"
alias gbd="git branch -d"
alias glog="git log --pretty=oneline --graph"
alias gpush="git push"
alias gpull="git pull"

alias k="kubectl"
alias kg="kubectl get"
alias kd="kubectl describe"
alias ka="kubectl apply"
alias kd="kubectl delete"
alias klogs="kubectl logs"
alias kexec="kubectl exec -it"
alias kcl="kubectl ctx"
alias kns="kubectl ns"
alias kbuild="kustomize build"

# hacky embed function in alias, just to not define a full function to have params
alias kubeseal="f() {kubeseal --controller-namespace sealed-secrets <$1 >$2};f"

alias tf="terraform"

alias mk="minikube"

alias ll="ls -al"

alias ssha="ssh -A"
alias sshcisco="ssh -oKexAlgorithms=+diffie-hellman-group1-sha1 -c aes128-cbc -l"

# Source
# -------
eval "$(starship init zsh)"
( [[ /home/michael/.nix-profile/bin/kubectl ]] || [[ /usr/bin/kubectl ]] ) && source <(kubectl completion zsh)
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# setup gpg-agent for ssh on fedora
if cat /etc/os-release | grep "ID=fedora" > /dev/null 2>&1; then
  if which gpg-agent > /dev/null 2>&1; then
    export GPG_TTY=$(tty)
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
    gpgconf --launch gpg-agent
    gpg-connect-agent updatestartuptty /bye 1>/dev/null 2>&1
  fi
fi
