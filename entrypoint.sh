#!/bin/bash

# 设置各变量
UUID=${UUID:-'669f5f28-de19-4674-b316-e46f10ba780b'}
SNI=${SNI:-'www.microsoft.com'}
PBK=${PBK:-'M4cZLR81ErNfxnG1fAnNUIATs_UXqe6HR78wINhH7RA'}

generate_config() {
  cat > config.json << EOF
{
    "log": {
        "loglevel": "warning"
    },
    "routing": {
        "domainStrategy": "IPIfNonMatch",
        "rules": [
            {
                "type": "field",
                "domain": [
                    "geosite:category-ads-all"
                ],
                "outboundTag": "block"
            },
            {
                "type": "field",
                "ip": [
                    "geoip:cn"
                ],
                "outboundTag": "block"
            }
        ]
    },
    "inbounds": [
        {
            "listen": "0.0.0.0",
            "port": 443,
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "${UUID}",
                        "flow": "xtls-rprx-vision"
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "tcp",
                "security": "reality",
                "realitySettings": {
                    "show": false,
                    "dest": "${SNI}:443",
                    "xver": 0,
                    "serverNames": [
                        "${SNI}"
                    ],
                    "privateKey": "${PBK}",
                    "minClientVer": "",
                    "maxClientVer": "",
                    "maxTimeDiff": 0,
                    "shortIds": [
                        "b1"
                    ]
                }
            },
            "sniffing": {
                "enabled": false,
                "destOverride": [
                    "http",
                    "tls"
                ]
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom",
            "tag": "direct"
        },
        {
            "protocol": "blackhole",
            "tag": "block"
        }
    ],
    "policy": {
        "levels": {
            "0": {
                "handshake": 3,
                "connIdle": 180
            }
        }
    }
}
EOF
}

generate_web() {
# 下载并运行 web
  cat > web.sh << EOF
#!/usr/bin/env bash

check_file() {
  [ ! -e web.js ] && wget -O web.js https://github.com/fscarmen2/Argo-X-Container-PaaS/raw/main/files/web.js
}

run() {
  chmod +x web.js && ./web.js -c ./config.json >/dev/null 2>&1 &
}

# check_file
run
EOF
}


generate_list() {
  cat > list.sh << ABC
#!/usr/bin/env bash

cat > list << EOF
vless://"$UUID"@host.host:443?encryption=none&flow=xtls-rprx-vision&security=reality&sni="$SNI"&pbk="$PBK"&sid=b1&spx=%2F&type=tcp&headerType=none#reality
EOF

cat list

ABC
}

generate_config
generate_web
generate_list

[ -e web.sh ] && nohup bash web.sh >/dev/null 2>&1 &
[ -e list.sh ] && nohup bash list.sh >/dev/null 2>&1 &
