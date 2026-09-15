from Xlib import X, display
from Xlib import Xatom
from PIL import Image
import array as arr
import struct


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


def get_window_icon(window_id):
    d = display.Display()
    window = d.create_resource_object('window', window_id)

    # Get the icon sizes
    # icon_sizes = window.get_property(X.XA_WM_ICON_SIZE, X.XA_CARDINAL, 0, 1024, False)
    name = d.get_atom('_NET_WM_ICON')
    icon = window.get_full_property(name, Xatom.CARDINAL)
    valarray = icon.value
    if not icon or len(valarray) < 6:
        raise ValueError("No icon sizes found")

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

# Example usage
window_id = 0x3a0004e  # Replace with your window ID
# xwininfo
save_icon_to_png(window_id, "window_icon.png")