#!/usr/bin/env python3
import base64
import json
from pathlib import Path

path = Path(__file__).parent

config_file = open(str(path.joinpath('v2ray.json')), 'r', encoding='utf-8')
config = json.load(config_file)

caddy = open(str(path.joinpath('caddy/Caddyfile')), 'r', encoding='utf-8').read()

uuid = config['inbounds'][0]['settings']['clients'][0]['id']
domain = caddy[:caddy.find(' {')]

# VMess configuration
vmess_config = {
    "v": "2",
    "ps": domain,
    "add": domain,
    "port": "443",
    "id": uuid,
    "aid": "0",
    "scy": "auto",
    "net": "ws",
    "type": "none",
    "host": domain,
    "path": "/ws",
    "tls": "tls",
    "sni": domain,
    "alpn": "",
    "fp": ""
}

vmess_json = json.dumps(vmess_config, separators=(',', ':'))
vmess_base64 = base64.b64encode(vmess_json.encode()).decode()
vmess_url = f'vmess://{vmess_base64}'

print('=' * 60)
print('VMess URL for your V2Ray client:')
print('=' * 60)
print(vmess_url)
print('=' * 60)
print('\nConfiguration details:')
print(json.dumps(vmess_config, indent=2))
print('\n' + '=' * 60)
print('IMPORTANT INSTRUCTIONS:')
print('1. Copy the VMess URL above')
print('2. Import it into your V2Ray client (v2rayN, v2rayNG, Shadowrocket, etc.)')
print('3. In your client settings, make sure to:')
print('   - Enable "Global Mode" or "Proxy All Traffic"')
print('   - Disable "Split Tunneling" or "Bypass Local Addresses"')
print('   - Set routing mode to "Global" not "Rule-based"')
print('=' * 60) 