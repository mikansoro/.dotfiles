
if [ -f $HOME/.zshenv.local ]; then
  # more info on how this works here: https://gist.github.com/mihow/9c7f559807069a03e302605691f85572
  export $(cat $HOME/.zshenv.local | sed 's/#.*//g' | sed 's/\r//g' | xargs)
fi

# check if macos, set $MACOS
if [[ `uname` == "Darwin" ]]; then
  export MACOS=1
fi
