# KDE Smart Paste Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Menambahkan fitur "Select to Paste" otomatis pada Clipboard Manager dan Emoji Selector di KDE Plasma 6 (Wayland) menggunakan `ydotool`.

**Architecture:** Menggunakan skrip Bash sebagai orchestrator yang memantau perubahan clipboard via DBus, lalu mensimulasikan penekanan `Ctrl+V` menggunakan `ydotool` (virtual keyboard device).

**Tech Stack:** Bash, DBus, `ydotool`, KDE Plasma 6 (Wayland).

---

### Task 1: Environment & Tooling Setup

**Files:**
- Modify: System configuration (requires `pacman` & `udev`)

- [ ] **Step 1: Install `ydotool`**

Run: `sudo pacman -S ydotool --noconfirm`
Expected: `ydotool` terinstall.

- [ ] **Step 2: Setup udev rules for non-root access to `/dev/uinput`**

```bash
echo 'KERNEL=="uinput", GROUP="input", MODE="0660", OPTIONS+="static_node=uinput"' | sudo tee /etc/udev/rules.d/80-uinput.rules
sudo udevadm control --reload-rules && sudo udevadm trigger
```

- [ ] **Step 3: Add user to `input` group**

Run: `sudo usermod -aG input $USER`
*Note: Perlu logout/login atau `newgrp input` agar efeknya terasa.*

- [ ] **Step 4: Enable & Start `ydotoold` service (User level)**

```bash
systemctl --user enable --now ydotoold
```

- [ ] **Step 5: Verify `ydotool` works**

Run: `ydotool type "Hello"`
Expected: Teks "Hello" muncul di terminal (mungkin perlu `sleep 2` sebelumnya agar sempat pindah fokus).

---

### Task 2: Implement Orchestrator Script

**Files:**
- Create: `bin/smart-paste.sh`

- [ ] **Step 1: Create script directory**

Run: `mkdir -p bin`

- [ ] **Step 2: Write `smart-paste.sh` implementation**

```bash
#!/bin/bash

# Type: clipboard (default) or emoji
MODE=${1:-clipboard}
TIMEOUT=10 # seconds
INTERVAL=0.1 # seconds

# Get current clipboard content
get_clipboard() {
    # Using klipper's DBus interface if possible, or wl-paste
    if command -v wl-paste >/dev/null; then
        wl-paste -n 2>/dev/null
    else
        qdbus org.kde.klipper /klipper getClipboardContents
    fi
}

OLD_CONTENT=$(get_clipboard)

# Launch UI
if [ "$MODE" == "emoji" ]; then
    qdbus org.kde.plasma.emojier /CentralPanel toggle
else
    # Show klipper at mouse position
    qdbus org.kde.klipper /klipper showKlipperPopupMenu
fi

# Detection loop
START_TIME=$(date +%s)
while true; do
    CURRENT_TIME=$(date +%s)
    if (( CURRENT_TIME - START_TIME > TIMEOUT )); then
        exit 0
    fi

    CURRENT_CONTENT=$(get_clipboard)
    
    if [[ "$CURRENT_CONTENT" != "$OLD_CONTENT" ]]; then
        # Wait a bit for UI to close and focus to return
        sleep 0.1
        
        # Simulate Ctrl+V (29: Ctrl, 47: V)
        ydotool key 29:1 47:1 47:0 29:0
        exit 0
    fi
    
    sleep $INTERVAL
done
```

- [ ] **Step 3: Make script executable**

Run: `chmod +x bin/smart-paste.sh`

- [ ] **Step 4: Manual Test**

Run: `bin/smart-paste.sh`
Expected: Menu clipboard muncul, pilih satu, dan teks terpilih otomatis ter-paste di terminal.

---

### Task 3: KDE Shortcut Integration

**Files:**
- Modify: KDE System Settings (Manual step)

- [ ] **Step 1: Register Global Shortcut for Clipboard**

1. Buka **System Settings** -> **Keyboard** -> **Shortcuts**.
2. Klik **Commands** -> **Add New**.
3. Name: `Smart Clipboard Paste`.
4. Command: `/home/root_iqbal/Codes/project-emote_clipboard/bin/smart-paste.sh clipboard`.
5. Shortcut: `Meta+V` (Mungkin perlu menonaktifkan shortcut default Klipper).

- [ ] **Step 2: Register Global Shortcut for Emoji**

1. Klik **Add New** lagi.
2. Name: `Smart Emoji Paste`.
3. Command: `/home/root_iqbal/Codes/project-emote_clipboard/bin/smart-paste.sh emoji`.
4. Shortcut: `Meta+.` (Mungkin perlu menonaktifkan shortcut default Emoji Selector).

- [ ] **Step 3: Final Verification**

Coba gunakan shortcut di aplikasi apapun (Browser, VS Code, Kate).
Expected: Persis seperti behavior Windows.
