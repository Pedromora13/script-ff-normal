#!/system/bin/sh
# Actualizador PedroModz666 v1.8
URL="https://raw.githubusercontent.com/Pedromora13/script-ff-normal/main/PedroModz666.sh"
OUT="/storage/emulated/0/PedroModz666.sh
dl(){ if command -v curl >/dev/null 2>&1;then curl -s --max-time 15 -o "$2" "$1";elif command -v wget >/dev/null 2>&1;then wget -q --timeout=15 -O "$2" "$1";else busybox wget -q -T 15 -O "$2" "$1";fi;}
dl "$URL" "$OUT" && chmod +x "$OUT" && echo "OK: $OUT" || echo "ERROR"