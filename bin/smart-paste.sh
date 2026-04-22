#!/bin/bash

# Ambil direktori tempat skrip ini berada
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_HELPER="$SCRIPT_DIR/paste_helper.py"

# Type: clipboard (default) or emoji
MODE=${1:-clipboard}
TIMEOUT=15 # detik
INTERVAL=0.1 # detik

# Fungsi untuk mengambil isi clipboard
get_clipboard() {
    wl-paste -n 2>/dev/null
}

OLD_CONTENT=$(get_clipboard)

# Cek perintah DBus yang tersedia
DBUS_CMD="qdbus6"
if ! command -v qdbus6 >/dev/null; then
    DBUS_CMD="qdbus"
fi

# Munculkan UI
if [ "$MODE" == "emoji" ]; then
    plasma-emojier &
else
    $DBUS_CMD org.kde.klipper /klipper showKlipperPopupMenu
fi

# Loop deteksi perubahan clipboard
START_TIME=$(date +%s)
while true; do
    CURRENT_TIME=$(date +%s)
    if (( CURRENT_TIME - START_TIME > TIMEOUT )); then
        exit 0
    fi

    CURRENT_CONTENT=$(get_clipboard)
    
    if [[ "$CURRENT_CONTENT" != "$OLD_CONTENT" ]]; then
        # Khusus Emoji: Tutup UI agar fokus kembali ke aplikasi asal
        if [ "$MODE" == "emoji" ]; then
            pkill plasma-emojier
            sleep 0.2
        fi

        # Jeda krusial agar jendela UI benar-benar tertutup dan fokus kembali
        sleep 0.3
        
        # Jalankan helper Python (Pastikan user sudah masuk grup 'input' agar tidak butuh sudo)
        python3 "$PYTHON_HELPER"
        
        exit 0
    fi
    
    sleep $INTERVAL
done
