#!/usr/bin/env bash
set -euo pipefail
umask 077
command -v ssh-keygen >/dev/null || { echo 'Install openssh-client first'; exit 1; }
seven=$(command -v 7zz || command -v 7z) || { echo 'Install 7zip or p7zip-full first'; exit 1; }
default="$HOME/Downloads/30na-SSH-Backup.zip"
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
echo 'Enter ZIP password at the 7-Zip prompt.'
"$seven" e -p -y "-o$tmp" -- "$archive" 30na_windows 30na_windows.pub
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
echo 'Key restored. In your current shell run:'
echo 'eval "$(ssh-agent -s)"; ssh-add ~/.ssh/30na_windows'
echo 'Then: ssh root@VPS_IP'
