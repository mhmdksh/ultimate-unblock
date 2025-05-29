#!/usr/bin/env bash

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Extract UUID from v2ray.json using jq
UUID=$(jq -r '.inbounds[0].settings.clients[0].id' "$SCRIPT_DIR/v2ray.json")

# Extract domain from Caddyfile (first line before the opening brace)
DOMAIN=$(head -n1 "$SCRIPT_DIR/caddy/Caddyfile" | awk '{print $1}')

# Create VMess configuration JSON
VMESS_CONFIG=$(cat <<EOF
{
  "v": "2",
  "ps": "$DOMAIN",
  "add": "$DOMAIN",
  "port": "443",
  "id": "$UUID",
  "aid": "0",
  "scy": "auto",
  "net": "ws",
  "type": "none",
  "host": "$DOMAIN",
  "path": "/ws",
  "tls": "tls",
  "sni": "$DOMAIN",
  "alpn": "",
  "fp": ""
}
EOF
)

# Remove whitespace and newlines to create compact JSON
VMESS_JSON=$(echo "$VMESS_CONFIG" | jq -c .)

# Base64 encode the JSON
VMESS_BASE64=$(echo -n "$VMESS_JSON" | base64 | tr -d '\n')

# Create the VMess URL
VMESS_URL="vmess://$VMESS_BASE64"

# Display the results
echo '============================================================'
echo 'VMess URL for your V2Ray client:'
echo '============================================================'
echo "$VMESS_URL"
echo '============================================================'
echo
echo 'Configuration details:'
echo "$VMESS_CONFIG" | jq .
echo
echo '============================================================'
echo 'IMPORTANT INSTRUCTIONS:'
echo '1. Copy the VMess URL above'
echo '2. Import it into your V2Ray client (v2rayN, v2rayNG, Shadowrocket, etc.)'
echo '3. In your client settings, make sure to:'
echo '   - Enable "Global Mode" or "Proxy All Traffic"'
echo '   - Disable "Split Tunneling" or "Bypass Local Addresses"'
echo '   - Set routing mode to "Global" not "Rule-based"'
echo '============================================================' 