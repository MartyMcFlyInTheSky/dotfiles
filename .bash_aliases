
# ----- Aliases -----

# For ourselves
alias ba="vim ~/.bash_aliases"
alias brc="vim ~/.bashrc"
alias rl="readlink -f"

# Git
alias gitroot='cd $(git rev-parse --show-toplevel)'
alias config='/usr/bin/git --git-dir=/home/sbeer/.myconfig/ --work-tree=/home/sbeer'

function lg { ll | grep $1; }

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias lg='ls -alF | grep'

# Use nvim by default
# alias vim='nvim'


# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

alias rgf='rg --files | rg'
alias pg='ps aux | grep'

# Some stuff I picked up on the internet
alias please='sudo !!'
alias cl='clear'
alias rr='curl -s -L https://raw.githubusercontent.com/keroserene/rickrollrc/master/roll.sh | bash'
alias update='sudo apt-get update && sudo apt-get upgrade'

# Copy using osc52 copy command
# alias cpy='echo -en "\x1b]52;c;$(base64 -w0 -)\x07"'
alias cpy='xclip -selection clipboard'

chdir() {
    mkdir -p "$1"
    cd "$1"
}

alias v='nvim'


# ----- Keybindings -----


# Helper commands to work with readline bindings
_save_command_line() {
   READLINE_LINE_OLD="$READLINE_LINE"
   READLINE_POINT_OLD="$READLINE_POINT"
   READLINE_LINE=
   READLINE_POINT=0
}

_restore_command_line() {
   READLINE_LINE="$READLINE_LINE_OLD"
   READLINE_POINT="$READLINE_POINT_OLD"
}

pushup() {
    pushd .. &>/dev/null
}

popdown() {
    popd +0 &>/dev/null
}

# Restore cl is universal
bind -x '"\201":"_restore_command_line"'

# Bind pushd / popd
bind -x '"\202":"_save_command_line; pushup"'
bind '"\ek":"\202\n\201"'
bind -x '"\203":"_save_command_line; popdown"'
bind '"\ej":"\203\n\201"'

# Better fuzzy find over command output
#bind -x '"\ep":"READLINE_LINE=$(eval ${READLINE_LINE} | fzf --exact); READLINE_POINT=0"'

# Better cd <subdir>
# bind -x '"\C-x\C-o":"_save_command_line; cd $(find . -maxdepth 1 -type d | fzf)"'
# bind '"\ej":"\C-x\C-o\n\C-x\C-r"'

# Better ls -al
bind -x '"\el":"ls -latr"'
