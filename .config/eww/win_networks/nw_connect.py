from typing import Tuple, List
import argparse
import subprocess
from contextlib import suppress
import json
import sys
import re


def send_notification(title, message):
    try:
        subprocess.run(['notify-send', title, message])
    except FileNotFoundError:
        print("notify-send is not available. Please make sure it is installed.")


def parse_arguments():
    parser = argparse.ArgumentParser(description="Process files with a given configuration.")
    parser.add_argument('selection', type=str, help="selection made")
    parser.add_argument('networks', type=str, help="all networks available")
    args = parser.parse_args()
    return args


def run_cmd(cmd_list: List[str]) -> subprocess.CompletedProcess:
    result = subprocess.run(cmd_list, capture_output=True, text=True)
    return result


if __name__ == "__main__":
    args = sys.argv[1:]
    # Combine all arguments into a single string message
    message = " ".join(args)
    # Send the notification
    # send_notification("all cli arguments: ", message)

    args = parse_arguments() 

    jnetworks = json.loads(args.networks)
    jselection = json.loads(args.selection)
    bssid = jselection["bssid"]

    #send_notification('Connecting to network', f"Connecting to network {bssid}") 

    # Update the network list to annotate the connection process
    for network in jnetworks:
        if network["bssid"] == bssid:
            # send_notification('set connecting = y', f"Connecting to network {bssid}") 
            network["connecting"] = "y"
    
    jvar_networks = json.dumps(jnetworks)

    run_cmd(['eww', 'update', 'var_connecting=true', f'jvar_networks={jvar_networks}'])

    result = run_cmd(['nmcli', 'device', 'wifi', 'connect', f'{bssid}'])

    pattern = r"successfully activated"
    match = re.search(pattern, result.stdout)

    if not match or result.returncode != 0:
        # send_notification('Connection failed', f"Connection to network {bssid} failed")
        # Add an entry connection error
        for network in jnetworks:
            if network["bssid"] ==  bssid:
                #send_notification('set to e', f"Connection to network {bssid} failed, set e flag")
                network["connecting"] = "e"

        jvar_networks = json.dumps(jnetworks)
        
        run_cmd(['eww', 'update', 'var_connecting=false', f"jvar_networks={jvar_networks}"])
    else:
        # Find the network in the available networks and set in-use to true
        for network in jnetworks:
            if network["bssid"] ==  bssid:
                network["in-use"] = "*"
                del network["connecting"]
            if network["in-use"] == "*" and network["bssid"] != bssid:
                network["in-use"] = " "

        jvar_networks = json.dumps(jnetworks)
    
        run_cmd(['eww', 'update', 'var_connecting=false', f"jvar_networks={jvar_networks}"])
        #send_notification('Connected to network', f"Connected to network {bssid}") 