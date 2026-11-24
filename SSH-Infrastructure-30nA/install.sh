#!/usr/bin/env bash
set -euo pipefail
umask 077
[[ $# == 1 && -f "$1" ]] || { echo "Usage: bash install.sh PUBLIC_KEY_FILE" >&2; exit 2; }
mapfile -t lines < "$1"
[[ ${#lines[@]} == 1 ]] || { echo "Expected one public key line" >&2; exit 2; }
key=${lines[0]%$'\r'}
[[ "$key" == ssh-ed25519\ * ]] || { echo "Expected ED25519 public key" >&2; exit 2; }
printf '%s\n' "$key" | ssh-keygen -lf -
dir="$HOME/.ssh"
file="$dir/authorized_keys"
[[ ! -L "$dir" && ! -L "$file" ]] || { echo "Refusing symlink" >&2; exit 1; }
mkdir -p "$dir"
chmod 700 "$dir"
touch "$file"
chmod 600 "$file"
backup=$(mktemp "$dir/authorized_keys.backup.XXXXXXXX")
cp -p "$file" "$backup"
if ! grep -Fxq -- "$key" "$file"; then
  printf '\n%s\n' "$key" >> "$file"
fi
echo "Backup: $backup"
ssh-keygen -lf "$file"
