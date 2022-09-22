
# --------------
# general
# --------------

# chpwd: zsh hook that fires on directory change
function chpwd() {
    changeKubernetesContext
}

# https://github.com/timidtogekiss/bim
# vim typo alias
function bim() {
    echo "Hey Bim! Guess what?"
    echo "The Shijo-Ohashi bridge is a bridge representative of Kyoto that crosses the Kamo River over Shijo Street. It is also called Gionbashi."
    [[ ! -z "$1" ]] && read -k1 -s && vim "$1"
}

# add arbitrary text to filenames before the file extension for a list of files
# TODO: make sure this works correctly
function appendTextBeforeExtension() {
    for file in "${1}"; do ext="${file##*.}"; filename="${file%.*}"; mv "$file" "${filename}${2}.${ext}"; done
}

# grabbed shamelessly from https://stackoverflow.com/a/8574392
function containsElement() {
    local e match="$1"
    shift
    for e; do [[ "$e" == "$match" ]] && return 0; done
    return 1
}

function mvlowercase() {
    if [ -n $1 ]; then
        local filepath="$1"
    else
        local filepath="*"
    fi
    for f in $filepath; do mv "$f" "$(echo "$f" | tr '[:lower:]' '[:upper:]')"; done
}

# --------------
# gpg
# --------------

# grabbed shamelessly from https://github.com/drduh/YubiKey-Guide
# does some gpg encode/decode for test files
function gpgsecret() {
  local output=~/"${1}".$(date +%s).enc
  gpg --encrypt --armor --output ${output} -r 0x0000 -r 0x0001 -r 0x0002 "${1}" && echo "${1} -> ${output}"
}

function gpgreveal() {
  local output=$(echo "${1}" | rev | cut -c16- | rev)
  gpg --decrypt --output ${output} "${1}" && echo "${1} -> ${output}"
}

# --------------
# kubernetes
# --------------

# split helm template into individual files
function splithelm() {
    if [ -z $1 ]; then
        echo "Path to a helm template file required" >&2
        return 1
    fi
    yq -s '.kind + "-" + .metadata.name' $1
    mklowercase '*.yml'
}

# make sure I base64 right the first time
function ksecret64() {
  echo -n "${1}" | base64
}

function knetworktest() {
    if [ -n "$1" ]; then
        img=$1
    else
        img='nicolaka/netshoot'
    fi
    kubectl run -it networktest-mrowland --image=$img --restart=Never --rm -- /bin/bash
}

# check aws role assumption via eks service account/oidc
function eksroletest() {
    if [ -z "$1" ]; then
        echo "requires a service account name"
    else
        kubectl run -it aws-role-test --image=amazon/aws-cli --overrides="{ \"spec\": { \"serviceAccount\": \"${1}\" }  }" --restart=Never --rm -- sts get-caller-identity
    fi
}

# print the originally applied configuration of a k8s resource
function koriginal() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Requires both an object type and an object name" >&2
        return 1
    fi
    kubectl get $1 $2 -o json | jq ".metadata.annotations.\"kubectl.kubernetes.io/last-applied-configuration\" | fromjson" | yq eval -P -e
}

# signature: ksecretval [-n namespace] secretname [...]
# prints json .data body of n named secrets in a namespace, with their values base64 decoded.
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

# print number of pods in a namespace vs number of nodes those pods are spread across
function podsVsNodes() {
    local uniqueNodes=$(kg pod -n $1 -o wide | grep -v NAME | sed 's/ \{1,\}/,/g' | sort --unique -t, -k7,7 | wc -l)
    local pods=$(kg pod -n $1 | grep -v NAME | wc -l)
    echo "Pods in Namespace: ${pods}\nNodes In Use By Namespace: ${uniqueNodes}"
}

# changes kubernetes context based on current directory (checks against subdirectories of 'kubernetes-manifests' folder on pwd)
# can take an associative array to match misnamed contexts & dirextories
# See the original gist here for more context and notes: https://gist.github.com/mrowlandfsq/7e01d75ff3b50d522c69186828db1d9d
function changeKubernetesContext() {
    # TODO: update this to use $KUBERNETES_MANIFESTS_DIRECTORY if it exists, or current pattern match
    if [[ $PWD =~ '/kubernetes-manifests/' ]]; then
        local pwdArr=($(echo $PWD | sed -e "s/\// /g"))

        local currentContext="$(kubectl config view -o jsonpath='{.current-context}')"
        local excludedContexts=( "minikube" "kind" )
        local excludedDirectories=( "eks-default" "policy" "docs" "crd_schemas" )

        # Optional: associative array to match cluster directory names to kubernetes contexts of differing names
        # Only supported in zsh, and in bash Version 4.
        #
        # Declared in .zshrc.local in this configuration
        #
        #declare -A KubernetesContextDefaultNameMap
        #KubernetesContextDefaultNameMap["colo"]="cluster.domain.local"

        local len="${#pwdArr[@]}"
        local context=""
        # grab cluster directory name from path for current context
        for ((i=0; i<$len; i++)); do
            if [[ $pwdArr[i] =~ 'kubernetes-manifests' ]]; then
                local context=$pwdArr[i+1]
                break
            fi
        done

        # if directory (context) is in excludedDirectories or excludedContexts, skip
        # if context is defined in the KubernetesContextDefaultNameMap, use that value. else use $context
        if ! containsElement $context "${excludedDirectories[@]}"; then
            if ! containsElement $currentContext "${excludedContexts[@]}"; then
                if [ -z $KubernetesContextDefaultNameMap["$context"] ]; then
                    kubectl config use-context "${context}" 1>/dev/null
                else
                    kubectl config use-context "${KubernetesContextDefaultNameMap["$context"]}" 1>/dev/null
                fi
            fi
        fi
    fi
}
