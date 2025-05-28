#!/bin/bash

echo "=== V2Ray Network Diagnostics ==="
echo

# Check if containers are running
echo "1. Checking container status..."
docker ps | grep -E "v2ray|caddy"
echo

# Check DNS resolution
echo "2. Testing DNS resolution..."
echo "   - Testing 1.1.1.1..."
dig @1.1.1.1 google.com +short +time=2
echo "   - Testing 8.8.8.8..."
dig @8.8.8.8 google.com +short +time=2
echo "   - Testing local DNS..."
dig google.com +short +time=2
echo

# Check network latency to common servers
echo "3. Testing network latency..."
echo "   - Cloudflare DNS:"
ping -c 4 1.1.1.1 | tail -1
echo "   - Google DNS:"
ping -c 4 8.8.8.8 | tail -1
echo

# Check V2Ray logs
echo "4. Recent V2Ray logs:"
docker logs v2ray --tail 20 2>&1 | grep -E "error|warning|failed"
echo

# Check system resources
echo "5. System resources:"
echo "   - Memory usage:"
free -h | grep -E "Mem:|Swap:"
echo "   - CPU load:"
uptime
echo

# Check network interfaces
echo "6. Network interfaces:"
ip addr show | grep -E "inet |state"
echo

# Test WebSocket connection
echo "7. Testing WebSocket connection to vpn.moeshehab.com..."
curl -I -N -H "Connection: Upgrade" -H "Upgrade: websocket" -H "Sec-WebSocket-Version: 13" -H "Sec-WebSocket-Key: x3JJHMbDL1EzLkh9GBhXDw==" https://vpn.moeshehab.com/ws 2>&1 | head -10
echo

echo "=== Diagnostics complete ===" 