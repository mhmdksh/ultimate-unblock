#!/bin/bash

echo "=== V2Ray Connection Test ==="
echo

# Test if V2Ray is running
echo "1. Checking V2Ray container status..."
docker ps | grep v2ray
echo

# Test direct connection to check your real IP
echo "2. Your real IP (without VPN):"
curl -s https://api.ipify.org
echo
echo

# Check V2Ray logs for routing
echo "3. Recent V2Ray routing summary:"
docker logs v2ray --tail 100 2>&1 | grep -E "\[direct\]|\[proxy\]|\[blocked\]" | awk '{print $NF}' | sort | uniq -c
echo

# Test WebSocket connection
echo "4. Testing WebSocket connection to your server:"
curl -I -N \
  -H "Connection: Upgrade" \
  -H "Upgrade: websocket" \
  -H "Host: vpn.moeshehab.com" \
  -H "Sec-WebSocket-Version: 13" \
  -H "Sec-WebSocket-Key: x3JJHMbDL1EzLkh9GBhXDw==" \
  https://vpn.moeshehab.com/ws 2>&1 | head -20
echo

echo "=== Test complete ==="
echo
echo "IMPORTANT: If all connections show [direct], your client is NOT configured correctly."
echo "You need to:"
echo "1. Import the VMess URL into your V2Ray client"
echo "2. Enable 'Route all traffic through VPN' in your client settings"
echo "3. Make sure your client is actually connecting through the VMess protocol" 