#!/usr/bin/env bash
set -euo pipefail
umask 077
fail(){ printf '\033[31mERROR: %s\033[0m\n' "$*" >&2; exit 1; }
step(){ printf '\033[36m%s\033[0m\n' "$*"; }
step '=== 30nA SSH LOCAL SETUP v6 ==='
[[ $# == 0 ]] || fail 'No arguments supported'
clear || true
step '[1/4] Installing prerequisites'
elevate=()
if [[ $EUID != 0 ]]; then elevate=(sudo); fi
"${elevate[@]}" apt-get update </dev/tty
"${elevate[@]}" apt-get install -y openssh-client </dev/tty
step '[2/4] Checking extracted keys'
dir="$HOME/.ssh"
[[ ! -L "$dir" ]] || fail '.ssh is a symlink'
mkdir -p "$dir"
chmod 700 "$dir"
src="$HOME/30na_windows"
dest="$dir/id_ed25519"
for p in "$src" "$src.pub" "$dest" "$dest.pub"; do
  [[ ! -L "$p" ]] || fail "Symlink not allowed: $p"
done
[[ -f "$src" && -f "$src.pub" ]] || fail 'Run unzip.sh first; extracted key pair missing or incomplete.'
chmod 600 "$src"
chmod 644 "$src.pub"
derived=$(ssh-keygen -y -P '' -f "$src") || fail 'Private key invalid or passphrase-protected; unattended setup requires a separate secure unlocking strategy'
actual=$(printf '%s\n' "$derived" | awk 'NR==1{print $1" "$2}')
expected=$(awk 'NR==1{print $1" "$2}' "$src.pub")
[[ "$expected" == ssh-ed25519\ * && "$actual" == "$expected" ]] || fail 'Key pair mismatch'
printf 'Private key: %s (contents hidden)\n' "$src"
printf 'Public key: %s\n' "$src.pub"
cat "$src.pub"
ssh-keygen -lf "$src.pub"
step '[3/4] Installing standard SSH identity'
if [[ -e "$dest" || -e "$dest.pub" ]]; then
  [[ -f "$dest" && -f "$dest.pub" ]] || fail 'Existing standard key pair incomplete; no overwrite'
  existing=$(ssh-keygen -y -P '' -f "$dest") || fail 'Existing private key cannot be validated; no overwrite'
  [[ "$(printf '%s\n' "$existing" | awk 'NR==1{print $1" "$2"}')" == "$expected" && "$(awk 'NR==1{print $1" "$2"}' "$dest.pub")" == "$expected" ]] || fail 'Different standard SSH identity already exists; no overwrite'
else
  (set -o noclobber; cat "$src" > "$dest") || fail 'Cannot install private key'
  if ! (set -o noclobber; cat "$src.pub" > "$dest.pub"); then rm -f -- "$dest"; fail 'Cannot install public key'; fi
fi
chmod 600 "$dest"
chmod 644 "$dest.pub"
step '[4/4] Checking SSH client identity'
ssh -G -o BatchMode=yes localhost 2>/dev/null | grep '^identityfile ' || true
printf '\033[32mREADY: %s\033[0m\n' "$dest"
printf '%s\n' 'Connect: ssh root@VPS_IP' 'New password VPS: ssh-copy-id -i ~/.ssh/id_ed25519.pub root@VPS_IP' 'No Agent required for this unencrypted key. Existing authorized_keys, known_hosts, sshd and tunnels were not changed.'
