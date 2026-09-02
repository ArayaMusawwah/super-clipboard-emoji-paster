# KDE Smart Paste (Wayland)

Solusi "Select to Paste" otomatis untuk KDE Plasma 6 di Wayland. Skrip ini meniru perilaku Windows (`Meta+V` / `Meta+.`) di mana memilih item dari Clipboard Manager atau Emoji Selector akan langsung melakukan *paste* (`Ctrl+V`) ke aplikasi yang sedang aktif dengan latensi instan.

## Fitur
- **Ultra Low Latency**: Menggunakan daemon background virtual keyboard (`smart_paste_daemon`) via Unix Domain Socket.
- **Auto-Paste Clipboard**: Pilih item dari history clipboard, langsung menempel.
- **Auto-Paste Emoji**: Pilih emoji, jendela emoji tertutup, dan emoji langsung menempel.
- **Wayland Native**: Didesain khusus untuk KDE Plasma 6 di Wayland.

## Persyaratan Sistem
- **KDE Plasma 6** (Wayland session)
- **wl-clipboard** (`wl-paste`)
- **gcc** / **make** (untuk compile binary C)

## Instalasi & Setup

### 1. Install Dependensi
```bash
sudo pacman -S wl-clipboard gcc
```

### 2. Izin Akses `/dev/uinput`
Agar daemon dapat membuat virtual keyboard tanpa `sudo`:
```bash
echo 'KERNEL=="uinput", GROUP="input", MODE="0660", OPTIONS+="static_node=uinput"' | sudo tee /etc/udev/rules.d/80-uinput.rules
sudo udevadm control --reload-rules && sudo udevadm trigger
sudo usermod -aG input $USER
```
*(Logout dan login kembali jika baru menambahkan user ke grup `input`)*

### 3. Compile Helper & Daemon
```bash
cd bin
gcc -O3 smart_paste_daemon.c -o smart_paste_daemon
gcc -O3 paste_trigger.c -o paste_trigger
gcc -O3 paste_helper.c -o paste_helper
```

### 4. Setup Systemd Service (Auto-Start Daemon)
Buat file service di `~/.config/systemd/user/smart-paste-daemon.service`:
```ini
[Unit]
Description=Smart Paste Virtual Keyboard Daemon
After=graphical-session.target

[Service]
ExecStart=%h/Codes/project-emote_clipboard/bin/smart_paste_daemon
Restart=always
RestartSec=1

[Install]
WantedBy=default.target
```

Aktifkan dan jalankan:
```bash
systemctl --user daemon-reload
systemctl --user enable --now smart-paste-daemon.service
```

### 5. Konfigurasi Shortcut KDE
Buka **System Settings** -> **Keyboard** -> **Shortcuts** -> **Commands** -> **Add New**:

1. **Clipboard Mode**:
   - **Name**: `Smart Clipboard Paste`
   - **Command**: `/path/to/project-emote_clipboard/bin/smart-paste.sh clipboard`
   - **Shortcut**: `Meta+V`

2. **Emoji Mode**:
   - **Name**: `Smart Emoji Paste`
   - **Command**: `/path/to/project-emote_clipboard/bin/smart-paste.sh emoji`
   - **Shortcut**: `Meta+.` atau `Meta+Space`

## Struktur Proyek
- `bin/smart_paste_daemon.c`: Daemon virtual keyboard `/dev/uinput` (standby via `/tmp/smart_paste.sock`).
- `bin/paste_trigger.c`: Client C untuk mengirim trigger paste ke daemon (~1ms).
- `bin/paste_helper.c` / `bin/paste_helper.py`: Standalone fallback paster.
- `bin/smart-paste.sh`: Orchestrator utama menu KDE dan event listener.

## Lisensi
MIT
