#!/bin/bash

# Type: clipboard (default) or emoji
MODE=${1:-clipboard}
TIMEOUT=15 # seconds
INTERVAL=0.1 # seconds

# Fungsi untuk mengambil isi clipboard
get_clipboard() {
    wl-paste -n 2>/dev/null
}

OLD_CONTENT=$(get_clipboard)

# Munculkan UI
if [ "$MODE" == "emoji" ]; then
    # Jalankan emojier
    plasma-emojier &
else
    # Jalankan klipper popup
    qdbus6 org.kde.klipper /klipper showKlipperPopupMenu
fi

# Loop deteksi perubahan
START_TIME=$(date +%s)
while true; do
    CURRENT_TIME=$(date +%s)
    if (( CURRENT_TIME - START_TIME > TIMEOUT )); then
        exit 0
    fi

    CURRENT_CONTENT=$(get_clipboard)
    
    if [[ "$CURRENT_CONTENT" != "$OLD_CONTENT" ]]; then
        # Khusus Emoji: Kita harus menutup aplikasinya agar fokus kembali
        if [ "$MODE" == "emoji" ]; then
            pkill plasma-emojier
        fi

        # Jeda krusial agar UI tertutup dan fokus kembali ke aplikasi tujuan
        sleep 0.5
        
        # Panggil helper Python dengan sudo
        sudo python /home/root_iqbal/Codes/project-emote_clipboard/bin/paste_helper.py
        
        exit 0
    fi
    
    sleep $INTERVAL
done
