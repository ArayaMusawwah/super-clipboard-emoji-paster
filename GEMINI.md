# KDE Smart Paste (Wayland)

Solusi "Select to Paste" untuk KDE Plasma 6 di Wayland, meniru perilaku Windows (`Meta+V` / `Meta+.`).

## Tech Stack
- **Language:** Bash (Orchestrator), Python (Input Simulation Helper)
- **Runtime:** Python 3 (dengan library `evdev`)
- **System Requirements:** KDE Plasma 6, `wl-paste` (Wayland), `python-evdev`
- **Architecture:** Mendeteksi perubahan clipboard setelah memicu UI selector KDE, lalu mensimulasikan `Ctrl+V` melalui `/dev/uinput`.

## Project Structure
- `bin/smart-paste.sh`: Skrip utama yang memantau clipboard dan memicu UI KDE.
- `bin/paste_helper.py`: Helper Python untuk simulasi input keyboard tingkat rendah menggunakan `evdev`.
- `docs/superpowers/`: Dokumentasi spesifikasi desain dan rencana implementasi.

## Setup & Commands

### Prerequisites
1.  **Dependencies:**
    - KDE Plasma 6
    - `wl-clipboard` (untuk `wl-paste`)
    - `python-evdev` (untuk simulasi input)
2.  **Permissions:**
    User memerlukan akses ke `/dev/uinput`. Biasanya dilakukan dengan menambahkan user ke grup `input` atau `uinput` dan mengonfigurasi udev rules.

### Running
Skrip dirancang untuk dijalankan melalui shortcut global KDE:
- **Clipboard Mode:** `bin/smart-paste.sh clipboard`
- **Emoji Mode:** `bin/smart-paste.sh emoji`

### Development Conventions
- **Clean Code:** Skrip harus rapi dan memiliki komentar yang jelas (Bahasa Indonesia/Inggris).
- **Security:** Hindari penggunaan `sudo` di dalam skrip jika memungkinkan; gunakan `udev` rules untuk izin permanen.
- **Robustness:** Pastikan loop deteksi memiliki timeout agar tidak berjalan selamanya jika tidak ada item yang dipilih.

## Key Files
- `docs/superpowers/specs/2026-04-22-kde-smart-paste-design.md`: Arsitektur detail sistem.
- `bin/smart-paste.sh`: Logika deteksi perubahan clipboard.
- `bin/paste_helper.py`: Implementasi virtual keyboard `Ctrl+V`.
