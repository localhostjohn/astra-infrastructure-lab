#!/usr/bin/env bash
set -u

QUEUE="Canon-TR4500"
USB_ID="04a9:1854"
EXPECTED_URI="ipp://localhost:60000/ipp/print"
METRICS_DIR="/opt/node-exporter/textfile"
METRICS_FILE="$METRICS_DIR/astra_print.prom"
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

USB_PRESENT=1
if ! lsusb -d "$USB_ID" >/dev/null 2>&1; then
  USB_PRESENT=0
  log "Canon TR4500 USB device ($USB_ID) is not currently detected."
fi

if ! lpstat -p "$QUEUE" 2>/dev/null | grep -q "enabled"; then
  log "$QUEUE is disabled or unavailable; attempting to enable it."
  cupsenable "$QUEUE" || true
fi

if ! lpstat -a "$QUEUE" 2>/dev/null | grep -q "accepting requests"; then
  log "$QUEUE is not accepting jobs; attempting cupsaccept."
  cupsaccept "$QUEUE" || true
fi

CUPS_UP=0
systemctl is-active --quiet cups && CUPS_UP=1

IPP_USB_UP=0
systemctl is-active --quiet ipp-usb && IPP_USB_UP=1

QUEUE_ENABLED=0
lpstat -p "$QUEUE" 2>/dev/null | grep -q "enabled" && QUEUE_ENABLED=1

ACCEPTING_JOBS=0
lpstat -a "$QUEUE" 2>/dev/null | grep -q "accepting requests" && ACCEPTING_JOBS=1

URI_OK=0
if lpstat -v "$QUEUE" 2>/dev/null | grep -q "$EXPECTED_URI"; then
  URI_OK=1
else
  log "WARNING: $QUEUE device URI differs from expected ipp-usb endpoint. No automatic queue reconfiguration performed."
fi

PENDING_JOBS="$(lpstat -W not-completed -o "$QUEUE" 2>/dev/null | wc -l | tr -d ' ')"
PENDING_JOBS="${PENDING_JOBS:-0}"

mkdir -p "$METRICS_DIR"
TMP_FILE="$(mktemp "$METRICS_DIR/astra_print.prom.XXXXXX")"

cat > "$TMP_FILE" <<EOF
# HELP astra_print_cups_up Whether the CUPS service is active (1=yes, 0=no).
# TYPE astra_print_cups_up gauge
astra_print_cups_up $CUPS_UP
# HELP astra_print_ipp_usb_up Whether ipp-usb is active (1=yes, 0=no).
# TYPE astra_print_ipp_usb_up gauge
astra_print_ipp_usb_up $IPP_USB_UP
# HELP astra_print_usb_present Whether the Canon TR4500 USB device is detected (1=yes, 0=no).
# TYPE astra_print_usb_present gauge
astra_print_usb_present $USB_PRESENT
# HELP astra_print_queue_enabled Whether the Canon CUPS queue is enabled (1=yes, 0=no).
# TYPE astra_print_queue_enabled gauge
astra_print_queue_enabled $QUEUE_ENABLED
# HELP astra_print_accepting_jobs Whether the Canon CUPS queue is accepting jobs (1=yes, 0=no).
# TYPE astra_print_accepting_jobs gauge
astra_print_accepting_jobs $ACCEPTING_JOBS
# HELP astra_print_uri_ok Whether the queue points to the expected ipp-usb endpoint (1=yes, 0=no).
# TYPE astra_print_uri_ok gauge
astra_print_uri_ok $URI_OK
# HELP astra_print_pending_jobs Number of jobs currently not completed in the Canon queue.
# TYPE astra_print_pending_jobs gauge
astra_print_pending_jobs $PENDING_JOBS
# HELP astra_print_health_last_run_unixtime Unix timestamp of the latest health-check run.
# TYPE astra_print_health_last_run_unixtime gauge
astra_print_health_last_run_unixtime $(date +%s)
EOF

chmod 0644 "$TMP_FILE"
mv "$TMP_FILE" "$METRICS_FILE"

log "Print health check completed."
