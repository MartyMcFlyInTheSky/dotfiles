
bash_login() {
    # Define an array of the files to check
    files=(~/.bash_profile ~/.bash_login ~/.profile)

    # Loop through each file in the array
    for file in "${files[@]}"; do
      # Check if the file exists
      if [ -f "$file" ]; then
        # Source the file and print a message indicating which file was sourced
        source "$file"
        echo "Sourced: $file"
        # Exit the loop after sourcing the first existing file
        break
      fi
    done
}

ssh() {
    # local host="$1"
    # echo "host = $host"
    # shift
    command ssh -t -o RemoteCommand="git -C '/tmp/sbeer/dotfiles' pull --rebase \
         || git clone https://github.com/MartyMcFlyInTheSky/dotfiles.git '/tmp/sbeer/dotfiles'; \
            bash --rcfile '/tmp/sbeer/dotfiles/.bashrc' -i" "$@"
    # command ssh -t -o RemoteCommand="echo 'Hello';bash -i" "$@"
}

tmux() {
    command tmux -f "$XDG_CONFIG_HOME/tmux/tmux.conf" -L sbeer "$@"
}

vim() {
    command vim -Nu "$XDG_CONFIG_HOME/vim/vimrc" "$@"
}

# Export overwritten functions
export -f tmux
export -f ssh
export -f vim
