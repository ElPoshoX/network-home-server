#!/bin/bash
# Fixed 20-inet6 initialization script for nordlynx
# This replaces the upstream script that tries to use hostnames in ip6tables

set -e

echo "[$(date -Iseconds)] Initializing IPv6 network interfaces..."

# Find all network interfaces (not loopback)
interfaces=$(ip link show | grep -E "^[0-9]+:" | awk -F: '{print $2}' | tr -d ' ' | grep -v "^lo$")

echo "[$(date -Iseconds)] Found interfaces: $interfaces"
echo "[$(date -Iseconds)] Allowing all IPv6 outbound traffic on non-VPN interfaces..."

# Allow ALL IPv6 outbound traffic on physical interfaces (eth0, eth1, eth2, etc)
# This is needed for DNS resolution and API access before WireGuard tunnel is up
# The WireGuard tunnel will take over once it's established
for iface in $interfaces; do
    case "$iface" in
        wg*|tun*|tap*)
            # Skip VPN interfaces - they'll be configured by WireGuard
            echo "[$(date -Iseconds)] Skipping VPN interface: $iface"
            ;;
        *)
            # Allow all IPv6 output on physical/network interfaces
            echo "[$(date -Iseconds)] Allowing IPv6 output on $iface"
            ip6tables -A OUTPUT -o "$iface" -j ACCEPT 2>/dev/null || true
            ;;
    esac
done

echo "[$(date -Iseconds)] IPv6 network interface initialization complete"
