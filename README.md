# KDE Smart Paste (Wayland)

Solusi "Select to Paste" otomatis untuk KDE Plasma 6 di Wayland. Skrip ini meniru perilaku Windows (`Meta+V` / `Meta+.`) di mana memilih item dari Clipboard Manager atau Emoji Selector akan langsung melakukan *paste* (`Ctrl+V`) ke aplikasi yang sedang aktif dengan latensi sub-50ms.

## Fitur
- **Ultra Low Latency (< 50ms)**: Menggunakan daemon background virtual keyboard (`smart_paste_daemon`) via Unix Domain Socket.
- **Auto-Paste Clipboard**: Pilih item dari history clipboard, langsung menempel.
- **Auto-Paste Emoji**: Pilih emoji, jendela emoji tertutup, dan emoji langsung menempel.
- **Wayland Native**: Didesain khusus untuk KDE Plasma 6 di Wayland.

## Struktur Komponen
1. **`smart_paste_daemon`**: Daemon background C yang menjaga virtual keyboard `/dev/uinput` tetap terbuka dan siap memicu `Ctrl+V` dalam 1 milidetik via `/tmp/smart_paste.sock`.
2. **`paste_trigger`**: Binary C kecil untuk mengirim sinyal ke daemon secara instan (~1ms).
3. **`smart-paste.sh`**: Orchestrator utama yang menampilkan menu KDE dan mendengarkan event perubahan clipboard.

## Systemd Service
Daemon berjalan otomatis saat login:
```bash
systemctl --user enable --now smart-paste-daemon.service
```
