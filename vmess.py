#!/usr/bin/python3

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

# Convert to JSON and encode to base64
vmess_json = json.dumps(vmess_config, separators=(',', ':'))
vmess_base64 = base64.b64encode(vmess_json.encode()).decode()

# Generate VMess URL
vmess_url = f"vmess://{vmess_base64}"

print("VMess URL:")
print(vmess_url)
print("\nConfiguration details:")
print(json.dumps(vmess_config, indent=2))
