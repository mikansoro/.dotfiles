
typeset -U path fpath

autoload -U compinit && compinit

HISTSIZE="10000"
SAVEHIST="10000"

HISTFILE="$HOME/.zsh_history"
mkdir -p "$(dirname "$HISTFILE")"

setopt HIST_FCNTL_LOCK
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_EXPIRE_DUPS_FIRST
setopt SHARE_HISTORY
unsetopt EXTENDED_HISTORY

command_exists() {
  (( $+commands[$1]))
}

function_exists() {
  (( $+functions[$1]))
}

# Functions
# ---------

# TODO: set fpath for function.zsh
# BUG: using fpath this way makes changeKubernetesContext fail to work
# fpath+=(
#   "${DOTFILES_DIRECTORY}/files/zsh/src/function.zsh"
# )
source $DOTFILES_DIRECTORY/files/zsh/src/function.zsh

# Aliases
# -------

# used for sensitive shell vars/etc that shouldn't go in git
if [ -e $HOME/.zshrc.local ]; then source $HOME/.zshrc.local; fi

source $DOTFILES_DIRECTORY/files/zsh/src/path.zsh
source $DOTFILES_DIRECTORY/files/zsh/src/alias.zsh

# Source
# -------
eval "$(starship init zsh)"
( [[ /home/michael/.nix-profile/bin/kubectl ]] || [[ /usr/bin/kubectl ]] ) && source <(kubectl completion zsh)
#export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# setup gpg-agent for ssh on fedora
# moved to .zprofile
#if cat /etc/os-release | grep "ID=fedora" > /dev/null 2>&1; then
#  if which gpg-agent > /dev/null 2>&1; then
#    export GPG_TTY=$(tty)
#    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
#    gpgconf --launch gpg-agent
#    gpg-connect-agent updatestartuptty /bye 1>/dev/null 2>&1
#  fi
#fi

