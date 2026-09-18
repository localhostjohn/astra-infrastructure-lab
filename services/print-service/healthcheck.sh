#!/usr/bin/env bash
set -euo pipefail

QUEUE_NAME="${QUEUE_NAME:-Canon-TR4500}"
PRINTER_IP="${PRINTER_IP:-}"

fail() {
  echo "CRITICAL: $1" >&2
  exit 2
}

warn() {
  echo "WARNING: $1" >&2
}

systemctl is-active --quiet cups || fail "CUPS service is not active"

if ! lpstat -p "$QUEUE_NAME" >/dev/null 2>&1; then
  fail "CUPS queue '$QUEUE_NAME' does not exist"
fi

QUEUE_STATE="$(lpstat -p "$QUEUE_NAME" 2>/dev/null || true)"
if grep -qi 'disabled' <<<"$QUEUE_STATE"; then
  fail "CUPS queue '$QUEUE_NAME' is disabled"
fi

if [[ -n "$PRINTER_IP" ]]; then
  if nc -z -w 3 "$PRINTER_IP" 631; then
    PRINTER_PROTOCOL="IPP"
  elif nc -z -w 3 "$PRINTER_IP" 9100; then
    PRINTER_PROTOCOL="RAW"
    warn "Printer is reachable on RAW 9100 but not IPP 631"
  else
    fail "Printer is not reachable on IPP 631 or RAW 9100"
  fi
else
  PRINTER_PROTOCOL="not-tested"
  warn "PRINTER_IP was not supplied; printer network reachability was not tested"
fi

echo "OK: cups=active queue=$QUEUE_NAME queue_state=enabled printer_protocol=$PRINTER_PROTOCOL"
exit 0
