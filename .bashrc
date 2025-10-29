# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in *i*) ;;
*) return ;;
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
# export XDG_RUNTIME_DIR=$MY_HOME/.local/share # This is needed for wezterm daemon pid file allocation

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# -----------------------------------------------------------------------------
# VIM
# -----------------------------------------------------------------------------

function vim() {
    # Set default visual editor to vim/nvim
    # if [[ -n ${SSH_CONNECTION} ]]; then
    # command vim -Nu ${XDG_CONFIG_HOME}/vim/vimrc -c "normal '0" "$@"
    # command vim -Nu ${XDG_CONFIG_HOME}/vim/vimrc "$@"
    # else
    command nvim "$@"
    # fi
}
export -f vim

export VISUAL="nvimsesh"
export EDITOR="$VISUAL"
export SYSTEMD_EDITOR="$VISUAL"
export GIT_EDITOR="$VISUAL"

# -----------------------------------------------------------------------------
# History
# -----------------------------------------------------------------------------

# Enable multiline command preservation
# https://stackoverflow.com/questions/38817144/easy-way-to-reopen-a-command-previously-written-with-ctrlx-ctrle-in-bash
# https://askubuntu.com/questions/1133015/multiline-command-chunks-in-bash-history-into-multiple-lines
shopt -s cmdhist
shopt -s lithist
# append to the history file instead of overwriting
shopt -s histappend

if [[ -n ${SSH_USER} ]]; then
	export HISTFILE="$HOME/.history_$SSH_USER"
fi

# Adapted from https://chemnitzer.linux-tage.de/2025/de/programm/beitrag/296
# don't put duplicate lines or track lines starting with space in the history.  # See bash(1) for more options
HISTCONTROL=ignoreboth
# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=30000          # default 1000
HISTFILESIZE=90000      # default 2000
HISTTIMEFORMAT='(%d.%m.%y) ' # default '%F %T ' 
HISTIGNORE="?:??:???:git status:gits:bash:clear:exit:man*:*--help"

# Don't use PROMPT_COMMAND since it would interfere with the implicitely used
# preexec and precmd from wezterm (check /etc/profile.d/wezterm.sh for details)
__append_reload_history() {
    history -a # append
    history -n # load new entries from histfile
}
precmd_functions+=(__append_reload_history)


# -----------------------------------------------------------------------------
# Prompt string
# -----------------------------------------------------------------------------

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
	debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
xterm-color | *-256color) color_prompt=yes ;;
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

# Add git branch if it's present to PS1
__parse_git_branch() {
	git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/  \1/'
}

# Right-aligned clock
__rclock() {
  # what to show (plain text length matters)
  local template=$1
  local text=$2

  # terminal width; Bash keeps $COLUMNS up to date on resize
  local cols=${COLUMNS:-$(tput cols)}

  # position: last column minus visible length of TEXT (no color)
  local col=$(( cols - ${#text} + 1 ))
  (( col < 1 )) && col=1

  # save cursor, move to target column in current row, print, restore cursor
  local text_colored=$(printf "$template" "$text")
  printf '\e7\e[%dG%s\e8' "$col" "$text_colored"
}

__fg_rgb() { printf '\[\e[38;2;%d;%d;%dm\]' "$1" "$2" "$3"; }  # R G B
__bg_rgb() { printf '\[\e[48;2;%d;%d;%dm\]' "$1" "$2" "$3"; }
__rst()    { printf '\[\e[0m\]'; }

# Static color palette
__c_earth_yellow="$(__fg_rgb 228 178 103)"
__c_ghost_white="$(__fg_rgb 247 247 253)"
__c_dark_coldenrod="$(__fg_rgb 196 137 49)"

__crst="$(__rst)"
__c_error=(176 63 81)
__c_topaz=(65 224 209)
__c_dark_slate_blue=(0 54 82)
__c_light_yellow_green=(222 253 131)
__c_field_drab=(96 74 32)
__c_gray=(128 128 128)

# Static elements
__ps_rclock="$(__fg_rgb ${__c_gray[@]})%s${__crst}"
__ps_pyvenv="\e[7m$(__fg_rgb ${__c_topaz[@]})%s\e[27m${__crst}"
__ps_arrwx="$(__fg_rgb ${__c_topaz[@]})$(__bg_rgb ${__c_dark_slate_blue[@]})${__crst}"
__ps_cwd1="$(__fg_rgb 255 255 255)$(__bg_rgb ${__c_dark_slate_blue[@]}) \w ${__crst}"
__ps_cwd2="$(__fg_rgb ${__c_light_yellow_green[@]})$(__bg_rgb ${__c_dark_slate_blue[@]}) \w ${__crst}"
__ps_arrwxx="$(__fg_rgb ${__c_dark_slate_blue[@]})${__crst}"
__ps_branch="$(__fg_rgb ${__c_gray[@]})%s ${__crst}"
__ps_prompt1="$(__fg_rgb ${__c_light_yellow_green[@]})  ${__crst}"
__ps_prompt2="$(__fg_rgb ${__c_error[@]})  ${__crst}"

__evaluate_ps1() {
    local exitcode=$?

    # PS1 dynamic elements

    local rclock="$(__rclock "$__ps_rclock" "$(date '+%H:%M:%S')")"   # change format if you like

    # Redefine prompt color if last command failed
    if [[ "$exitcode" != 0 ]]; then
        local prompt=$__ps_prompt2
    else
        local prompt=$__ps_prompt1
    fi

    local pyvenv=$(printf "$__ps_pyvenv" "${VIRTUAL_ENV_PROMPT+" $VIRTUAL_ENV_PROMPT "}")

    # Make projects in ~/dev visually pop
    if [[ "$(dirname "$PWD")" == ~/dev ]]; then
        local cwd=$__ps_cwd2
    else
        local cwd=$__ps_cwd1
    fi

    local branch="$(printf "$__ps_branch" "$(__parse_git_branch)")"

    PS1="${rclock}${pyvenv}${__ps_arrwx}${cwd}${__ps_arrwxx}${branch}\n${prompt}"
}


if [ "$color_prompt" = yes ]; then
    precmd_functions+=(__evaluate_ps1)
else
    # static
	PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w$(parse_git_branch)\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm* | rxvt*)
	PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
	;;
*) ;;
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


# zoxide integration
eval "$(zoxide init bash)"

# fzf integration

export FZF_DEFAULT_OPTS="
--style minimal
--bind 'ctrl-/:change-preview-window(down|hidden|)'
--bind 'ctrl-d:preview-down,ctrl-u:preview-up'"

# export FZF_CTRL_T_OPTS="
# --walker-skip .git,node_modules,target
# --preview 'if file {} | grep -i 'text'; then head -100 {}; fi'
# --multi"

export FZF_ALT_C_OPTS="
--walker-skip .git,node_modules,target
--preview 'tree -C -L 2 {}'"

eval "$(fzf --bash)"

# wezterm integration
# (enabled by default by /etc/profile.d/wezterm.sh)


# Alias definitions.
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f "$MY_HOME/.config/bash/.bash_aliases" ]; then
	. "$MY_HOME/.config/bash/.bash_aliases"
fi

if [ -f "$MY_HOME/.config/bash/.bash_functions.bash" ]; then
	. "$MY_HOME/.config/bash/.bash_functions.bash"
fi

if [ -f "$MY_HOME/.config/bash/.bash_completions.bash" ]; then
	. "$MY_HOME/.config/bash/.bash_completions.bash"
fi

# Extend paths for scripts and binaries
export PATH=$MY_HOME/.local/scripts/:$MY_HOME/.local/bin:$PATH


# Conda init for current shell depending on if we're in remote or local context
if [[ -n "${SSH_CONNECTION}" ]]; then
	echo "SSH_CONNECTION is set to ${SSH_CONNECTION}"

	# Also ssh should use the repo's config file
	alias ssh="ssh -F ${MY_HOME}/.ssh/config"

	# >>> conda initialize >>>
	# !! Contents within this block are managed by 'conda init' !!
	__conda_setup="$('/home/process/software/miniconda3/bin/conda' 'shell.bash' 'hook' 2>/dev/null)"
	if [ $? -eq 0 ]; then
		eval "$__conda_setup"
	else
		if [ -f "/home/process/software/miniconda3/etc/profile.d/conda.sh" ]; then
			. "/home/process/software/miniconda3/etc/profile.d/conda.sh"
		else
			export PATH="/home/process/software/miniconda3/bin:$PATH"
		fi
	fi
	unset __conda_setup
	# <<< conda initialize <<<
else
    # Disable software flow control XON/XOFF
    stty -ixon

    # Disable CAPSLOCK, remap to VoidSymbol
    setxkbmap -option caps:none

	ssh-add ~/.ssh/private_github
	ssh-add ~/.ssh/mm_gitlab
	ssh-add ~/.ssh/gitlab_private

	export PATH="$PATH:/opt/nvim-linux64/bin"

	eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

	# Source nomad environment
	source /home/sbeer/dev/nomad-config/.envrc

    # Source node manager
    export NVM_DIR="$HOME/.config/nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
fi
