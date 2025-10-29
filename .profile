# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# Set espressif paths
if [ -d "$HOME/esp/esp-idf" ] && [ -d "$HOME/.espressif" ]; then
    export PATH="$PATH:$IDF_PATH:$IDF_TOOLS_PATH"
    export IDF_PATH=~/esp/esp-idf
    export IDF_TOOLS_PATH=~/.espressif
fi

# Set pgadmin paths
if [ -d "/usr/pgadmin4/bin" ]; then
    export PATH="$PATH:/usr/pgadmin4/bin"
fi

# Set go paths
if [ -d "/usr/local/go/bin" ]; then
    export PATH=$PATH:/usr/local/go/bin
fi

if [ -n "$(go env GOPATH)" ]; then
    export PATH="$(go env GOPATH)/bin:$PATH"
fi

. "$HOME/.cargo/env"

# Read secrets
if [ -f "$HOME/.bash_secrets" ]; then
	. "$HOME/.bash_secrets"
fi

# This takes way shorter than installing the whole nvm environment
export PATH="/home/sbeer/.config/nvm/versions/node/v22.12.0/bin:$PATH"

# mm
export SSH_KEY_MM=~/.ssh/mm_gitlab

# Do this before conda
export PATH="/home/sbeer/anaconda3/bin:$PATH"

