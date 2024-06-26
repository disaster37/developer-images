#!/bin/bash

# Ensure $HOME exists when starting
if [ ! -d "${HOME}" ]; then
  mkdir -p "${HOME}"
fi

# Setup $PS1 for a consistent and reasonable prompt
if [ -w "${HOME}" ] && [ ! -f "${HOME}"/.bashrc ]; then
  echo "PS1='[\u@\h \W]\$ '" > "${HOME}"/.bashrc
fi

# Add current (arbitrary) user to /etc/passwd and /etc/group
if ! whoami &> /dev/null; then
  if [ -w /etc/passwd ]; then
    echo "${USER_NAME:-user}:x:$(id -u):0:${USER_NAME:-user} user:${HOME}:/bin/bash" >> /etc/passwd
    echo "${USER_NAME:-user}:x:$(id -u):" >> /etc/group
  fi
fi

# Copy and load certificats if path exist
EXTRA_CERTICATE_PATH=/public-certs
if [ -d $EXTRA_CERTICATE_PATH ]; then
    sudo cp $EXTRA_CERTICATE_PATH/*.crt /usr/share/pki/ca-trust-source/anchors/
    sudo update-ca-trust
fi

exec "$@"
