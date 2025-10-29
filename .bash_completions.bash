# Complete --target of cmake command
__cmp_cmake() {
	local cur="$2"
	local prev="$3"

	if [[ "$prev" != "--target" ]]; then
		return 1
	fi

	local currdir=${PWD##*/}
	currdir=${currdir:-/}

	# Scan the line for build directory
	local build_dir="build"
	if [[ "$currdir" == "build" ]]; then
		build_dir="."
	fi

	for ((i = 0; i < ${#COMP_WORDS[@]}; i++)); do
		if [[ "${COMP_WORDS[i]}" == "--build" ]]; then
			if [[ $((i + 1)) -lt ${#COMP_WORDS[@]} ]]; then
				build_dir="${COMP_WORDS[i + 1]}"
			fi
			break
		fi
	done

	local target=$(cmake --build "$build_dir" --target help 2>/dev/null | awk '/^[a-zA-Z0-9_-]+:/ {print $1}' | sed 's/://' | fzf --query "$cur")

	if [[ -n "$target" ]]; then
		COMPREPLY=("$target")
	else
		COMPREPLY=()
	fi
}

__cmp_exec() {
    local selected=$(find "." -maxdepth 3 ! -type d -executable | fzf --query "$curr")
    if [[ -n "$selected" ]]; then
        COMPREPLY=("$selected")
    else
        COMPREPLY=()
    fi
}

# Deal with empty completion differently
complete -F __cmp_exec -E

# The -I specifier can only be used from bash 5.2 (https://stackoverflow.com/questions/79025685/bash-complete-i-invalid-option/79025820)
# if [ "${BASH_VERSINFO[0]}" -ge 5 ] && [ "${BASH_VERSINFO[1]}" -ge 0 ]; then
# 	complete -I -F __cmp_exec -o bashdefault
# fi

complete -o nospace -F __cmp_cmake cmake

