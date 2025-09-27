# termux-starter

**termux-starter** repo pertama yang ku buat untuk starter/mempercepat pengaturan environment termux kalian — cocok buat pemula dan power‑users yang mau setup cepat (tooling, dotfiles ringan, dan opsi profile seperti `dev`, `lite`, dan `kde-vnc`).

> catatan: skrip `install.sh` dibuat aman dan non‑destruktif — file penting akan di-*backup* jika sudah ada.

## Fitur
- One-line installer (bash) untuk paket esensial Termux
- Backup otomatis dotfiles sebelum dibuat / di-*link*
- Profile terpisah: `dev`, `lite`, `kde-vnc` (contoh)
- Dokumentasi singkat jalankan GUI via `proot-distro` + `termux-x11`
- Panduan troubleshooting umum (storage, permission, Android 11+)

## Persyaratan
- Termux terbaru download disini >> https://f-droid.org/packages/com.termux
- Izin storage: jalankan `termux-setup-storage` sekali
- Koneksi internet untuk unduh paket dngn baik
- Opsional: termux-x11 atau VNC client untuk mode GUI jika kapan2 dibutuhkan

## Quick install (one-line)
```bash
pkg update -y && pkg install git curl -y
bash <(curl -fsSL https://raw.githubusercontent.com/syaaikoo/termux-starter/refs/heads/main/install.sh)
```

## Struktur repo (ringkasan)
```
termux-starter/
├─ install.sh
├─ README.md
├─ LICENSE
├─ .gitignore
├─ profiles/
│  ├─ dev.sh
│  └─ lite.sh
└─ docs/
   └─ kde-proot.md
```

## Cara kerja `install.sh` (singkat)
- Mengecek apakah dijalankan di Termux.
- Meminta izin sebelum melakukan tindakan sensitif.
- Menginstall paket esensial (`git`, `python`, `openssh`, `proot-distro`, dsb).
- Membuat direktori `~/dotfiles-termux` dan men-*backup* dotfiles lama (mis. `.bashrc`) ke `~/dotfiles-termux/backups/`.
- Menyediakan opsi profile: `dev` (alat pengembang), `lite` (config ringan), `kde-vnc` (instruksi, tidak otomatis install KDE besar tanpa persetujuan).

## Penggunaan
- Install default:
```bash
bash install.sh
```
- Install dengan profile `dev`:
```bash
bash install.sh --profile dev
```
- Tampilkan bantuan:
```bash
bash install.sh --help
```

## Troubleshooting singkat
- `Permission denied` ketika akses file → jalankan `termux-setup-storage` dan beri izin storage.
- `pkg: command not found` → gunakan Termux, bukan shell Android biasa.
- Jika ingin GUI via `termux-x11`, pastikan `termux-x11` terpasang dan minimal 3GB RAM tersedia untuk pengalaman lebih lancar.

## Contributing
terimakasih kasih sudah mau kontribusi! buka issue atau pr. Sertakan:
- Device (merk + model)
- Versi Android
- Versi Termux (lihat `termux-info`)

## License
MIT — lihat file `LICENSE`.

