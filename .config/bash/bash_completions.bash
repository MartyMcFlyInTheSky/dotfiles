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

complete -o nospace -F __cmp_cmake cmake

__wt_completion_branches() {
	local line branch

	# Only offer branches that already have a worktree for wt navigation.
	while IFS= read -r line; do
		case "$line" in
			'branch refs/heads/'*)
				branch=${line#branch refs/heads/}
				printf '%s\n' "$branch"
				;;
		esac
	done < <(git worktree list --porcelain 2>/dev/null)
}

__wt_removable_branches() {
	local repo_root line path branch

	repo_root=$(__wt_git_root 2>/dev/null) || return 1
	while IFS= read -r line; do
		case "$line" in
			'worktree '*)
				path=${line#worktree }
				if [[ "$path" != /* ]]; then
					path=$(realpath -m "$repo_root/$path") || return 1
				fi
				;;
			'branch refs/heads/'*)
				branch=${line#branch refs/heads/}
				[[ "$path" == "$repo_root" ]] || printf '%s\n' "$branch"
				;;
		esac
	done < <(git -C "$repo_root" worktree list --porcelain 2>/dev/null)
}

__wt_local_branches() {
	git for-each-ref --format='%(refname:short)' refs/heads 2>/dev/null
}

__wt_completion_refs() {
	git for-each-ref \
		--format='%(refname:short)' \
		refs/heads refs/remotes 2>/dev/null
}

__wt_fzf_triggered() {
	local cur=${COMP_WORDS[COMP_CWORD]}
	local trigger=${FZF_COMPLETION_TRIGGER-'**'}

	# Match fzf's trigger rules while avoiding shell expression fragments.
	[[ "$cur" == *"$trigger" ]] &&
		[[ "$cur" != *'$('* ]] &&
		[[ "$cur" != *':='* ]] &&
		[[ "$cur" != *'`'* ]]
}

__wt_complete_candidates() {
	local generator=$1
	local cur=${COMP_WORDS[COMP_CWORD]}
	local candidate

	COMPREPLY=()
	while IFS= read -r candidate; do
		[[ "${candidate:0:${#cur}}" == "$cur" ]] && COMPREPLY+=("$candidate")
	done < <("$generator")
}

__wt_fzf_complete_from() {
	local prompt=$1
	local generator=$2
	shift 2

	_fzf_complete \
		--no-multi \
		--prompt="$prompt" \
		-- "$@" < <("$generator")
}

_fzf_complete_wt() {
	if __wt_fzf_triggered; then
		__wt_fzf_complete_from 'worktree> ' __wt_completion_branches "$@"
	else
		__wt_complete_candidates __wt_completion_branches
	fi
}

_fzf_complete_mkwt() {
	# The optional argument after -b is the starting ref for the new branch.
	local generator=__wt_local_branches
	local prompt='branch> '

	if [[ "${COMP_WORDS[1]}" == '-b' && $COMP_CWORD -eq 2 ]]; then
		# New branch names are free-form; do not suggest existing branches here.
		COMPREPLY=()
		return
	elif [[ "${COMP_WORDS[1]}" == '-b' && $COMP_CWORD -ge 3 ]]; then
		generator=__wt_completion_refs
		prompt='base> '
	fi

	if __wt_fzf_triggered; then
		__wt_fzf_complete_from "$prompt" "$generator" "$@"
	else
		__wt_complete_candidates "$generator"
	fi
}

_fzf_complete_rmwt() {
	local branch_index=1

	case "${COMP_WORDS[1]}" in
		-f|--force|--)
			branch_index=2
			;;
	esac

	if ((COMP_CWORD < branch_index)); then
		COMPREPLY=(-f --force --)
		return
	fi
	if ((COMP_CWORD > branch_index)); then
		COMPREPLY=()
		return
	fi

	if __wt_fzf_triggered; then
		__wt_fzf_complete_from 'worktree> ' __wt_removable_branches "$@"
	else
		__wt_complete_candidates __wt_removable_branches
	fi
}

if declare -F _fzf_complete >/dev/null 2>&1; then
	# Do not enable Bash's default fallback: it would offer filesystem paths.
	complete -F _fzf_complete_wt wt
	complete -F _fzf_complete_mkwt mkwt
	complete -F _fzf_complete_rmwt rmwt
fi

# __cmp_exec() {
#     local selected=$(find "." -maxdepth 3 ! -type d -executable | fzf --query "$curr")
#     if [[ -n "$selected" ]]; then
#         COMPREPLY=("$selected")
#     else
#         COMPREPLY=()
#     fi
# }

# Deal with empty completion differently
# complete -F __cmp_exec -E

# The -I specifier can only be used from bash 5.2 (https://stackoverflow.com/questions/79025685/bash-complete-i-invalid-option/79025820)
# if [ "${BASH_VERSINFO[0]}" -ge 5 ] && [ "${BASH_VERSINFO[1]}" -ge 0 ]; then
# 	complete -I -F __cmp_exec -o bashdefault
# fi
