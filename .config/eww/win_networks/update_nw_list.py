from typing import Dict, List, Tuple
import subprocess
import re
import json


def send_notification(title, message):
    try:
        subprocess.run(['notify-send', title, message])
    except FileNotFoundError:
        print("notify-send is not available. Please make sure it is installed.")


def run_cmd(cmd_list: List[str]) -> subprocess.CompletedProcess:
    result = subprocess.run(cmd_list, capture_output=True, text=True)
    return result


def get_network_list() -> List[Dict[str, str]]:
    # Define the keys we're interested in
    keys = ["name", "ssid",  "mode", "chan", "freq", "signal", "security", "device", "active",  "in-use", "bssid"]

    # Run the nmcli command
    cmd_keys = ','.join(keys)
    # result = run_cmd(f'nmcli -t -f {cmd_keys.upper()} dev wifi list')
    result = run_cmd(['nmcli', '-t', '-f', f'{cmd_keys.upper()}', 'dev', 'wifi', 'list'])

    # Assemble list of networks
    nmcli_list: List[Dict[str, str]] = [ ]

    if (result.returncode == 0):
        lines = result.stdout.strip().split('\n')

        for line in lines:
            fields = re.split(r'(?<!\\):', line)
            nmcli_dict = dict(zip(keys, fields))
            # bssid needs to be sanitized as it contains escaped \: sequences that we don't want to deal with upstream
            if 'bssid' in nmcli_dict:
                nmcli_dict['bssid'] = nmcli_dict['bssid'].replace('\\:', ':')
            nmcli_list.append(nmcli_dict)
    else:
        raise RuntimeError(f"Error running nmcli command: {result.stderr}")

    #     # Create widgets list
    #     for network in nmcli_list:
    #         cmd = r"\${{EWW_CMD}} update wifibox_selected=\"{bssid}\"".format(**network)
    #         # cmd = r"notify-send \"1234\""
    #         network['cmd'] = cmd
    #         widget = "(button :class {{ wifibox_selected == '{bssid}' ? 'wifi-selected' : 'wifi-not-selected' }} :onclick '{cmd}' '{ssid}, {signal}, {freq} (y)')".format(**network)
    #         # widget = "(button :class 'wifi-selected' :onclick '{cmd}' '{ssid}, {signal}, {freq} (y)')".format(**network)
    #         # if network["in-use"] == "*":
    #         #     widget = "(button :class {{ wifibox_selected == {bssid} ? 'wifi-selected' : 'wifi-not-selected' }} :onclick '${{EWW_CMD}} update wifibox_selected=\"{bssid}\"' '{ssid}, {signal}, {freq} (y)')".format(**network)
    #         # else:
    #         #     widget = "(button :onclick 'python scripts/connect_to_network.py {ssid}' '{ssid}, {signal}, {freq} (n)')".format(**network)
    #         widgets += widget
    #     widgets = fr"(wifibox {widgets or ''})"
    # else:
    #     widgets = f"(label :text '/!\\nError nmcli command returned {outerr}')"
    
    # And publish
    return nmcli_list


if __name__ == "__main__":
    # send_notification("Networks", "Loading network list...")
    # Signal loading
    run_cmd(['eww', 'update', 'var_loading=true'])

    # Retrieve network list
    loading_error = False
    try:
        nmcli_list = get_network_list() 
    except Exception as e:
        loading_error = True
        nmcli_list = []
    
    # send_notification("Networks", "Network list loaded. {} items found".format(len(nmcli_list)))

    jsondata = json.dumps(nmcli_list)

    # Update data
    run_cmd(['eww', 'update', 'var_loading=false', f'jvar_networks={jsondata}', f'var_loading_error={loading_error}'])