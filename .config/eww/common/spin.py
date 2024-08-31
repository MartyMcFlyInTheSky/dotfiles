import time
import sys
import subprocess

# Define the spinner symbols
# spinner = ['⠁', '⠃', '⠉', '⠙', '⠹', '⠸', '⠼', '⠴', '⠤', '⠦', '⠖', '⠒']
spinner = ['⠟','⠯','⠷','⠾','⠽','⠻']

def send_notification(title, message):
    try:
        subprocess.run(['notify-send', title, message])
    except FileNotFoundError:
        print("notify-send is not available. Please make sure it is installed.")

def get_spinner_symbol():
    # send_notification("Spinner", "Spinner started.")
    # Get the current time in milliseconds
    current_time_ms = int(time.time() * 1000)
    # Use the last two digits of the current time to determine the spinner symbol
    index = (current_time_ms // 50) % len(spinner)
    return spinner[index]

def spin():
    try:
        while True:
            # Get the spinner symbol based on the current time
            symbol = get_spinner_symbol()
            # Print the current spinner symbol
            sys.stdout.write(f"{symbol}")
            sys.stdout.flush()
            # Wait for 100 milliseconds
            time.sleep(0.1)
    except KeyboardInterrupt:
        # Handle the interrupt to stop the spinner gracefully
        sys.stdout.write("")
        sys.stdout.flush()
        print("Spinner stopped.")

if __name__ == "__main__":
    # spin()
    symbol = get_spinner_symbol()
    sys.stdout.write(f"{symbol}")
    sys.stdout.flush()
