#!/usr/bin/env bash
set -euo pipefail
umask 077
printf '\033[36m[0/3] Checking dependencies\033[0m\n'
if ! command -v ssh-keygen >/dev/null || ! command -v ssh-add >/dev/null || ! command -v ssh-agent >/dev/null || ! { command -v 7zz >/dev/null || command -v 7z >/dev/null; }; then
  command -v apt-get >/dev/null || { echo 'Automatic dependencies supported on Debian/Ubuntu; install OpenSSH and 7-Zip manually.'; exit 1; }
  elevate=()
  if [[ $EUID != 0 ]]; then elevate=(sudo); fi
  "${elevate[@]}" apt-get update
  "${elevate[@]}" apt-get install -y openssh-client p7zip-full
fi
seven=$(command -v 7zz || command -v 7z)
default="$HOME/Downloads/30na-SSH-Backup.zip"
[[ ! -f "$HOME/30na-SSH-Backup.zip" ]] || default="$HOME/30na-SSH-Backup.zip"
[[ ! -f "./30na-SSH-Backup.zip" ]] || default="./30na-SSH-Backup.zip"
printf "\\033[36m=== 30nA SSH RESTORE v3 ===\\033[0m\\n"
archive=${1:-}
if [[ -z "$archive" ]]; then
  read -r -p "ZIP path [$default]: " archive
  archive=${archive:-$default}
fi
[[ -f "$archive" ]] || { echo 'ZIP not found'; exit 1; }
archive=$(realpath -- "$archive")
dir="$HOME/.ssh"
[[ ! -L "$dir" ]] || { echo 'Refusing symlink .ssh'; exit 1; }
mkdir -p "$dir"
chmod 700 "$dir"
tmp=$(mktemp -d "$dir/.30na-restore.XXXXXXXX")
trap 'rm -rf -- "$tmp"' EXIT
printf '\033[33m[1/3] ZIP password (not SSH passphrase)\033[0m\n'
if ! "$seven" e -y "-o$tmp" -- "$archive" 30na_windows 30na_windows.pub </dev/tty; then
  printf '\033[31mExtraction failed. Check ZIP password or archive integrity. No keys installed.\033[0m\n' >&2
  exit 1
fi
printf '\033[36m[2/3] Validating key pair\033[0m\n'
for name in 30na_windows 30na_windows.pub; do
  [[ -f "$tmp/$name" && ! -L "$tmp/$name" ]] || { echo 'Missing or invalid archive member'; exit 1; }
  chmod 600 "$tmp/$name"
done
derived=$(ssh-keygen -y -f "$tmp/30na_windows" | awk '{print $1" "$2}')
stored=$(awk 'NR==1 {print $1" "$2}' "$tmp/30na_windows.pub")
[[ "$stored" == ssh-ed25519\ * && "$derived" == "$stored" ]] || { echo 'Key pair mismatch'; exit 1; }
ssh-keygen -lf "$tmp/30na_windows.pub"
for name in 30na_windows 30na_windows.pub; do
  [[ ! -L "$dir/$name" ]] || { echo 'Refusing symlink destination'; exit 1; }
done
if [[ -e "$dir/30na_windows" || -e "$dir/30na_windows.pub" ]]; then
  cmp -s "$tmp/30na_windows" "$dir/30na_windows" && cmp -s "$tmp/30na_windows.pub" "$dir/30na_windows.pub" || { echo 'Existing key differs or is incomplete; no overwrite'; exit 1; }
else
  ln -- "$tmp/30na_windows" "$dir/30na_windows"
  if ! ln -- "$tmp/30na_windows.pub" "$dir/30na_windows.pub"; then
    rm -- "$dir/30na_windows"
    exit 1
  fi
fi
chmod 600 "$dir/30na_windows" "$dir/30na_windows.pub"
printf '\033[32m[3/3] Key restored successfully.\033[0m\n'
echo 'In your current shell run:'
echo 'eval "$(ssh-agent -s)"; ssh-add ~/.ssh/30na_windows'
echo 'Then: ssh root@VPS_IP'
