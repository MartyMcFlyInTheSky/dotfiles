from typing import Dict, List, Tuple
import time
import subprocess
import json


def run_cmd(cmd_list: List[str]) -> subprocess.CompletedProcess:
    result = subprocess.run(cmd_list, capture_output=True, text=True)
    return result


def get_vpn_list():
    # Retrieve a list of all known vpn connections
    cols = ['name', 'type','active']
    cols_str = ','.join(cols)
    result = run_cmd(['nmcli', '-t', '-f', f'{cols_str}', 'connection', 'show'])

    # Annotate error if not successful
    if result.returncode != 0:
        raise RuntimeError(f"Error running nmcli command: {result.stderr}")

    # Parse output into dict
    nmcli_list: List[Dict[str, str]] = []

    lines = result.stdout.strip().split('\n')
    for line in lines:
        values = line.split(':')
        nmcli_dict = dict(zip(cols, values))
        if nmcli_dict['type'] == 'vpn':
            nmcli_list.append(nmcli_dict)

    return nmcli_list


if __name__ == "__main__":
    # Announce us loading
    run_cmd(['eww', 'update', 'var_vpn_script_exec=loading'])

    # Retrieve the list of VPNs
    try:
        vpns_list = get_vpn_list()
    except RuntimeError as e:
        run_cmd(['eww', 'update', 'var_vpn_script_exec=loading_error'])

    # Put into json
    vpns_json = json.dumps(vpns_list)

    # Update the eww variables
    run_cmd(['eww', 'update', 'var_vpn_script_exec=', f"jvar_vpns={vpns_json}"])
