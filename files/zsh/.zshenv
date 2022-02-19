if command -v emacsclient 1>/dev/null 2>&1; then
  if [[ ! -z $INSIDE_EMACS ]]; then
    export VISUAL="$(command -v emacsclient)"
    export EDITOR="$(command -v emacsclient)"
  else
    export VISUAL="$(command -v emacsclient) -c"
    export EDITOR="$(command -v emacsclient) -nw"
  fi
else
  export EDITOR="$(command -v vim 1>/dev/null 2>&1 || command -v vi)"
  export VISUAL=$EDITOR
fi
export SUDO_EDITOR=$EDITOR

if [ -f $HOME/.zshenv.local ]; then
  # more info on how this works here: https://gist.github.com/mihow/9c7f559807069a03e302605691f85572
  export $(cat $HOME/.zshenv.local | sed 's/#.*//g' | sed 's/\r//g' | xargs)
fi

# check if macos, set $MACOS
if [[ `uname` == "Darwin" ]]; then
  export MACOS=1
fi
