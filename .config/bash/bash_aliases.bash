# TODO:
# - refactor(venv-toggle): Use the save and restore readline to show command so readline is not destoryed
# - feat(venv-toggle): work with conda as well
# - feat(task launcher): maybe allow enter to just paste command to command line (liked Ctrl-R does) and execute using f1, f2.. immediately
# - fix(task_launcher): error when not in dev repo and trying to save metainfo -> where should metainfo even be stored?

# shellcheck disable=SC2155
#
# ----- Aliases -----

# Quick open aliases
alias ba="vim ~/.bash_aliases"
alias brc="vim ~/.bashrc"
alias hist="history | tail -20"
alias hists="history | cut -d ' ' -f 6-"

alias rl="readlink -f"
alias rp="realpath"

# Git
alias gitroot='cd $(git rev-parse --show-toplevel)'
alias gits='git status'
alias gitr='git reflog --format="%C(yellow)%h%C(reset) %gs %C(green)%ad%C(reset) %C(blue)[%ar]%C(reset)"'
alias conf='git --git-dir="$HOME/.myconfig" --work-tree="$HOME"'

# Gitlab
mrstart() {
    glab api "$(glab mr view -F json | jq -r '"projects/\(.project_id)/merge_requests/\(.iid)/commits"')" |
        jq -r '.[-1] | "\(.short_id) \(.author_name) \(.title)"'
}

# Docker
alias dps='docker ps --format "{{.ID}}\t{{.Names}}"'
alias dlast='docker ps -a --format "{{.ID}}\t{{.Names}}\t{{.Status}}" | head -n 10'

# mm specific
alias cfmt='/home/sbeer/dev/cpp-components/templates/clang_format_check/clang-format-check.sh'
conanls() {
	conan graph info . --format=json 2>/dev/null |
		jq -r '.graph.nodes[] | select(.ref and .ref!="conanfile") | .ref' |
		sort -u |
		awk -F '#' '{ print $1 }'
}

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

# Toggle nvimsesh
bind -x '"\C-s":"nvimsesh"'

# Helper commands to work with readline bindings
_save_readline() {
	READLINE_LINE_OLD="$READLINE_LINE"
	READLINE_POINT_OLD="$READLINE_POINT"
	READLINE_LINE=
	READLINE_POINT=0
}

bind -x '"\204":"_save_readline"'

_restore_readline() {
	READLINE_LINE="$READLINE_LINE_OLD"
	READLINE_POINT="$READLINE_POINT_OLD"
}

bind -x '"\201":"_restore_readline"'

# Go up one directory
bind '"\eh":"\204cd ..\n\201"'

# Go to previous directory
bind '"\C-^":"\204cd - >/dev/null\n\201"'

# Rotate pushed directories
# dirstack_next() {
#     pushd +1 >/dev/null
# }
#
# dirstack_prev() {
#     pushd -0 >/dev/null
# }
# bind -x '"\202":"_save_readline; dirstack_next"'
# bind '"\ek":"\202\n\201"'
# bind -x '"\203":"_save_readline; dirstack_prev"'
# bind '"\ej":"\203\n\201"'

bind '"\C-x\C-i":"pushd "'
bind '"\C-x\C-f":"find . -type f -iname \""'
bind '"\C-xb":"\204bf ls\n\201"'
bind -x '"\C-xn":"nvr_worktree"'
bind -x '"\C-xl":"lg"'
bind -x '"\C-xo":"opencode"'

# Tune in and out of virtual python envs

toggle_virtual_env() {
	# Figure out if we're in a virtual env either activate or deactivate it
	if [[ -n "${VIRTUAL_ENV-}" ]]; then
		deactivate
	else
		if [[ ! -f ".venv/bin/activate" ]]; then
			return
		fi
		. .venv/bin/activate
	fi
	# Send siginterrupt
	kill -SIGINT $(ps -o tpgid= -p $$)
}

bind -x '"\e[1;7\x00":"toggle_virtual_env"'

# Copy current readline

copy_readline_osc52() {
	# using OSC 52
	printf "\e]52;c;%s\a" "$(printf %s "$READLINE_LINE" | openssl base64 -A)"
}

bind -x '"\e[99;6u": copy_readline_osc52'

__select_task() {
	# Start noevim as lua interpreter to extract json
	local luafile="${XDG_CONFIG_HOME-~/.config}/nvim/init.lua"

	# mapfile -d '' will terminate line at NULL byte by default
	local lines
	mapfile -d '' -t lines < <(
		nvim --headless -u "$luafile" -l /dev/stdin <<'LUA'
        local m = require("launcher")
        local tasks, metainfo, i_sel = m.read_all_tasks()

        -- Write selection as first item so we can easily parse it out
        io.stdout:write(i_sel, '\0')

        -- Write all tasks to stdout
        for _, task in ipairs(tasks) do
            io.stdout:write(task.type .. '#' .. task.label .. '#' .. task.command .. '#' .. vim.inspect(task) .. '\0') 
        end
LUA
	)
	# Get current selection
	local i_sel=${lines[0]}

	# fzf display tasks
	# Map directly into array, since storing in bash variable drops the NULL-bytes
	local fzf_out
	mapfile -d '' -t fzf_out < <(
		printf '%s\0' "${lines[@]:1}" | fzf --read0 --print0 --delimiter='#' \
			--with-nth='{2}' --sync \
			--bind "f1,f2,f3,enter:accept,start:pos($i_sel)" \
			--expect "f1,f2,f3,enter" \
			--height 40% --layout reverse --border \
			--style 'minimal' \
			--preview 'printf "%s" {4}'
		# --color 'border:#aaaaaa,label:#cccccc' \
		# --color 'preview-border:#9999cc,preview-label:#ccccff' \
		# --color 'list-border:#669966,list-label:#99cc99' \
		# --color 'input-border:#996666,input-label:#ffcccc' \
		# --color 'header-border:#6699cc,header-label:#99ccff' \
	)

	local key="${fzf_out[0]}"

	# Check if we even selected a task (can be aborted with Ctrl-c)
	if [[ -z ${fzf_out[1]} ]]; then
		return
	fi

	# Disect task into its fields. Can't use here-string since it adds newline
	local fields
	mapfile -d '#' -t fields < <(printf '%s' "${fzf_out[1]}")

	# Write build task
	TYPE="${fields[0]}" LABEL="${fields[1]%% <*>}" COMMAND="${fields[2]}" KEY="$key" \
		nvim --headless -u "$luafile" -l /dev/stdin <<'LUA'
        local m = require('launcher')

        -- Reassemble task
        local task = {
            type    = vim.fn.getenv("TYPE"),
            label   = vim.fn.getenv("LABEL"),
            command = vim.fn.getenv("COMMAND"),
        }
        m.write_selection(task, vim.fn.getenv("KEY"))
LUA

	if [[ "$key" != "enter" ]]; then
		return
	fi

	# Execute task
	local command="${fields[2]}"
	bash -c "$command"
}

__launch_task() {
	local how=$1

	# Start noevim as lua interpreter to extract json
	local luafile="${XDG_CONFIG_HOME-~/.config}/nvim/init.lua"

	# "$cfg/nvim/init_minimal.lua"
	local fields
	mapfile -d ',' -t fields < <(
		HOW="$how" nvim --headless -u "$luafile" -l /dev/stdin <<'LUA'
        local m = require("launcher")
        local how = vim.fn.getenv("HOW")
        local ok, meta = pcall(m.read_metainfo, '.vscode/task_meta.json')
        if ok then
            if meta[how] then
                io.stdout:write(meta[how].type .. ',' ..  meta[how].label .. ',' .. meta[how].command) 
            end
        end
LUA
	)

	if [[ "${#fields[@]}" == 0 ]]; then
		# Happens if no task was selected
		echo "No build task selected"
		return
	fi

	# Execute task
	local command="${fields[2]}"
	bash -c "$command"
}

# Deal with empty completion differently
complete -F __select_task -E
# bind -x '"\C-g":"__select_task"'
bind -x '"\eOP":"__launch_task f1"'
bind -x '"\eOQ":"__launch_task f2"'
bind -x '"\eOR":"__launch_task f3"'
