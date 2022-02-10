
# GPG SSH Agent Setup
if which gpg-agent; then
  export GPG_TTY="$(tty)"
  export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  gpgconf --launch gpg-agent

  # is this still needed?
  # if cat /etc/os-release | grep "ID=fedora"; then
  #   gpg-connect-agent updatestartuptty /bye 1>/dev/null 2>&1
  # fi
fi
