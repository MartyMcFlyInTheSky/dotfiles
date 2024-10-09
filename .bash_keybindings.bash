
bind -x '"\C-f": "tmux-sessionizer.sh"'
# rotate_cwd() {
#     # exec $SHELL
#     echo "dirstack entries = ${#DIRSTACK[@]}"
#     while (( ${#DIRSTACK[@]} )); do
#         pushd "$1" &>/dev/null
#         if [[ $? -eq 0 ]]; then
#             break
#         else
#             popd &>/dev/null
#         fi
#     done
#     refresh
#     # No direct equivalent to `redraw-prompt`, but you can reset PS1
#     ##  /usr/bin/cd $PWD
# }
#
cd_back() {
    pushd .. &>/dev/null
}

cd_forward() {
    popd +0 &>/dev/null
}

# bind -x '"\201": cd_forward'
# bind -x '"\202": cd_back'
# bind '"\C-j": "\201\C-m"' 
# bind '"\C-k": "\202\C-m"' 

