#!/home/sbeer/anaconda3/envs/i3/bin/python
from typing import List, Dict, Any, Set, Tuple
from i3ipc import Connection, Event, Con
from Xlib import X, display
from Xlib import Xatom
from PIL import Image
import json
import os
from pathlib import Path
import subprocess

d = display.Display()


ICON_PATH = "./icons_gen"
ICON_INDEX_FILE = "./icons_gen/icons.json"

def abgr_to_rgba(argb: int) -> int:
    # Extract the components (little endian, so byte order is bgra)
    alpha = (argb >> 24) & 0xFF
    red = (argb >> 16) & 0xFF
    green = (argb >> 8) & 0xFF
    blue = (argb >> 0) & 0xFF

    # blue = (argb >> 24) & 0xFF
    # green = (argb >> 16) & 0xFF
    # red = (argb >> 8) & 0xFF
    # alpha = (argb >> 0) & 0xFF

    # ffaabbcc
    
    # Combine into RGBA format
    rgba = (alpha << 24) | (blue << 16) | (green << 8) | red
    # rgba = (red << 24) | (green << 16) | (blue << 8) | alpha
    return rgba
    # argb = (alpha << 24) | (red << 16) | (green << 8) | blue
    argb = (alpha << 24) | (blue << 16) | (green << 8) | red
    return argb
    # myint = 0xff0000bb
    # partofit = (myint >> 24) & 0xFF
    # return 0xffff00ff


def query_property(win, name, prop_type, format_size, empty=None):
    if win == 73400323:
        pass
    if isinstance(win, int):
        # Create a Window object for the Window ID
        win = d.create_resource_object('window', win)
    if isinstance(name, str):
        # Create/retrieve the X11 Atom for the property name
        name = d.get_atom(name)

    result = win.get_full_property(name, prop_type)
    if result and result.format == format_size:
        return result.value
    return empty


def get_window_icon(window_id: int) -> Image:
    print("---- get window icon ---")
    # window = d.create_resource_object('window', window_id)
    # if window_id == 73400323:
    #     pass

    # Get the icon sizes
    # icon_sizes = window.get_property(X.XA_WM_ICON_SIZE, X.XA_CARDINAL, 0, 1024, False)
    valarray = query_property(window_id, '_NET_WM_ICON', Xatom.CARDINAL, 32, None)

    # name = d.get_atom('_NET_WM_ICON')
    # icon = window.get_full_property(name, Xatom.CARDINAL)
    if not valarray or len(valarray) < 6:
        return None
        # raise ValueError("No icon sizes found")

    # Get the icon data
    # valarray = window.get_property(X.XA_WM_ICON, X.XA_CARDINAL, 0, 1024, False)
    # if not valarray:
    #     raise ValueError("No icon data found")

    # Convert the icon data to a usable format
    width = valarray[0]
    height = valarray[1]
    # height = 1
    pixels: arr.array = valarray[2:]

    # Open a file for writing
    # with open('array_hex.txt', 'w') as file:
    #     i = 0
    #     for num in pixels:
    #         # Convert the integer to a 32-bit signed integer in big-endian format
    #         packed_num = struct.pack('>I', num)
    #         # Convert the packed bytes to a hex string
    #         hex_string = packed_num.hex()
    #         # Write the hex string to the file
    #         i+=1
    #         if i == 4:
    #             file.write(hex_string + '\n')
    #             i = 0
    #         else:
    #             file.write(hex_string + ' ')
            
    
    # Create an image from the pixel data
    pixels = [abgr_to_rgba(argb) for argb in pixels]
    
    img = Image.new('RGBA', (width, height))
    # datalist = list(zip(pixels[::4], pixels[1::4], pixels[2::4], pixels[3::4]))
    # print(f'width = {width}, height = {height}, theoretic_len = {width*height*4}, listlen={len(datalist)}')

    img.putdata(pixels)

    return img

    
def save_icon_to_png(window_id, filename):
    try:
        icon = get_window_icon(window_id)
        icon.save(filename, 'PNG')
        print(f"Icon saved as {filename}")
    except Exception as e:
        print(f"Error: {e}")

# Define a callback function for the window::new event
def on_window_new(i3, e):
    # e.container contains information about the new window
    container = e.container
    print(f"New window created: {container.name} (Class: {container.window_class}, Instance: {container.window_instance}, ID: 0x{container.window:x})")

    save_icon_to_png(window_id=container.window, filename='icon.png')

    # You can perform any actions here based on the new window properties
    # For example, move the window to a specific workspace
    # if window.window_class == "Firefox":
    #     i3.command(f'[id={window.id}] move to workspace 2')

def traverse_tree(container):
    # Check if the container has a window (leaf node)
    print("------")
    if container.window:
        print(f"Window ID: {container.window}, Name: {container.name}, Output: {container.output}")
        save_icon_to_png(window_id=container.window, filename=f'icon_{container.window}.png')
    else:
        print("empty container spotted")

    
    # Recursively traverse child containers
    if isinstance(container.nodes, list):
        for child in container.nodes:
            traverse_tree(child)

def assemble_json_from_node(container):
    json = {
            "name": container.name,
            "window_id": container.window,
            "nodes": []
    }
    # if container.window:
    #     json.append({"name": container.name, "nodes": [f'icon_{container.window}.png']})
    # else:
    #     json.append({"name": container.name, "nodes": []})
        
    # Recursively traverse child containers
    if isinstance(container.nodes, list):
        for child in container.nodes:
            json["nodes"].append(assemble_json_from_node(child))
    return json





# ----------------
            
def extract_win_classes(node: Con) -> Set[str]:
    # Walk through the tree recursively and extract all window classes
    win_classes = set()

    if node.window_class:
        win_classes.add(node.window_class)

    if isinstance(node.nodes, list):
        for child in node.nodes:
            child_win_classes = extract_win_classes(child)
            win_classes.update(child_win_classes)

    return win_classes
 

def assemble_eww_json(node: Con, target='output') -> List[Dict[str, Any]]:

    json = list()

    print(f"Node: {node.name}, Type: {node.type}")
    
    # Looking for these node types
    if target != node.type:
        # Return a flattened list of children
        if isinstance(node.nodes, list):
            for child in node.nodes:
                json += assemble_eww_json(child, target) # Flattens the list
    else:
        match node.type:
            case 'output':
                entry = {
                    "name": node.name,
                    "type" : node.type,
                }
                children = list()
                if isinstance(node.nodes, list):
                    for child in node.nodes:
                        children += assemble_eww_json(child, target='workspace') # Needs all workspaces
                entry["workspaces"] = children
                json.append(entry)

            case 'workspace':
                entry = {
                    "name": node.name,
                    "type" : node.type,
                }
                children = list()
                if isinstance(node.nodes, list):
                    for child in node.nodes:
                        children += assemble_eww_json(child, target='con')
                entry["windows"] = children
                json.append(entry)
                    
            case 'con':
                entry = {
                    "name": node.name,
                    "type" : node.type,
                    "window_id": node.window,
                    "win_class": node.window_class
                }
                json.append(entry)
            case _:
                raise ValueError(f"Unknown node type: {node.type}")
    
    return json


def enrich_with_icons(eww_json: List[Dict[str, Any]], icons: Dict[str, Any]) -> List[Dict[str, Any]]:
    # Traverse the eww_json and add the icons where available
    for output in eww_json:
        for workspace in output["workspaces"]:
            for window in workspace["windows"]:
                win_class = window["win_class"]
                if win_class in icons:
                    window["icon"] = icons[win_class]
    return eww_json

    
def create_new_icons(node: Con, new_win_classes: Set[str], icon_dirname: Path, icon_res: Tuple[int, int]) -> Dict[str, Any]:
    # Check if directory exists if not create it
    if not icon_dirname.exists():
        icon_dirname.mkdir()
    # Create icons for the new window classes
    icons = dict()
    for win_class in new_win_classes:
        windows: List[Con] = node.find_classed(win_class)
        if windows:
            win = windows[0]
            window_id = win.window
            icon: Image = get_window_icon(window_id)
            # Some windows do not annotate the icon, so we skip them
            if not icon:
                continue
            icon.thumbnail(icon_res, Image.Resampling.LANCZOS)
            width, height = icon.size
            print(f"width = { width }, height = { height }")
            x_res, y_res = icon_res
            icon_filepath = icon_dirname / f"{win_class}_{ x_res }x{ y_res }.png"
            icon.save(icon_filepath, 'PNG')
            # Add this icon to the index
            icons[win_class] = str(icon_filepath)
    return icons

    
def update_eww(eww_json: List[Dict[str, Any]]):
    result = subprocess.run(["eww", "update", f"jvar_workspaces={ json.dumps(eww_json) }"])
    print(f"{json.dumps(eww_json)}")
    if result.returncode != 0:
        print(f"Error updating eww: {result.stderr}")


def main():
    # Load all icons from file
        
    # old_icons = """
    #     {
    #        "firefox" : {
    #             "resolution" : [1920, 1080],
    #             "path": "icon_ff_1920x1080.png"
    #        },
    #        "chrome" :{
               
    #        }

    #     }
        
    # """

    # Load the old icons from file and sort out the ones that are not found
    old_icons = dict()
    if os.path.exists(ICON_INDEX_FILE): 
        with open(ICON_INDEX_FILE, 'r') as file:
            icons = json.load(file)
    for icon in icons:
        if not os.path.exists(icons[icon]):
            icons.pop(icon)

    # Get current container tree from i3
    i3 = Connection()
    root = i3.get_tree()

    # Extract all window classes from the tree
    all_win_classes: Set[str] = extract_win_classes(root)

    # Determine new classes
    new_win_classes = set()
    for win_class in all_win_classes:
        if not win_class in icons:
            new_win_classes.add(win_class)

    # Create json for eww with icons
    eww_json = assemble_eww_json(root)
    eww_json = enrich_with_icons(eww_json, icons)

    update_eww(eww_json)

    # Create all the other icons
    icon_res = (64, 64)
    new_icons: Dict[str: Any] = create_new_icons(root, new_win_classes, Path(ICON_PATH), icon_res)

    # Add the new icons to the index
    icons.update(new_icons)

    # Save the new index
    os.makedirs(os.path.dirname(ICON_INDEX_FILE), exist_ok=True)
    with open(ICON_INDEX_FILE, 'w') as file:
        json.dump(icons, file)

    # Update eww again with the new icons
    eww_json = enrich_with_icons(eww_json, icons)
    update_eww(eww_json)

    # # Subscribe to the window::new event
    # i3.on('window::new', on_window_new)

    # i3.main()

    # Print the name of the focused window
    # focused = i3.get_tree().find_focused()
    # print('Focused window %s is on workspace %s' %
    #     (focused.name, focused.workspace().name))

    # print(f'Focused window ID: {focused.window}')

    # save_icon_to_png(window_id=focused.window, filename='icon.png')
        
    # Find the window ID of the focused window
    # window_id = focused.window


if __name__ == "__main__":
    main()


