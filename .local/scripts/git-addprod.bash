#!/bin/bash

url="$1"

# TODO:
# - Proper code generation and checks for lua with treesitter (?)
# - Bash regex decomposition in one line
# - rmprod functionality
# - jumphost support to enable jumping to ncm
# - bash with the right rc should be instantiated on the other side

# Setup repository on remote. For this we parse the url and go to the
# server to initialize the git directory with denyCurrentBranch

# Input sanitization

if ! [[ $url =~ ^([_[:alnum:]]+)@([_[:alnum:].]+):([_[:alnum:]/-]+) ]]; then
    echo -e "\e[31mError: URL has unexpected format, coulnd't decompose!\e[0m"
    exit 1
fi
user=${BASH_REMATCH[1]} 
host=${BASH_REMATCH[2]} 
path=${BASH_REMATCH[3]} 

# Determine the name of the configuration
if ! [[ $host =~ ^([_[:alnum:]]+)(.[_[:alnum:].]+)* ]];then
    echo -e "\e[31mCouldn't extract proper name for domain_file\e[0m"
    exit 1
fi
config_name=${BASH_REMATCH[1]}

echo -e "Adding configuration '$config_name' for:\n\tuser: $user\n\thost: $host\n\tpath: $path"


ssh "$user@$host" /bin/bash << EOF
    if [[ ! -d $path ]]; then
        echo "Creating new upstream repository in $path.."
        set -e
        mkdir -p $path && cd $path
        echo "executing git init in $path"
        git init >/dev/null
        git config --local receive.denyCurrentBranch updateInstead
        echo -e "\e[32mSuccessfully created new upstream repository\e[0m"
    else
        echo -e "\e[33mNoop: Upstream already in place on host '$host'\e[0m"
    fi
EOF
if [[ $? != 0 ]]; then
    echo "Error running command on host $host"
    exit 1
fi


# Insert the remote into our local git configuration if not already present.
# NOTE: The git aliases (in which this shell script is supposed to be run)
# will always be executed from the git root.

# Extract main (fetch) url from origin if available (otherwise garbage)
remote_name="prod"
remote_url="garbage"
primary_remote_name=$(git remote)
if [[ -n "$primary_remote_name" && "$remote_name" != "$primary_remote_name" ]]; then
    remote_url=$(git remote get-url "$primary_remote_name")
fi

# Add custom remote if not available
if ! git remote -v | grep -w "$remote_name" >/dev/null; then
    git remote add "$remote_name" "$remote_url"
    git remote set-url --add --push "$remote_name" "$url"
    echo -e "\e[32mAdded new remote 'remote_name'with push url '$url'\e[0m"
else
    if ! git remote -v | awk '$3 == "(push)" { print $2 }' | grep -w $url >/dev/null; then
        git remote set-url --add --push "$remote_name" "$url"
        echo -e "\e[32mSuccessfully added new push url '$url' for remote '$remote_name'\e[0m\""
    else
        echo -e "\e[33mNoop: Url has already been added to git remote '$remote_name'\e[0m"
    fi
fi

# Generate some lua code
wezterm_domains_file="$HOME/.config/wezterm/ssh_domains.lua"

# Check if the entry is already there
if grep -w "name = 'SSHMUX:${config_name}'" "$wezterm_domains_file" >/dev/null; then
    echo -e "\e[33mNoop: Config for $config_name has already been added to wezterm the domain file \e[0m"
else
    # Find configuration insert place
    lineno=$(grep -n 'AUTO GENERATED' "$wezterm_domains_file" | head -n 1 | awk -F: '{ print $1 }')
    if [[ -z "$lineno" ]]; then
        # Nothing emitted
        echo -e "\e[31mCouldn't find place to insert in $wezterm_domains_file\e[0m"
        exit 1
    fi
    # Add some text
    sed -i "${lineno}r /dev/stdin" "$wezterm_domains_file" >/dev/null << EOF
    {
        name = 'SSHMUX:${config_name}',
        remote_address = '${host}',
        username = '${user}',
        remote_wezterm_path = "${path%/}/.local/bin/wezterm"
    },
EOF
    echo -e "\e[32mSuccessfully added configuration to wezterm domain_file!\e[0m"
fi

