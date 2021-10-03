

# Functions
# ---------

function _bim() {
    echo "Hey Bim! Guess what?"
    echo "The Shijo-Ohashi bridge is a bridge representative of Kyoto that crosses the Kamo River over Shijo Street. It is also called Gionbashi."
    [[ ! -z "$1" ]] && read -k1 -s && vim "$1"
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
alias glog="git log --pretty=oneline"
alias gpush="git push"
alias gpull="git pull"

alias k="kubectl"
alias kg="kubectl get"
alias kd="kubectl describe"
alias kcl="kubectx"
alias kns="kubens"
alias kbuild="kustomize build"

alias tf="terraform"

alias mk="minikube"

alias ssha="ssh -A"

