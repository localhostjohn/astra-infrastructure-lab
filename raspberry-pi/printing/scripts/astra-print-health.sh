#!/usr/bin/env bash
set -u

QUEUE="Canon-TR4500"
USB_ID="04a9:1854"
TAG="astra-print-health"

log() {
  logger -t "$TAG" "$*"
  printf '%s\n' "$*"
}

if ! systemctl is-active --quiet cups; then
  log "cups.service is not active; attempting restart."
  systemctl restart cups
fi

if ! systemctl is-active --quiet ipp-usb; then
  log "ipp-usb.service is not active; attempting restart."
  systemctl restart ipp-usb
fi

if ! lsusb -d "$USB_ID" >/dev/null 2>&1; then
  log "Canon TR4500 USB device ($USB_ID) is not currently detected."
  exit 0
fi

if ! lpstat -p "$QUEUE" 2>/dev/null | grep -q "enabled"; then
  log "$QUEUE is disabled or unavailable; attempting to enable it."
  cupsenable "$QUEUE" || true
fi

if ! lpstat -a "$QUEUE" 2>/dev/null | grep -q "accepting requests"; then
  log "$QUEUE is not accepting jobs; attempting cupsaccept."
  cupsaccept "$QUEUE" || true
fi

if ! lpstat -v "$QUEUE" 2>/dev/null | grep -q "ipp://localhost:60000/ipp/print"; then
  log "WARNING: $QUEUE device URI differs from expected ipp-usb endpoint. No automatic queue reconfiguration performed."
fi

log "Print health check completed."
