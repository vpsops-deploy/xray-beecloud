#!/bin/sh
set -eu
PORT="${PORT:-8080}"
UUID="${UUID:-$(cat /proc/sys/kernel/random/uuid 2>/dev/null || uuidgen)}"
WSPATH="${WSPATH:-/ws}"
case "$WSPATH" in /*) ;; *) WSPATH="/$WSPATH" ;; esac
mkdir -p /etc/xray
cat > /etc/xray/config.json <<JSON
{
  "log": {"loglevel": "warning"},
  "inbounds": [{
    "listen": "0.0.0.0",
    "port": ${PORT},
    "protocol": "vless",
    "settings": {
      "clients": [{"id": "${UUID}"}],
      "decryption": "none"
    },
    "streamSettings": {
      "network": "ws",
      "security": "none",
      "wsSettings": {"path": "${WSPATH}"}
    }
  }],
  "outbounds": [{"protocol": "freedom"}]
}
JSON
echo "xray listening on :${PORT} path=${WSPATH}"
exec /usr/local/bin/xray run -c /etc/xray/config.json
