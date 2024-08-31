from typing import Dict, List, Tuple
import subprocess
import json
import argparse
import re
import sys


def send_notification(title, message):
    try:
        subprocess.run(['notify-send', title, message])
    except FileNotFoundError:
        print("notify-send is not available. Please make sure it is installed.")


def run_cmd(cmd_list: List[str]) -> subprocess.CompletedProcess:
    result = subprocess.run(cmd_list, capture_output=True, text=True)
    return result


def parse_arguments():
    parser = argparse.ArgumentParser(description="Process files with a given configuration.")
    parser.add_argument('--mode', choices=['up', 'down'], type=str, help="Up or down the connection")
    parser.add_argument('jvar_vpn_selection', type=str, help="selection made")
    parser.add_argument('jvar_vpns', type=str, help="all vpns available")
    args = parser.parse_args()
    return args


if __name__ == "__main__":
    # Parse input arguments
    args = parse_arguments()

    # Parse as json
    jvar_vpns = json.loads(args.jvar_vpns)
    jvar_vpn_selection = json.loads(args.jvar_vpn_selection)

    # Update the ongoing connection
    for vpn in jvar_vpns:
        if vpn["name"] == jvar_vpn_selection["name"]:
            # Ensure toggle
            if (vpn["active"] == 'yes' and args.mode == 'up') or (vpn["active"] == 'no' and args.mode == 'down'):
                sys.exit(0)
            vpn["inprogress"] = "y"

    jvar_vpns_str = json.dumps(jvar_vpns)
    run_cmd(['eww', 'update', 'var_vpn_script_exec=updown', f'jvar_vpns={jvar_vpns_str}'])

    result = run_cmd(['nmcli', 'connection', f'{args.mode}', f'{jvar_vpn_selection["name"]}'])

    # Annotate if not successfull
    pattern = r'successfully'
    match = re.search(pattern, result.stdout)
    if result.returncode != 0 or not match:
        for vpn in jvar_vpns:
            if vpn["name"] == jvar_vpn_selection["name"]:
                vpn["inprogress"] = 'e'
        
        jvar_vpns_str = json.dumps(jvar_vpns)
        run_cmd(['eww', 'update', 'var_vpn_script_exec=', f'jvar_vpns={jvar_vpns_str}'])
        raise RuntimeError(f'Error running nmcli command: {result.stderr}')

    # Otherwise set as active / inactive
    for vpn in jvar_vpns:
        if vpn["name"] == jvar_vpn_selection["name"]:
            if args.mode == 'up':
                vpn["active"] = 'yes'
            else:
                vpn["active"] = 'no'
            vpn["inprogress"] = 'n'
            jvar_vpn_selection = vpn

    jvar_vpns_str = json.dumps(jvar_vpns)
    jvar_vpn_selection_str = json.dumps(jvar_vpn_selection)
    run_cmd(['eww', 'update', 'var_vpn_script_exec=', f'jvar_vpns={jvar_vpns_str}', f'jvar_vpn_selection={jvar_vpn_selection_str}'])