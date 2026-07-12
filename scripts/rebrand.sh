#!/usr/bin/env bash
set -euo pipefail

echo "==> STK VPN rebranding started"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

APP_NAME="STK VPN"
APP_NAME_PLAIN="STK VPN"
APP_NAME_DASHED="STK-VPN"
APP_NAME_LOWER="stk vpn"
DART_PACKAGE_NAME="stk_vpn"
ANDROID_APP_ID="com.stkvpn.app"

replace_in_file() {
  local file="$1"
  local from="$2"
  local to="$3"

  if [ -f "$file" ]; then
    python3 - "$file" "$from" "$to" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
old = sys.argv[2]
new = sys.argv[3]

data = path.read_text(encoding="utf-8")
if old in data:
    path.write_text(data.replace(old, new), encoding="utf-8")
PY
  fi
}

safe_replace_many() {
  local search="$1"
  local replace="$2"

  while IFS= read -r -d '' file; do
    case "$file" in
      */.git/*|*/build/*|*/.dart_tool/*|*/.idea/*|*/.gradle/*|*/ios/Pods/*|*/macos/Pods/*)
        continue
        ;;
    esac

    python3 - "$file" "$search" "$replace" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
old = sys.argv[2]
new = sys.argv[3]

try:
    data = path.read_text(encoding="utf-8")
except Exception:
    raise SystemExit(0)

if old in data:
    path.write_text(data.replace(old, new), encoding="utf-8")
PY
  done < <(find . -type f \
    ! -path './.git/*' \
    ! -path './build/*' \
    ! -path './.dart_tool/*' \
    ! -path './.idea/*' \
    ! -path './.gradle/*' \
    ! -path './ios/Pods/*' \
    ! -path './macos/Pods/*' \
    -print0)
}

echo "==> Updating pubspec.yaml"
replace_in_file "pubspec.yaml" "name: hiddify" "name: ${DART_PACKAGE_NAME}"
replace_in_file "pubspec.yaml" "description: Cross Platform Multi Protocol Proxy Frontend." "description: STK VPN personal build."

echo "==> Updating Android applicationId/namespace references"
safe_replace_many "app.hiddify.com" "${ANDROID_APP_ID}"
safe_replace_many "com.hiddify.hiddify" "${ANDROID_APP_ID}"
safe_replace_many "com.hiddify.app" "${ANDROID_APP_ID}"

echo "==> Updating visible product names"
safe_replace_many "Hiddify-Android" "${APP_NAME_DASHED}-Android"
safe_replace_many "Hiddify-iOS" "${APP_NAME_DASHED}-iOS"
safe_replace_many "Hiddify-Windows" "${APP_NAME_DASHED}-Windows"
safe_replace_many "Hiddify-Linux" "${APP_NAME_DASHED}-Linux"
safe_replace_many "Hiddify-MacOS" "${APP_NAME_DASHED}-MacOS"
safe_replace_many "Hiddify Proxy & VPN" "${APP_NAME}"
safe_replace_many "Hiddify Proxy VPN" "${APP_NAME}"
safe_replace_many "Hiddify Next" "${APP_NAME}"
safe_replace_many "Hiddify" "${APP_NAME}"

echo "==> Updating lowercase references where safe"
safe_replace_many "hiddify-next" "stk-vpn"
safe_replace_many "hiddify_app" "stk_vpn"
safe_replace_many "hiddify-app" "stk-vpn"

echo "==> Rebranding finished"
