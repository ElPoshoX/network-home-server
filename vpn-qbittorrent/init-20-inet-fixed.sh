#!/bin/bash
# Fixed 20-inet initialization script for nordlynx
# This replaces the upstream script that tries to use hostnames in iptables

set -e

echo "[$(date -Iseconds)] Initializing network interfaces..."

# Find the default interface
default_iface=$(ip route | grep "^default" | awk '{print $5}' | head -1)
if [ -z "$default_iface" ]; then
    default_iface="eth0"
fi

echo "[$(date -Iseconds)] Using interface: $default_iface"

# Allow DNS and NordVPN API traffic on the default interface
# This must happen BEFORE the firewall restricts all traffic
echo "[$(date -Iseconds)] Configuring firewall rules for DNS and NordVPN API..."

# Allow DNS (UDP and TCP port 53)
iptables -A OUTPUT -o "$default_iface" -p udp --dport 53 -j ACCEPT 2>/dev/null || true
iptables -A OUTPUT -o "$default_iface" -p tcp --dport 53 -j ACCEPT 2>/dev/null || true

# Allow NordVPN API (use IP ranges instead of hostname)
# api.nordvpn.com resolves to IP ranges: 45.137.184.0/24 and 45.137.185.0/24
iptables -A OUTPUT -o "$default_iface" -d 45.137.184.0/24 -p tcp --dport 443 -j ACCEPT 2>/dev/null || true
iptables -A OUTPUT -o "$default_iface" -d 45.137.185.0/24 -p tcp --dport 443 -j ACCEPT 2>/dev/null || true

echo "[$(date -Iseconds)] Network interface initialization complete"
