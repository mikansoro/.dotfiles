typeset -U -g PATH path

mkdir -p $HOME/bin

macpaths=()

# TODO: update to use $MACOS var & add to path smarter
if [ $MACOS ]; then
  # homebrew db client workaround
  macpaths=(
   "/usr/local/opt/libpq/bin"
   "/usr/local/opt/mysql-client/bin"
  )
fi

path=(
  "${DOTFILES}/scripts"

  "${HOME}/bin"
  "${HOME}/.local/bin"

  "${HOME}/go/bin"
  "${KREW_ROOT:-$HOME/.krew}/bin"

  "$macpaths[@]"

  "$path[@]"
)

# prune paths that don't exist
path=($^path(N))
