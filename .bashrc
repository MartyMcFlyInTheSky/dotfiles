# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in *i*) ;;
      *) return;;
esac


# Follow xdg standard paths
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
SCRIPT_PATH=$(dirname $(realpath -s "$BASH_SOURCE[0]"))
export MY_HOME="$SCRIPT_PATH"
echo "Proprietary .bashrc: Setting xdg home to ${MY_HOME}"
export XDG_CONFIG_HOME=$MY_HOME/.config
export XDG_DATA_HOME=$MY_HOME/.local/share
export XDG_CACHE_HOME=$MY_HOME/.cache
export XDG_STATE_HOME=$MY_HOME/.local/state


# Set default visual editor to vim/nvim
if [[ -n ${SSH_CONNECTION} ]]; then
    export VISUAL="vim -Nu ${XDG_CONFIG_HOME}/vim/vimrc"
else
    export VISUAL="nvim"
fi
export EDITOR="$VISUAL"
export GIT_EDITOR="$VISUAL"

# History
# Enable multiline command preservation
# https://stackoverflow.com/questions/38817144/easy-way-to-reopen-a-command-previously-written-with-ctrlx-ctrle-in-bash
# https://askubuntu.com/questions/1133015/multiline-command-chunks-in-bash-history-into-multiple-lines
shopt -s cmdhist
shopt -s lithist
HISTTIMEFORMAT='%F %T '

if [[ -n ${SSH_USER} ]]; then
    export HISTFILE="$HOME/.history_$SSH_USER"
fi

# don't put duplicate lines or lines starting with space in the history.  # See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"


# ------ Prompt string ------

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi


# Define the colors and their RGB values
declare -A colors=(
  ["earth_yellow"]="228;178;103"
  ["ghost_white"]="247;247;253"
  ["dark_coldenrod"]="196;137;49"
  ["field_drab"]="96;74;32"
)

# Function to generate ANSI escape code for a color
get_color_txt() {
  local color_name=$1
  local rgb=${colors[$color_name]}
  echo -ne "\[\e[38;2;${rgb}m\]"
}

# Reset color
color_reset='\[\e[0m\]'

# Add git branch if it's present to PS1
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/  \1/'
}

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}'
    PS1+="$(get_color_txt earth_yellow)"'\u@\h'"${color_reset}:"
    PS1+="$(get_color_txt ghost_white)"'\w'"${color_reset}"
    PS1+="$(get_color_txt field_drab)"'$(parse_git_branch)'"${color_reset}"
    PS1+="\n$(get_color_txt earth_yellow)"' \$'"${color_reset} "
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w$(parse_git_branch)\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac



# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'



# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi



# Alias definitions.
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f "$MY_HOME/.bash_aliases" ]; then
    . "$MY_HOME/.bash_aliases"
fi

if [ -f "$MY_HOME/.bash_functions.bash" ]; then
    . "$MY_HOME/.bash_functions.bash"
fi

if [ -f "$MY_HOME/.bash_keybindings.bash" ]; then
    . "$MY_HOME/.bash_keybindings.bash"
fi

if [ -f "$MY_HOME/.bash_completions.bash" ]; then
    . "$MY_HOME/.bash_completions.bash"
fi

# Extend paths for scripts and binaries
export PATH=$MY_HOME/.local/scripts/:$MY_HOME/.local/bin:$PATH


# Install zoxide
eval "$(zoxide init bash)"

export SYSTEMD_EDITOR=vim
export FZF_DEFAULT_OPTS='--bind "alt-j:down,alt-k:up"'


# Make some adaptions based on whether we're on remote or not 
if [ -n "$SSH_CONNECTION" ]; then
    echo "SSH_CONNECTION is set to ${SSH_CONNECTION}"
    
    # Recreate bash login behaviour (https://github.com/rbenv/rbenv/wiki/Unix-shell-initialization#bash)
    # bash_login 

    # Some applications do not follow xdg standard,
    # for these we need to manually urge them to use
    # the corresponding config files
    
    # Also ssh should use the repo's config file
    alias ssh="ssh -F ${MY_HOME}/.ssh/config"

    # Use return since this script is sourced
    return
fi


# ** Everything after here is not considered on remote **

ssh-add ~/.ssh/private_github
ssh-add ~/.ssh/mm_gitlab_and_servers
ssh-add ~/.ssh/gitlab_private

export IDF_PATH=~/esp/esp-idf
export IDF_TOOLS_PATH=~/.espressif

export PATH="$PATH:/opt/nvim-linux64/bin:$IDF_PATH:$IDF_TOOLS_PATH"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/sbeer/anaconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/sbeer/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/home/sbeer/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/sbeer/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

conda activate meteomatics

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Source nomad environment
source /home/sbeer/dev/nomad-config/.envrc
