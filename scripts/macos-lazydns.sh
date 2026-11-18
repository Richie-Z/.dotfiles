#!/usr/bin/env bash
NODE=192.168.18.43
# shellcheck source=lazydns-hosts.sh
. "$(dirname "${BASH_SOURCE[0]}")/lazydns-hosts.sh"
B="# BEGIN homelab"
E="# END homelab"

sudo sed -i '' "/$B/,/$E/d" /etc/hosts
if nc -z -G 1 "$NODE" 443 2>/dev/null; then
  printf '%s\n%s %s\n%s\n' "$B" "$NODE" "${ING[*]}" "$E" | sudo tee -a /etc/hosts >/dev/null
fi
sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder
