#!/bin/bash

#
CRITICAL_PATH_COMPONENT="/sbeer/"
#
# TODO:
# - Consistent naming
# - Better regex parse for netloc so it works also with git@...


# Exit on error
set -e

###### FUNCTION DEFINITIONS ######

read_git_remotes() {
    # Make sure GIT_DIR has been set by the upstream git alias executor because
    # that's probably what we wanted
    if [[ -z "$GIT_DIR" ]]; then
        echo "ERROR: Please point GIT_DIR environment variable to reference repo!" 
        return 1
    fi

    # Map all git push urls into a bash array
    mapfile -t urls < <(git config --local --get-all remote.origin.pushurl)

    # Regex-disect urls and populate json
    out="{}"
    if [[ -z "$urls" ]]; then # Prevents empty line reading
        echo "$out"
    fi

    for url in ${urls[@]}; do
        if ! [[ $url =~ ^([_[:alnum:]]+)@([_[:alnum:].]+):([_[:alnum:]/-]+) ]]; then
            echo "Error: Couldn't decompose URL, URL has unexpected format: $url!" >&2
            return 1
        fi

        user=${BASH_REMATCH[1]} 
        host=${BASH_REMATCH[2]} 
        path=${BASH_REMATCH[3]} 

        # Construct json
        out="$(jq \
            --arg host "$host" \
            --arg user "$user" \
            --arg path "$path" \
            '. + { ($host) : { "user": $user, "path": $path | sub("/+$"; "") } }' \
        <<< "$out")"
    done

    echo "$out"
}


read_wezterm_ssh_domains() {
    local domains_filepath=$1
    local repo_toplevel_name=$2

    # Check if file exists, otherwise return empty
    if [[ ! -f "$domains_filepath" ]]; then
        jq -n '{}'
        return 1
    fi

    lua - "$domains_filepath" "$repo_toplevel_name" << 'EOF'
        -- Put path to module file on package path
        local domains_filepath = arg[1]
        local toplevel_repo_name = arg[2]

        local dir, mod_name = domains_filepath:match("^(.-)/?([^/]+)%.lua$")
        package.path = dir .. "/?.lua;" .. package.path

        local ssh_domains = require(mod_name).ssh_domains

        -- Requires `luarocks install json-lua` (do not mistake for lua-json!)
        JSON = require("JSON")

        curr_domains = {}
        for i, data in ipairs(ssh_domains) do
            -- Parse hostname
            local hostname = string.match(data["name"], "^[^:]+:(.+)$") -- takes care of SSHMUX:-prefix
            local path = string.match(data["remote_wezterm_path"], "^(.-/" .. toplevel_repo_name .. ")")
            local user = data["username"]

            curr_domains[hostname] = {
                path = path,
                user = user
            }
        end 

        -- NOTE: Since lua only understands tables and the JSON module opts for [] instead of {} on empty
        -- we rewrite that as {} with our knowledge..
        local pretty_json = JSON:encode_pretty(curr_domains)
        if pretty_json == "[]" then
            pretty_json = "{}"
        end
        print(pretty_json)
EOF
}



update_host() {
    local hostname="$1"
    local old="$2"
    local new="$3"
    local force="$4" # Enforces the state on servers even if nothing apparently changed

    add_host() {
        local hostname="$1"
        local info="$2"

        echo "Adding new host $hostname"

        local user="$(jq -r '.user' <<< "$new")"
        local path="$(jq -r '.path' <<< "$new")"

        ssh -o ConnectTimeout=5 "$user@$hostname" /bin/bash << EOF || [[ -n "$force" ]]
            set -e
            if [[ -d "$path" ]]; then
                echo -e "Error: Path already exists" 
                exit 1
            fi
            # Check that we don't create a path without the safety component
            if [[ "$path" != *"$CRITICAL_PATH_COMPONENT"* ]]; then
                echo -e "Error: Aborting because path doesn't contain critical component"
                exit 1
            fi
            # Add new repository
            echo "Adding new repository $path now..."
            mkdir -p $path
            cd $path # don't use && as this will cancel set -e
            git init >/dev/null 2>&1
            git config --local receive.denyCurrentBranch updateInstead
            echo "Successfully created new upstream repository!"
EOF
    }

    remove_host() {
        local hostname="$1"
        local info="$2"

        echo "Removing host $hostname"

        local user="$(jq -r '.user' <<< "$old")"
        local path="$(jq -r '.path' <<< "$old")"

        ssh -o ConnectTimeout=5 "$user@$hostname" /bin/bash << EOF || [[ -n "$force" ]]
            set -e
            if [[ ! -d $path ]]; then
                echo -e "Error, path doesn't exists"
                exit 1
            fi
            # Before we remove the path make sure that it contains safety component
            if [[ "$path" != *"$CRITICAL_PATH_COMPONENT"* ]]; then
                echo -e "Error, refusing to remove directory that doesn't contain safety component!"
                exit 1
            fi
            # Remove the repository
            echo -e "Removing path $path now..."
            rm -rf "$path"
            # Try deleting empty parent folder
            rmdir "$(dirname "$path")" 2>/dev/null || true
            echo "Successfully removed repo $path!"
EOF
    }

    move_repo() {
        local hostname="$1"
        local old="$2"
        local new="$3"

        echo "Moving repo on host $hostname"

        local new_user="$(jq -r '.user' <<< "$new")"
        local new_path="$(jq -r '.path' <<< "$new")"

        local old_user="$(jq -r '.user' <<< "$old")"
        local old_path="$(jq -r '.path' <<< "$old")"

        ssh -o ConnectTimeout=5 "$new_user@$hostname" /bin/bash << EOF
            set -e
            if [[ ! -d "$old_path" ]]; then
                echo "Error, old path doesn't exists"
                exit 1
            fi
            # Before we move the path make sure that it contains safety component
            if [[ "$old_path" != *"$CRITICAL_PATH_COMPONENT"* || "$new_path" != *"$CRITICAL_PATH_COMPONENT"* ]]; then
                echo "Error, refusing to move from/to directory that doesn't contain safety component!"
                exit 1
            fi
            # Relocate repo folder
            echo "Moving path $old_path to $new_path..."
            mkdir -p "$(dirname "$new_path")"
            mv "$old_path" "$new_path"
            # Try deleting empty parent folder
            rmdir "$(dirname "$old_path")" 2>/dev/null || true
            echo "Successfully moved path $old_path to $new_path"
EOF
    }

    echo "Updating host $hostname"

    sleep 1

    if [[ -n "$old" ]]; then
        if [[ -n "$new" ]]; then
            # Check if something actually changed
            local status=0
            jq -n -e --argjson old "$old" --argjson new "$new" '$old == $new' || status=$?

            if [[ "$status" == 0 && -z "$force" ]]; then
                echo "Old and new unchanged"
                echo -e "[[\033[34m=\033[0m]]" && return 0
            fi

            # Check if we can move the repo around which is the case if the username stayed and only
            # the path changed (otherwise we might run into permission issues)
            local new_user="$(jq -r '.user' <<< "$new")"
            local old_user="$(jq -r '.user' <<< "$old")"

            # For force="true" we always update by removing and adding seperately
            if [[ "$new_user" == "$old_user" && -z "$force" ]]; then
                move_repo "$hostname" "$old" "$new"
            else
                remove_host "$hostname" "$old" || [[ -z "$force" ]]
                add_host "$hostname" "$new" || [[ -z "$force" ]]
            fi
            
            echo -e "[[\033[33m~\033[0m]]" && return 0
        else
            remove_host "$hostname" "$old" || [[ -z "$force" ]]
            echo -e "[[\033[35m-\033[0m]]" && return 0
        fi
    elif [[ -n "$new" ]]; then
        add_host "$hostname" "$new" || [[ -z "$force" ]]
        echo -e "[[\033[32m+\033[0m]]" && return 0
    fi

    echo "Error, no old or new configuration provided (empty)"
    return 1
}


print_new_ssh_domains() {
    local domains_json="$1"
    
    lua - "$domains_json" << 'EOF'
        domains_json = arg[1] ~= "" and arg[1] or "{}"

        -- Requires `luarocks install json-lua` (do not mistake for lua-json!)
        JSON = require("JSON")

        -- Helper to serialize a Lua table into a string
        local function serialize(tbl, indent)
            -- TODO: This func is probably flawed but it works for our case now
            indent = indent or ""
            local result = "{\n"
            for k, v in pairs(tbl) do
                if type(v) == "table" then
                    local key = type(k) == "string" and string.format("%s = ", k) or ""
                    result = result .. indent  .. "  " .. key
                    result = result .. serialize(v, indent .. "  ") .. ",\n"
                else
                    local key = type(k) == "string" and string.format("%s", k) or key
                    result = result .. indent  .. "  " .. key .. " = "
                    if type(v) == "string" then
                        result = result .. string.format("%q", v) .. ",\n"
                    else
                        result = result .. tostring(v) .. ",\n"
                    end
                end
            end
            result = result .. indent .. "}"
            return result
        end

        local new_domains = JSON:decode(domains_json)

        -- Create lua table based on the new domains json file
        local new_ssh_domains = {}
        for hostname, v in pairs(new_domains) do
            local domain = {
                name = 'SSHMUX:' .. hostname,
                remote_address = hostname,
                username = v["user"],
                remote_wezterm_path = v["path"],
            }
            table.insert(new_ssh_domains, domain)
        end

        -- Write everything to stdout
        print("-- THIS FILE IS AUTO GENERATED AND MAINTAINED BY GIT REMOTE SYNC\n")
        print("local M = {}\n")
        print("M.ssh_domains = " .. serialize(new_ssh_domains) .. "\n")
        print("return M\n")

EOF
}


log_from_fds() {
    local -n fds=$1

    trap 'stop_log_loop=true' TERM INT
    stop_log_loop=false

    # Braille spinner
    local spinner=(⠁ ⠂ ⠄ ⡀ ⢀ ⠠ ⠐ ⠈)
    local index=0
   
    local -A lines
    local -A term_tokens

    # Disable auto-wrap
    printf '\e[?7l'

    # Log everything then jump back to the top as background process
    while true; do
        local n_new_lines=0

        # Forward spinner index
        index=$(( (index + 1) % ${#spinner[@]} ))

        # Read messages from all file descriptors and put them into dict
        local lines_fmt=""
        for host in "${!fds[@]}"; do
            fd=${fds[$host]}

            # Not yet finished? Display spinner
            local token="${term_tokens[$host]}"
            if [[ -z "$token" ]]; then
                token="${spinner[$index]}"
            fi

            # Read line
            if IFS= read -r -t 0.01 -u "$fd" line; then
                ((++n_new_lines))
                # Check for token
                if [[ "$line" =~ ^\[\[(.+)\]\] ]]; then
                    local term_token="${BASH_REMATCH[1]}"
                    term_tokens["$host"]="$term_token"
                    printf -v line_fmt "\r%s\n" "$term_token"
                else
                    printf -v line_fmt "\033[2K\r%s %-20s: \033[90m%s\033[0m\n" "$token" "$host" "$line" # Clear line before printing new statement
                fi
            else
                printf -v line_fmt "\r%s\n" "$token"
            fi
            lines_fmt+="$line_fmt"
        done

        echo -en "$lines_fmt"

        # Stop signal received -> loop one last time
        if [[ $stop_log_loop == true && "$n_new_lines" == 0 ]]; then
            break
        fi

        # Jump back up and repeat
        # sleep 0.05
        printf "\033[%dA" "${#fds[@]}"
    done

    # Re-enable auto-wrap (important to restore!)
    printf '\e[?7h'
}


sync() {
    local wezterm_ssh_domains_file="$1"
    local force="$2"

    # 1. Read git remotes 

    git_remotes="$(read_git_remotes)"

    echo "git_remotes=$git_remotes"


    # 2. Read ssh_domains file

    ssh_domains="$(read_wezterm_ssh_domains "$wezterm_ssh_domains_file" "dotfiles")"

    echo "ssh_domains=$ssh_domains"


    # 3. Diff those two 

    # NOTE: If the hostname doesn't exist in new or old json the complete new/old field
    # respectively is omitted in the diff json
    diff=$(jq -rn \
      --argjson new "$git_remotes" \
      --argjson old "$ssh_domains" \
      '
      ($new + $old | keys_unsorted[]) as $k
        | {
            ($k): (
                {} +
                (if $new[$k] != null then { new: $new[$k] } else {} end) +
                (if $old[$k] != null then { old: $old[$k] } else {} end)
                )
            }
      ' | jq -s 'add // {}') # in case no keys

    echo "diff=$diff"


    # 4. Update remotes
    
    # Create bash array with all unique hostnames (keys)
    hostnames=( $(jq -r 'keys_unsorted[]' <<< "$diff") )
   
    
    # DEBUG:
    for hostname in ${hostnames[@]}; do
        echo "hostname = $hostname"
    done


    # Create named pipes
    declare -A host_pipes
    for hostname in "${hostnames[@]}"; do
        pipe="/tmp/$(mktemp -u git-remote-sync.XXXXXXX)"
        mkfifo "$pipe"
        host_pipes["$hostname"]="$pipe"
    done

    # Create file descriptors for pipes
    # NOTE: We need to use file descriptors instead of named pipes because if we
    # finish reading from a pipe the pipe closes the read end eagerly which is
    # not what we want!
    declare -A host_fds
    for hostname in "${hostnames[@]}"; do
        pipe="${host_pipes[$hostname]}"
        exec {fd}<>"$pipe"
        host_fds["$hostname"]=$fd
    done

    # Start a child process for each host
    declare -A host_pids
    for hostname in "${hostnames[@]}"; do
        pipe="${host_pipes[$hostname]}"
        old=$(jq -r --arg hostname "$hostname" '.[$hostname].old // empty' <<< "$diff")
        new=$(jq -r --arg hostname "$hostname" '.[$hostname].new // empty' <<< "$diff")

        update_host "$hostname" "$old" "$new" "$force" > "$pipe" 2>&1 &
        host_pids["$hostname"]="$!"
    done

    echo "Started all tasks"

    # Start logger
    log_from_fds host_fds &
    log_pid=$!

    # Wait for all child processes to finish and concatenate results
    new_json="{}"
    for hostname in "${hostnames[@]}"; do
        pipe="${host_pipes[$hostname]}"
        pid="${host_pids[$hostname]}"

        status=0
        wait "$pid" || status=$?
        if [[ "$status" != 0 ]]; then
            echo -e "[[\033[31m!\033[0m]]" > "$pipe" 2>&1
        fi

        new_json="$(jq -r --arg hostname "$hostname" \
            --argjson status "$status" \
            --argjson diff "$diff" \
                '. + (
                    if $status == 0 then
                        { ($hostname) : ( $diff[$hostname].new // empty) }
                    else
                        { ($hostname) : ( $diff[$hostname].old // empty) }
                    end)
                ' <<< "$new_json")"
    done
 
    # Cleanup pipes and fds
    kill -TERM "$log_pid" 2>/dev/null
    wait "$log_pid" 2>/dev/null

    # All tasks done
    echo "All done"

    for hostname in "${hostnames[@]}"; do
        fd="${host_fds[$hostname]}"
        pipe="${host_pipes[$hostname]}"
        exec {fd}>&-  # Close file descriptor
        rm -f "$pipe"
    done

    echo "After cleanup"


    # 5. Create new ssh_domains

    tmp_filepath="$(dirname "$wezterm_ssh_domains_file")/tmp_domains.lua"
    print_new_ssh_domains "$new_json" > $tmp_filepath
    mv "$tmp_filepath" "$wezterm_ssh_domains_file"

    echo "File written!"
    # + = addition
    # - = removal
    # ~ = modification/change
    # = = unchanged
    # ! = error

    # echo -e "$(cat "$tmp_filepath")\nDo you want to commit the above file [y/N]?"
    # echo "Main script finished"
}


sshmux_connect() {
    local wezterm_ssh_domains_file="$1"
    ssh_domains_list="$(read_wezterm_ssh_domains "$wezterm_ssh_domains_file" | jq -r 'keys_unsorted[]')"
    selection=$(fzf <<< "$ssh_domains_list")
    echo "selection was $selection"
    wezterm connect "SSHMUX:$selection"
}


###### MAIN APP ######

# Program assumptions
# - json-lua installed via luarocks `luarocks install json-lua` (do not mistake for lua-json!)
# - wezterm installed and available on PATH
WEZTERM_SSH_DOMAINS_FILE=$HOME/.config/wezterm/ssh_domains.lua

# Add luarocks packages
eval "$(luarocks path)"


case "$1" in
    ""|-f|--force)
        sync "$WEZTERM_SSH_DOMAINS_FILE" "$1"
        ;;
    -s|--ssh)
        sshmux_connect "$WEZTERM_SSH_DOMAINS_FILE"
        ;;
esac
