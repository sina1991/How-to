#!/usr/bin/env bash
set -euo pipefail
main() {
umask 077
fail(){ printf 'ERROR: %s\n' "$*" >&2; exit 1; }
step(){ printf '\n%s\n' "$*"; }
[[ $# == 0 ]] || fail 'No arguments supported'
[[ $EUID == 0 ]] || fail 'Run as root to configure incoming root SSH'
if [[ -t 1 && -n "$TERM" && "$TERM" != dumb ]]; then clear; fi
step '=== 30nA SSH LOCAL SETUP v7 ==='
step '[1/5] Installing prerequisites'
apt-get update </dev/null
DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-client openssh-server </dev/null
step '[2/5] Validating extracted keys'
dir="$HOME/.ssh"
src="$HOME/30na_windows"
dest="$dir/id_ed25519"
auth="$dir/authorized_keys"
[[ ! -L "$dir" ]] || fail '.ssh is a symlink'
mkdir -p "$dir"
chmod 700 "$dir"
for p in "$src" "$src.pub" "$dest" "$dest.pub" "$auth"; do
  [[ ! -L "$p" && ( ! -e "$p" || -f "$p" ) ]] || fail "Unsafe path: $p"
done
[[ -f "$src" && -f "$src.pub" ]] || fail 'Run unzip.sh first'
chmod 600 "$src"
chmod 644 "$src.pub"
key_fields(){ awk 'NR==1 {print $1, $2}'; }
derived=$(ssh-keygen -y -P '' -f "$src") || fail 'Invalid or encrypted private key'
expected=$(key_fields < "$src.pub")
[[ "$expected" == ssh-ed25519\ * && "$(key_fields <<< "$derived")" == "$expected" ]] || fail 'Key pair mismatch'
cat "$src.pub"
ssh-keygen -lf "$src.pub"
step '[3/5] Installing outgoing identity'
if [[ -e "$dest" || -e "$dest.pub" ]]; then
  [[ -f "$dest" && -f "$dest.pub" ]] || fail 'Existing identity incomplete; no overwrite'
  chmod 600 "$dest"
  existing=$(ssh-keygen -y -P '' -f "$dest") || fail 'Existing private key invalid; no overwrite'
  [[ "$(key_fields <<< "$existing")" == "$expected" && "$(key_fields < "$dest.pub")" == "$expected" ]] || fail 'Existing identity differs; no overwrite'
else
  (set -o noclobber; cat "$src" > "$dest") || fail 'Cannot install private key'
  if ! (set -o noclobber; cat "$src.pub" > "$dest.pub"); then rm -f -- "$dest"; fail 'Cannot install public key'; fi
fi
chmod 600 "$dest"
chmod 644 "$dest.pub"
step '[4/5] Authorizing incoming identity'
touch "$auth"
chmod 600 "$auth"
if ! awk -v key="$expected" '{for(i=1;i<NF;i++) if($i" "$(i+1)==key && $1=="ssh-ed25519") found=1} END{exit !found}' "$auth"; then
  printf '\n%s\n' "$(cat "$src.pub")" >> "$auth"
fi
step '[5/5] Configuring SSH server'
cfg=/etc/ssh/sshd_config
[[ -f "$cfg" && ! -L "$cfg" ]] || fail 'Invalid sshd_config path'
mkdir -p /run/sshd
/usr/sbin/sshd -t
backup=$(mktemp /etc/ssh/.30na-sshd-backup.XXXXXXXX)
cp -p "$cfg" "$backup"
tmp=$(mktemp /etc/ssh/.30na-sshd-config.XXXXXXXX)
# First global value wins. Keep all existing settings and Match blocks.
{
  printf '%s\n' '# BEGIN 30nA SSH authentication' 'PermitRootLogin yes' 'PubkeyAuthentication yes' 'PasswordAuthentication yes' 'AuthenticationMethods any' 'AuthorizedKeysFile .ssh/authorized_keys .ssh/authorized_keys2' '# END 30nA SSH authentication'
  awk '/^# BEGIN 30nA SSH authentication$/{skip=1;next} /^# END 30nA SSH authentication$/{skip=0;next} !skip' "$cfg"
} > "$tmp"
chmod --reference="$cfg" "$tmp"
chown --reference="$cfg" "$tmp"
if ! /usr/sbin/sshd -t -f "$tmp"; then rm -f "$tmp"; fail 'Candidate SSH configuration invalid; original preserved'; fi
mv -fT "$tmp" "$cfg"
check_config(){
  local effective
  effective=$(/usr/sbin/sshd -T -C user=root,host=localhost,addr=127.0.0.1) || return 1
  grep -Fxq 'permitrootlogin yes' <<< "$effective" &&
  grep -Fxq 'pubkeyauthentication yes' <<< "$effective" &&
  grep -Fxq 'passwordauthentication yes' <<< "$effective" &&
  grep -Fxq 'authenticationmethods any' <<< "$effective" &&
  grep -Eq '^authorizedkeysfile .*\.ssh/authorized_keys( |$)' <<< "$effective"
}
if ! /usr/sbin/sshd -t || ! check_config; then
  cp -p "$backup" "$cfg"
  fail 'Effective SSH settings differ; original restored'
fi
if systemctl is-active --quiet ssh.service; then
  if ! systemctl reload ssh.service; then
    cp -p "$backup" "$cfg"
    systemctl reload ssh.service
    fail 'Reload failed; original restored'
  fi
else
  if ! systemctl start ssh.service; then cp -p "$backup" "$cfg"; fail 'SSH start failed; original restored'; fi
fi
systemctl is-active --quiet ssh.service || fail 'SSH service not active'
printf '\nREADY: Incoming and outgoing SSH configured\n'
printf 'SSH configuration backup: %s\n' "$backup"
printf '%s\n' 'Public key: enabled' 'Password: enabled (existing account password unchanged)' 'Existing tunnels: not modified' 'Remote connectivity: test from a separate session'
}
main "$@"
