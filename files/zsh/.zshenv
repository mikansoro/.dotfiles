export PATH="$HOME/.dotfiles/scripts:$HOME/.local/bin:$PATH"
export EDITOR="emacsclient -c"
export VISUAL="emacsclient -c"

# TODO: import .zshenv.local somehow into env vars
if [ ! -f ~/.zshenv.local ]; then
  # more info on how this works here: https://gist.github.com/mihow/9c7f559807069a03e302605691f85572
  export $(cat .zshenv.local | sed 's/#.*//g' | sed 's/\r//g' | xargs)
fi
