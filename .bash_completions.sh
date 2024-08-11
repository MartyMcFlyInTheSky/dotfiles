# Bring up history selection
__cmp_history() {
    local cur="$2"
    local prev="$3"

    local selected_command=$(history | fzf --tac --no-sort | sed 's/^[ ]*[0-9]*[ ]*//')
    if [[ -n "$selected_command" ]]; then
      COMPREPLY=( "$selected_command" )
    else
      COMPREPLY=()
    fi
}

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

    for (( i=0; i < ${#COMP_WORDS[@]}; i++)); do
      if [[ "${COMP_WORDS[i]}" == "--build" ]]; then
        if [[ $((i + 1)) -lt ${#COMP_WORDS[@]} ]]; then
          build_dir="${COMP_WORDS[i + 1]}"
        fi
        break
      fi 
    done

    local target=$(cmake --build "$build_dir" --target help 2>/dev/null | awk '/^[a-zA-Z0-9_-]+:/ {print $1}' | sed 's/://' | fzf --query "$cur")

  if [[ -n "$target" ]]; then
    COMPREPLY=( "$target" )
  else
    COMPREPLY=()
  fi
}


__cmp_exec() {
    local curr="$2"
    case "$curr" in
        ./*)
            local selected=$(find "." ! -type d -executable | fzf --query "$curr")
        if [[ -n "$selected" ]]; then
            COMPREPLY=( "$selected" )
        else
            COMPREPLY=()
        fi
    esac
}


complete -I -F __cmp_exec -o bashdefault

complete -o nospace -F __cmp_cmake cmake

complete -F __cmp_history -E
complete -F __cmp_exec bash


