#!/usr/bin/env bash
set -euo pipefail

QUEUE_NAME="${QUEUE_NAME:-Canon-TR4500}"
PRINTER_IP="${PRINTER_IP:-}"
IPP_PATH="${IPP_PATH:-/ipp/print}"

if [[ $EUID -ne 0 ]]; then
  echo "Run this installer with sudo/root privileges." >&2
  exit 1
fi

if [[ -z "$PRINTER_IP" ]]; then
  echo "PRINTER_IP is required. Example:" >&2
  echo "  sudo PRINTER_IP='192.0.2.19' ./install.sh" >&2
  exit 2
fi

if lpstat -p "$QUEUE_NAME" >/dev/null 2>&1; then
  echo "Queue '$QUEUE_NAME' already exists. No changes made."
  echo "Use lpstat -t to inspect it before deciding whether it should be changed."
  exit 0
fi

echo "Installing CUPS, Avahi and connectivity tools..."
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y \
  cups \
  cups-client \
  cups-filters \
  avahi-daemon \
  netcat-openbsd

systemctl enable --now cups
systemctl enable --now avahi-daemon

IPP_REACHABLE=false
RAW_REACHABLE=false

if nc -z -w 3 "$PRINTER_IP" 631; then
  IPP_REACHABLE=true
fi

if nc -z -w 3 "$PRINTER_IP" 9100; then
  RAW_REACHABLE=true
fi

if [[ "$IPP_REACHABLE" != true && "$RAW_REACHABLE" != true ]]; then
  echo "Printer is not reachable on TCP 631 (IPP) or 9100 (RAW)." >&2
  echo "No CUPS queue was created." >&2
  exit 3
fi

echo "Connectivity: IPP=$IPP_REACHABLE RAW=$RAW_REACHABLE"

if [[ "$IPP_REACHABLE" != true ]]; then
  echo "The printer answered on RAW 9100 but not IPP 631." >&2
  echo "This installer will not create an unverified raw queue automatically." >&2
  echo "No queue was created." >&2
  exit 4
fi

DEVICE_URI="ipp://${PRINTER_IP}${IPP_PATH}"

echo "Attempting driverless IPP queue at: $DEVICE_URI"
if ! lpadmin -p "$QUEUE_NAME" -E -v "$DEVICE_URI" -m everywhere; then
  echo "Driverless IPP queue creation failed." >&2
  echo "Removing only the partial queue created by this installer, if present." >&2
  lpadmin -x "$QUEUE_NAME" >/dev/null 2>&1 || true
  echo "No existing unrelated queues or jobs were changed." >&2
  exit 5
fi

# CUPS --share-printers exposes shared queues to the local network only.
# We intentionally do not use --remote-any.
cupsctl --share-printers
lpadmin -p "$QUEUE_NAME" -o printer-is-shared=true
lpadmin -d "$QUEUE_NAME"

echo
echo "Astra print queue created successfully."
lpstat -t

echo
echo "Next: run ./healthcheck.sh and perform a one-page test print."
