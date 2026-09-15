from Xlib import X, Xutil
from Xlib.display import Display
from PIL import Image
import numpy as np

def get_window_icon(display, window):
    # Get the WM_HINTS property
    wm_hints = window.get_wm_hints()
    if wm_hints is None:
        print("No WM_HINTS property found.")
        return

    # Check if the icon pixmap and mask are available
    if wm_hints.flags & Xutil.IconPixmapHint:
        icon_pixmap = wm_hints.icon_pixmap
    else:
        icon_pixmap = None

    if wm_hints.flags & Xutil.IconMaskHint:
        icon_mask = wm_hints.icon_mask
    else:
        icon_mask = None

    # If both pixmap and mask are available, convert them to an image
    if icon_pixmap and icon_mask:
        image = icon_pixmap.get_image(0, 0, 16, 16, X.ZPixmap, 0xffffffff)
        mask_image = icon_mask.get_image(0, 0, 16, 16, X.ZPixmap, 0xffffffff)

        if image and mask_image:
            print("Icon pixmap and mask retrieved successfully.")

            # Convert the image data to a numpy array
            image_data = np.frombuffer(image.data, dtype=np.uint8).reshape(image.height, image.width, 4)
            mask_data = np.frombuffer(mask_image.data, dtype=np.uint8).reshape(mask_image.height, mask_image.width, 4)

            # Create a PIL image from the numpy array
            pil_image = Image.fromarray(image_data, 'RGBA')
            pil_mask = Image.fromarray(mask_data, 'RGBA')

            # Apply the mask to the image
            pil_image.putalpha(pil_mask.convert('L'))

            # Save the image to a file
            pil_image.save('window_icon.png')

            # Alternatively, display the image
            pil_image.show()

        else:
            print("Failed to retrieve icon image or mask.")
    else:
        print("No icon pixmap or mask found in WM_HINTS.")

def main():
    # Open a connection to the X server
    display = Display()
    if not display:
        print("Unable to open X display.")
        return

    # Get the window ID (replace with the actual window ID you want to query)
    window_id = 0x4600003  # Example window ID
    window = display.create_resource_object('window', window_id)

    # Get the window icon
    get_window_icon(display, window)

    # Close the connection to the X server
    display.close()

if __name__ == "__main__":
    main()