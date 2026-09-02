#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRIGGER="$SCRIPT_DIR/paste_trigger"
NATIVE_HELPER="$SCRIPT_DIR/paste_helper"
PYTHON_HELPER="$SCRIPT_DIR/paste_helper.py"

MODE=${1:-clipboard}
TIMEOUT=15

do_paste() {
    if [[ -S "/tmp/smart_paste.sock" ]]; then
        "$TRIGGER"
    elif [[ -x "$NATIVE_HELPER" ]]; then
        "$NATIVE_HELPER"
    else
        python3 "$PYTHON_HELPER"
    fi
}

DBUS_CMD="qdbus6"
if ! command -v qdbus6 >/dev/null; then
    DBUS_CMD="qdbus"
fi

if [[ "$MODE" == "emoji" ]]; then
    OLD_CONTENT=$(wl-paste -n 2>/dev/null)
    plasma-emojier &

    START_TIME=$(date +%s)
    while true; do
        NOW=$(date +%s)
        if (( NOW - START_TIME > TIMEOUT )); then
            exit 0
        fi

        CURRENT_CONTENT=$(wl-paste -n 2>/dev/null)
        if [[ "$CURRENT_CONTENT" != "$OLD_CONTENT" ]]; then
            pkill plasma-emojier 2>/dev/null
            sleep 0.15
            do_paste
            exit 0
        fi
        sleep 0.03
    done
else
    # 1. Catat konten clipboard awal
    OLD_CONTENT=$(wl-paste -n 2>/dev/null)

    # 2. Munculkan popup Klipper
    $DBUS_CMD org.kde.klipper /klipper showKlipperPopupMenu &

    # 3. Dengarkan event Klipper via gdbus monitor ATAU perubahan wl-paste
    # Catatan: gdbus monitor menangkap sinyal clipboardHistoryUpdated seketika
    (
        gdbus monitor --session --dest org.kde.klipper --object-path /klipper 2>/dev/null | grep -m 1 "clipboardHistoryUpdated" >/dev/null
    ) &
    DBUS_PID=$!

    START_TIME=$(date +%s)
    while true; do
        NOW=$(date +%s)
        if (( NOW - START_TIME > TIMEOUT )); then
            kill $DBUS_PID 2>/dev/null
            exit 0
        fi

        # Cek apakah DBus signal sudah terpicu
        if ! kill -0 $DBUS_PID 2>/dev/null; then
            # Sinyal Klipper terdeteksi! Jeda agar popup Klipper selesai menutup dan target window aktif
            sleep 0.18
            do_paste
            exit 0
        fi

        # Fallback jika item clipboard yang dipilih adalah item teratas (DBus tidak selalu emit signal)
        CURRENT_CONTENT=$(wl-paste -n 2>/dev/null)
        if [[ "$CURRENT_CONTENT" != "$OLD_CONTENT" ]]; then
            kill $DBUS_PID 2>/dev/null
            sleep 0.18
            do_paste
            exit 0
        fi

        sleep 0.03
    done
fi
