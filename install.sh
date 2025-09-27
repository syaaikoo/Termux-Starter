#!/usr/bin/env bash
# termux-starter: safe installer (non-destructive)
# - backups exist files (timestamp)
# - installs essential packages
# - provides basic profiles in ./profiles/
set -euo pipefail

PROGNAME="$(basename "$0")"
BASEDIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$HOME/dotfiles-termux/backups/$(date +%Y%m%d-%H%M%S)"
DOTFILES_DIR="$HOME/dotfiles-termux"
PROFILE="default"

usage() {
  cat <<EOF
Usage: $PROGNAME [--profile NAME] [--yes] [--help]

Options:
  --profile NAME   pilih profile (default|dev|lite|kde-vnc)
  --yes            non-interactive (anggapan: yes)
  --help           tampilkan pesan ini
EOF
  exit 0
}

# parse args
NONINTERACTIVE=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile) PROFILE="${2:-}"; shift 2;;
    --yes) NONINTERACTIVE=1; shift;;
    --help) usage;;
    *) echo "Unknown arg: $1"; usage;;
  esac
done

confirm() {
  if [[ $NONINTERACTIVE -eq 1 ]]; then
    return 0
  fi
  read -r -p "$1 [y/N]: " resp
  case "$resp" in
    [yY]|[yY][eE][sS]) return 0;;
    *) return 1;;
  esac
}

# ensure running in Termux (simple check)
if ! command -v termux-info >/dev/null 2>&1; then
  echo "Sepertinya ini bukan lingkungan Termux atau termux-api belum terpasang."
  echo "Lanjut? (disarankan jalankan di Termux)."
  if ! confirm "Lanjutkan install di lingkungan ini?"; then
    echo "Batal."
    exit 1
  fi
fi

echo "Mulai pemasangan termux-starter..."
echo "Base dir: $BASEDIR"
echo "Profile: $PROFILE"

# update paket
if confirm "Update paket dan install paket esensial (git, curl, python, proot-distro, openssh)?"; then
  pkg update -y || true
  pkg install -y git curl python proot-distro openssh clang make termux-api || true
fi

# prepare backup
mkdir -p "$BACKUP_DIR"
mkdir -p "$DOTFILES_DIR"

backup_if_exists() {
  local f="$1"
  if [ -e "$f" ]; then
    echo "Backup $f -> $BACKUP_DIR/"
    mkdir -p "$BACKUP_DIR"
    cp -a "$f" "$BACKUP_DIR/"
  fi
}

# safe dotfiles example
for f in "$HOME/.bashrc" "$HOME/.profile" "$HOME/.vimrc" "$HOME/.gitconfig"; do
  if [ -e "$f" ]; then
    backup_if_exists "$f"
  fi
done

# install sample dotfiles if not present
if [ ! -e "$DOTFILES_DIR/.bashrc" ]; then
  cat > "$DOTFILES_DIR/.bashrc" <<'BASHRC'
# sample .bashrc for termux-starter
export EDITOR=vim
export PATH="$HOME/.local/bin:$PATH"
alias ll='ls -alF'
PS1='[\u@\h \W]\$ '
BASHRC
  echo "Created sample dotfile: $DOTFILES_DIR/.bashrc"
fi

# link (create safe symlink)
link_dotfile() {
  local src="$1"
  local dest="$2"
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    echo "File $dest sudah ada. Sudah dibackup di $BACKUP_DIR"
  else
    ln -sf "$src" "$dest"
    echo "Linked $src -> $dest"
  fi
}

link_dotfile "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"
link_dotfile "$DOTFILES_DIR/.profile" "$HOME/.profile" || true

# apply profile specifics
case "$PROFILE" in
  dev)
    echo "Mengaktifkan profile: dev"
    if confirm "Install paket tambahan untuk profile dev (git, nodejs, vim)?"; then
      pkg install -y nodejs vim || true
    fi
    ;;
  lite)
    echo "Mengaktifkan profile: lite (konfigurasi ringan)"
    ;;
  kde-vnc)
    echo "Profile kde-vnc dipilih — ini hanya menambahkan instruksi, tidak akan install KDE otomatis."
    cat > "$BASEDIR/docs/kde-proot.md" <<'MD'
Panduan singkat menjalankan KDE di proot:
1. Install proot-distro: pkg install proot-distro
2. Pasang distro (mis. ubuntu): proot-distro install ubuntu-22.04
3. Login: proot-distro login ubuntu-22.04
4. Install KDE dependencies di dalam container (gunakan instruksi resmi)
5. Jalankan X server di Android (termux-x11 atau VNC)
MD
    echo "Instruksi KDE disimpan di $BASEDIR/docs/kde-proot.md"
    ;;
  *)
    echo "Profile default (tidak ada aksi khusus)."
    ;;
esac

echo "Selesai. Periksa $DOTFILES_DIR untuk konfigurasi, dan $BACKUP_DIR untuk backup file lama."
echo "Jika mau rollback, salin file dari backup ke home manual."
