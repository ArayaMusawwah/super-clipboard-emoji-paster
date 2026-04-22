import sys
import time
from evdev import UInput, ecodes as e

def do_paste():
    # Inisialisasi virtual keyboard
    # Kita tambahkan tombol yang diperlukan: CTRL dan V
    cap = {
        e.EV_KEY: [e.KEY_LEFTCTRL, e.KEY_V]
    }
    
    with UInput(cap, name='virtual-kbd', vendor=0x1) as ui:
        # Jeda sangat singkat agar sistem mengenali device
        time.sleep(0.1)
        
        # Tekan Ctrl+V
        ui.write(e.EV_KEY, e.KEY_LEFTCTRL, 1)
        ui.write(e.EV_KEY, e.KEY_V, 1)
        ui.syn()
        
        time.sleep(0.05)
        
        # Lepas Ctrl+V
        ui.write(e.EV_KEY, e.KEY_V, 0)
        ui.write(e.EV_KEY, e.KEY_LEFTCTRL, 0)
        ui.syn()

if __name__ == "__main__":
    do_paste()
