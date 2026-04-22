# KDE Smart Paste (Wayland)

Solusi "Select to Paste" otomatis untuk KDE Plasma 6 di Wayland. Skrip ini meniru perilaku Windows (`Meta+V` / `Meta+.`) di mana memilih item dari Clipboard Manager atau Emoji Selector akan langsung melakukan *paste* (`Ctrl+V`) ke aplikasi yang sedang aktif.

## Fitur
- **Auto-Paste Clipboard**: Pilih item dari history clipboard, langsung menempel.
- **Auto-Paste Emoji**: Pilih emoji, jendela emoji tertutup, dan emoji langsung menempel.
- **Wayland Native**: Didesain khusus untuk KDE Plasma 6 di Wayland.
- **Low-Level Simulation**: Menggunakan Python `evdev` untuk simulasi keyboard yang presisi.

## Persyaratan Sistem
- **KDE Plasma 6** (Wayland session)
- **wl-clipboard** (untuk akses clipboard di Wayland)
- **python-evdev** (untuk simulasi input keyboard)

## Instalasi

### 1. Install Dependensi
Untuk pengguna Arch Linux/CachyOS:
```bash
sudo pacman -S wl-clipboard python-evdev
```

### 2. Izin Akses `/dev/uinput`
Agar Python dapat mensimulasikan keyboard tanpa `sudo` (diperlukan agar skrip otomatis berjalan lancar):
```bash
echo 'KERNEL=="uinput", GROUP="input", MODE="0660", OPTIONS+="static_node=uinput"' | sudo tee /etc/udev/rules.d/80-uinput.rules
sudo udevadm control --reload-rules && sudo udevadm trigger
sudo usermod -aG input $USER
```
*Catatan: Anda perlu logout dan login kembali agar grup `input` aktif, atau jalankan `newgrp input` di terminal sesi saat ini.*

## Konfigurasi Shortcut KDE

Skrip ini sekarang secara otomatis mendeteksi jalurnya sendiri, sehingga Anda hanya perlu mendaftarkan path absolutnya sekali.

1. Buka **System Settings** -> **Keyboard** -> **Shortcuts**.
2. Klik **Commands** -> **Add New**.
3. **Clipboard Mode**:
   - Name: `Smart Clipboard Paste`
   - Command: `/path/to/your/project/bin/smart-paste.sh clipboard`
   - Shortcut: `Meta+V`
4. **Emoji Mode**:
   - Name: `Smart Emoji Paste`
   - Command: `/path/to/your/project/bin/smart-paste.sh emoji`
   - Shortcut: `Meta+.`

## Struktur Proyek
- `bin/smart-paste.sh`: Orchestrator utama (Bash).
- `bin/paste_helper.py`: Simulator `Ctrl+V` (Python + evdev).
- `GEMINI.md`: Instruksi konteks asisten AI.

## Lisensi
MIT
