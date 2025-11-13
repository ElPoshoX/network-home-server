#!/bin/bash
# Fixed 20-inet initialization script for nordlynx
# This replaces the upstream script that tries to use hostnames in iptables

set -e

echo "[$(date -Iseconds)] Initializing network interfaces..."

# Find all network interfaces (not loopback)
interfaces=$(ip link show | grep -E "^[0-9]+:" | awk -F: '{print $2}' | tr -d ' ' | grep -v "^lo$")

echo "[$(date -Iseconds)] Found interfaces: $interfaces"
echo "[$(date -Iseconds)] Allowing all outbound traffic on non-VPN interfaces for DNS and API..."

# Allow ALL outbound traffic on physical interfaces (eth0, eth1, eth2, etc)
# This is needed for DNS resolution and API access before WireGuard tunnel is up
# The WireGuard tunnel will take over once it's established
for iface in $interfaces; do
    case "$iface" in
        wg*|tun*|tap*)
            # Skip VPN interfaces - they'll be configured by WireGuard
            echo "[$(date -Iseconds)] Skipping VPN interface: $iface"
            ;;
        *)
            # Allow all output on physical/network interfaces
            echo "[$(date -Iseconds)] Allowing all output on $iface"
            iptables -A OUTPUT -o "$iface" -j ACCEPT 2>/dev/null || true
            ip6tables -A OUTPUT -o "$iface" -j ACCEPT 2>/dev/null || true
            ;;
    esac
done

# Ensure DNS is properly configured
echo "[$(date -Iseconds)] Ensuring DNS configuration..."
if ! grep -q "nameserver" /etc/resolv.conf 2>/dev/null; then
    echo "nameserver 8.8.8.8" > /etc/resolv.conf
    echo "nameserver 8.8.4.4" >> /etc/resolv.conf
    echo "[$(date -Iseconds)] Added Google DNS to /etc/resolv.conf"
fi

echo "[$(date -Iseconds)] Network interface initialization complete"
