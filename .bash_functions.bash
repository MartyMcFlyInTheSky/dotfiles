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
	if [ "$#" -gt 1 ]; then
		command ssh "$@"
	else
		local remote_command=$(
			cat <<-'EOF'
				            DOTFILES_DIR=~/test/sbeer/dotfiles
				            if [[ -d "${DOTFILES_DIR}" ]]; then
				                git -C "${DOTFILES_DIR}" pull --rebase
				            else
				                mkdir -p "${DOTFILES_DIR}"
				                git clone 'https://github.com/MartyMcFlyInTheSky/dotfiles.git' "${DOTFILES_DIR}"
				            fi
				            bash --rcfile "${DOTFILES_DIR}/.bashrc" -i
			EOF
		)
		command ssh -t -o "RemoteCommand=$remote_command" "$@"
	fi
}

tmux() {
	command tmux -f "$XDG_CONFIG_HOME/tmux/tmux.conf" -L sbeer "$@"
}

# Export overwritten functions
export -f tmux
export -f ssh
