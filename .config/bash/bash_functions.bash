# Worktree navigation and creation helpers.

__wt_git_root() {
    local common_git

    # Resolve the shared Git directory so this works from linked worktrees too.
    common_git=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null) || {
        printf 'wt: not inside a Git repository\n' >&2
        return 1
    }

    common_git=$(realpath -s "$common_git") || return 1
    dirname "$common_git"
}

__wt_branch_slug() {
    printf '%s' "$1" | sed 's#[^A-Za-z0-9.-]#-#g; s#^[.-]*##; s#[.-]*$##'
}

__sbx_sandbox_name() {
    local repo_root=$1 worktree=$2 repo_name worktree_name hash

    repo_name=$(__wt_branch_slug "$(basename "$repo_root")" | tr '[:upper:]' '[:lower:]')
    worktree_name=$(__wt_branch_slug "$(basename "$worktree")" | tr '[:upper:]' '[:lower:]')
    [[ -n "$repo_name" && -n "$worktree_name" ]] || return 1

    hash=$(printf '%s\0%s' "$repo_root" "$worktree" | sha256sum | cut -c1-8) || return 1
    printf '%s-%s-%s\n' "${repo_name:0:20}" "${worktree_name:0:26}" "$hash"
}

__wt_worktree_path() {
    local repo_root repo_parent repo_name branch_slug

    repo_root=$(__wt_git_root) || return 1
    repo_parent=$(dirname "$repo_root")
    repo_name=$(__wt_branch_slug "$(basename "$repo_root")")
    branch_slug=$(__wt_branch_slug "$1")
    [[ -n "$branch_slug" ]] || {
        printf 'wt: branch produces an empty directory name: %s\n' "$1" >&2
        return 1
    }

    printf '%s/%s-worktrees/%s\n' "$repo_parent" "$repo_name" "$branch_slug"
}

__wt_find_worktree() {
    local branch=$1 line path current_branch repo_root

    repo_root=$(__wt_git_root) || return 1

    # Porcelain output preserves worktree paths and makes branch matching exact.
    while IFS= read -r line; do
        case "$line" in
            'worktree '*) path=${line#worktree } ;;
            'branch '*)
                current_branch=${line#branch }
                if [[ "$current_branch" == "refs/heads/$branch" ]]; then
                    if [[ "$path" != /* ]]; then
                        path=$(realpath -m "$repo_root/$path") || return 1
                    fi
                    printf '%s\n' "$path"
                    return 0
                fi
                ;;
        esac
    done < <(git -C "$repo_root" worktree list --porcelain 2>/dev/null)

    return 1
}

wt() {
    local target

    # Bare wt always returns to the primary worktree.
    if (($# == 0)); then
        target=$(__wt_git_root) || return 1
        cd "$target" || return 1
        return 0
    fi

    if (($# != 1)); then
        printf 'usage: wt [branch]\n' >&2
        return 2
    fi

    target=$(__wt_find_worktree "$1") || {
        printf "wt: no worktree found for branch '%s'\n" "$1" >&2
        return 1
    }

    cd "$target" || return 1
}

mkwt() {
    local create_branch=false branch base path

    if (($# == 0)); then
        printf 'usage: mkwt <branch> | mkwt -b <new-branch> [start-branch]\n' >&2
        return 2
    fi

    if [[ "$1" == '-b' ]]; then
        create_branch=true
        [[ $# -ge 2 && $# -le 3 ]] || {
            printf 'usage: mkwt -b <new-branch> [start-branch]\n' >&2
            return 2
        }
        branch=$2
        base=${3:-HEAD}
        git check-ref-format --branch "$branch" >/dev/null || return 2
    else
        [[ $# == 1 ]] || {
            printf 'usage: mkwt <branch> | mkwt -b <new-branch> [start-branch]\n' >&2
            return 2
        }
        branch=$1
        git check-ref-format --branch "$branch" >/dev/null || return 2
    fi

    # Check the path before invoking Git so an existing directory is untouched.
    path=$(__wt_worktree_path "$branch") || return 1
    if [[ -e "$path" ]]; then
        printf 'mkwt: worktree path already exists: %s\n' "$path" >&2
        return 1
    fi

    mkdir -p "$(dirname "$path")" || return 1
    if [[ "$create_branch" == true ]]; then
        git worktree add --relative-paths -b "$branch" "$path" "$base" || return 1
    else
        git worktree add --relative-paths "$path" "$branch" || return 1
    fi

    mkdir -p "$path/.nvim" || return 1
    cd "$path" || return 1
}

rmwt() {
    local force=false branch target repo_root current_dir

    if (($# == 0)); then
        printf 'usage: rmwt [-f|--force] <branch>\n' >&2
        return 2
    fi

    case "$1" in
        -f|--force)
            force=true
            shift
            ;;
        --)
            shift
            ;;
    esac

    [[ $# == 1 ]] || {
        printf 'usage: rmwt [-f|--force] <branch>\n' >&2
        return 2
    }
    branch=$1

    repo_root=$(__wt_git_root) || return 1
    target=$(__wt_find_worktree "$branch") || {
        printf "rmwt: no worktree found for branch '%s'\n" "$branch" >&2
        return 1
    }
    if [[ "$target" == "$repo_root" ]]; then
        printf 'rmwt: refusing to remove the main worktree: %s\n' "$target" >&2
        return 1
    fi

    current_dir=$(pwd -P) || return 1
    case "$current_dir" in
        "$target"|"$target"/*)
            cd "$repo_root" || return 1
            ;;
    esac

    if [[ "$force" == true ]]; then
        git worktree remove -f "$target"
    else
        git worktree remove "$target"
    fi
}

# Start the configured sandbox agent from the current Git worktree.
sbx_agent() {
    local worktree repo_root common_git sandbox_name

    command -v sbx >/dev/null 2>&1 || {
        printf 'sbx_agent: sbx is not installed\n' >&2
        return 1
    }

    worktree=$(pwd -P) || return 1
    common_git=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null) || {
        printf 'sbx_agent: not inside a Git repository\n' >&2
        return 1
    }
    repo_root=$(dirname "$common_git") || return 1
    sandbox_name=$(__sbx_sandbox_name "$repo_root" "$worktree") || return 1

    printf 'Loading sandbox %s...\n' "$sandbox_name" >&2
    sbx env run --auto-approve --name "$sandbox_name" \
        --env-arg "repository=$repo_root"
}
