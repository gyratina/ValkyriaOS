#!/usr/bin/env bash
set -e

groupadd -f nordvpn
groupadd -f input

# Aggiunge tutti gli utenti con UID >= 1000 ai gruppi nordvpn e input
while IFS=: read -r username _ uid _ _ _ _; do
  if [ -n "$uid" ] && [ "$uid" -ge 1000 ] 2>/dev/null && [ "$username" != "nobody" ]; then
    usermod -aG nordvpn,input "$username" 2>/dev/null || true
  fi
done < /etc/passwd

touch /var/lib/valkyriaos-nordvpn-setup
