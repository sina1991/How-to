#!/usr/bin/env bash
set -euo pipefail
main() {
umask 077
[[ -t 1 && -r /dev/tty ]] || { echo 'Interactive terminal required'; return 1; }
clear || true
echo '=== 30nA KEY EXTRACTION ==='
local -a elevate=()
if [[ $EUID != 0 ]]; then elevate=(sudo); fi
"${elevate[@]}" apt-get update </dev/tty
"${elevate[@]}" apt-get install -y openssh-client p7zip-full </dev/tty
local key="$HOME/30na_windows" archive="$HOME/30na-SSH-Backup.zip" answer
for p in "$key" "$key.pub"; do
  [[ ! -L "$p" && ( ! -e "$p" || -f "$p" ) ]] || { echo "Unsafe path: $p"; return 1; }
done
validate() {
  local k="$1" derived expected
  [[ -f "$k" && -f "$k.pub" && ! -L "$k" && ! -L "$k.pub" ]] || return 1
  chmod 600 "$k" && chmod 644 "$k.pub" || return 1
  derived=$(ssh-keygen -y -P '' -f "$k") || return 1
  expected=$(awk 'NR==1{print $1" "$2}' "$k.pub")
  [[ "$expected" == ssh-ed25519\ * && "$(awk '{print $1" "$2}' <<< "$derived")" == "$expected" ]] && ssh-keygen -lf "$k.pub"
}
show() {
  printf '\nPublic key:\n'; cat "$1.pub"
  printf '\nPrivate key: %s (hidden by default)\n' "$1"
  read -r -p 'Reveal private key on this terminal? [y/N]: ' answer </dev/tty
  if [[ "$answer" == [yY] ]]; then cat "$1"; fi
}
if validate "$key"; then
  show "$key"
  read -r -p 'Confirm existing keys? [y/N]: ' answer </dev/tty
  if [[ "$answer" == [yY] ]]; then echo 'KEYS READY'; return 0; fi
fi
[[ -f "$archive" ]] || { echo "ZIP not found: $archive"; return 1; }
tmp=$(mktemp -d "$HOME/.30na-extract.XXXXXXXX")
trap 'rm -rf -- "$tmp"' EXIT
echo 'Enter ZIP password:'
7z e -y "-o$tmp" -- "$archive" 30na_windows 30na_windows.pub </dev/tty
validate "$tmp/30na_windows" || { echo 'Invalid extracted pair; existing keys unchanged'; return 1; }
# Preserve previous files in a private backup before replacement.
for p in "$key" "$key.pub"; do
  if [[ -f "$p" ]]; then
    local backup
    backup=$(mktemp "$HOME/.30na-key-backup.XXXXXXXX")
    cat "$p" > "$backup"
    printf 'Previous file backed up: %s\n' "$backup"
  fi
done
mv -fT "$tmp/30na_windows" "$key"
mv -fT "$tmp/30na_windows.pub" "$key.pub"
show "$key"
echo 'KEYS READY'
rm -rf -- "$tmp"
trap - EXIT
}
main "$@"
