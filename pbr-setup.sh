#!/bin/bash
# Minimal PBR helper: route wlan1-sourced traffic via wlan1's gateway. 🎯
# Usage: sudo ./pbr-setup.sh [ifname] [table]
# Defaults: ifname=wlan1, table=100
set -euo pipefail

IF="${1:-wlan1}"
TAB="${2:-100}"

# Get wlanX IPv4 and gateway
IP4=$(ip -4 addr show dev "$IF" | awk '/inet /{print $2}' | head -n1 || true)
SRC="${IP4%%/*}"
GW=$(ip -4 route show dev "$IF" default | awk '{print $3}' | head -n1 || true)

if [[ -z "${SRC:-}" || -z "${GW:-}" ]]; then
  echo "[$IF] not ready (no IPv4 or gateway)"; exit 1
fi

# Clean previous rules/routes
ip rule del from "$SRC/32" table "$TAB" 2>/dev/null || true
ip route flush table "$TAB" 2>/dev/null || true

# Add table and rule for $IF-sourced traffic
ip route add default via "$GW" dev "$IF" table "$TAB"
ip rule add from "$SRC/32" table "$TAB" priority 1000

# Show result
ip addr show dev "$IF"
ip rule show
ip route show table "$TAB"
echo "PBR applied: src $SRC via $GW on $IF (table $TAB)"