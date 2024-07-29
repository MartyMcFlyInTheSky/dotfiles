alias rl="readlink -f"
alias gitroot='cd $(git rev-parse --show-toplevel)'
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
alias lg='ls -alF | grep'

# Use nvim by default
# alias vim='nvim'


# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

alias rgf='rg --files | rg'
alias config='/usr/bin/git --git-dir=/home/sbeer/.myconfig/ --work-tree=/home/sbeer'
alias cdf='cd $(find . -type d -print | fzf)'
alias pg='ps aux | grep'

alias cd='z'
