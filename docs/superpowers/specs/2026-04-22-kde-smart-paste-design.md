# Design Spec: KDE Smart Paste (Wayland)

## 1. Goal
Implementasi behavior "Select to Paste" di KDE Plasma 6 (Wayland) untuk Clipboard Manager dan Emoji Selector, meniru behavior Windows (Win+V / Win+.).

## 2. Approach
Menggunakan `ydotool` sebagai virtual input device untuk mensimulasikan penekanan tombol `Ctrl+V` setelah mendeteksi perubahan pada clipboard yang dipicu oleh selector KDE.

## 3. Architecture & Components
- **Input Simulator:** `ydotool` (memerlukan `ydotoold` daemon).
- **Orchestrator:** Bash script (`smart-paste.sh`) yang mengelola logika deteksi dan eksekusi.
- **Trigger:** Custom Global Shortcut di KDE Plasma.
- **System Integration:** Udev rules untuk akses `/dev/uinput` tanpa root.

## 4. Logical Flow
1. Skrip dijalankan via shortcut.
2. Simpan isi clipboard saat ini (`old_content`).
3. Munculkan UI Clipboard/Emoji KDE via DBus.
4. Loop deteksi (max 10s):
   - Cek isi clipboard setiap 100ms.
   - Jika `current_content` != `old_content`:
     - Tunggu 50-100ms (window focus transition).
     - Jalankan `ydotool key 29:1 47:1 47:0 29:0` (Ctrl+V).
     - Exit.
5. Jika timeout, exit tanpa aksi.

## 5. Implementation Steps
1. Install `ydotool` (via pacman).
2. Konfigurasi `udev` & grup user agar bisa akses `uinput`.
3. Enable & Start `ydotoold` service.
4. Buat skrip `smart-paste.sh`.
5. Daftarkan shortcut di System Settings KDE.

## 6. Success Criteria
- Memilih item dari clipboard manager langsung menempelkan teks ke area input yang aktif.
- Skrip tidak menyebabkan loop paste yang tidak diinginkan.
- Performa ringan dan tidak mengganggu copy-paste manual biasa.
