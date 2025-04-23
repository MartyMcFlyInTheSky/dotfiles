# ----- Aliases -----

# Quick open aliases
alias ba="vim ~/.bash_aliases"
alias brc="vim ~/.bashrc"
alias vk="vim ~/.config/nvim/lua/config/keybindings.lua"
alias vak="vim ~/.config/vim/keybindings.vim"
alias vo="vim ~/.config/nvim/lua/config/settings.lua"
alias wez="vim ~/.config/wezterm/wezterm.lua"

alias rl="readlink -f"
alias rp="realpath"

# Git
alias gitroot='cd $(git rev-parse --show-toplevel)'
alias config='/usr/bin/git --git-dir=/home/sbeer/.myconfig/ --work-tree=/home/sbeer'
alias lazyconfig='lazygit --git-dir=/home/sbeer/.myconfig/ --work-tree=/home/sbeer'

# mm specific
alias cfmt='/home/sbeer/dev/cpp-components/templates/clang_format_check/clang-format-check.sh'

function lg { ll | grep $1; }

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
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

# Some common greps
alias lg='ls -alF | grep -i'
alias cg='crontab -l | grep -i'
alias pg='ps aux | grep -i'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

alias rgf='rg --files | rg'

# Some stuff I picked up on the internet
alias please='sudo !!'
alias cl='clear'
alias rr='curl -s -L https://raw.githubusercontent.com/keroserene/rickrollrc/master/roll.sh | bash'
alias update='sudo apt-get update && sudo apt-get upgrade'

# Copy using osc52 copy command
# alias cpy='echo -en "\x1b]52;c;$(base64 -w0 -)\x07"'
alias cpy='xclip -selection clipboard'

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

dirstack_next() {
    pushd +1 >/dev/null
}

dirstack_prev() {
    pushd -0 >/dev/null
}

# Restore cl is universal
bind -x '"\201":"_restore_command_line"'

# Go up one directory
bind -x '"\204":"_save_command_line; cd .."'
bind '"\eh":"\204\n\201"'
# Rotate pushed directories
bind -x '"\202":"_save_command_line; dirstack_next"'
bind '"\ek":"\202\n\201"'
bind -x '"\203":"_save_command_line; dirstack_prev"'
bind '"\ej":"\203\n\201"'

# Better ls -al
bind -x '"\el":"echo; command ls -lAtr"'

# Show newest 10 files in a folder
bind -x '"\eu":"echo; command ls -1U | head"'

# Terminal reset shortkey
bind -x '"\205":"reset"'
bind '"\C-x\C-i":"pushd "'
bind '"\C-x\C-f":"find . -type f -iname \""'

