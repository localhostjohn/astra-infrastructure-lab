# Astra Pi Print Server – Canon TR4500 Build & Troubleshooting Log

**Date:** 17 September 2026  
**Host:** `astra-pi`  
**Purpose:** Centralise printing through the Raspberry Pi so client devices can print without relying on Windows WSD/direct printer discovery.

---

## 1. Objective

The goal of this project is to make printing as close to "hands-off" as possible:

```text
Windows / Laptop / Phone
        ↓
   CUPS on astra-pi
        ↓
   Canon TR4500
```

The Raspberry Pi is already used for other Astra services, including Docker workloads, Tailscale, AdGuard Home, Uptime Kuma, Portainer, Prometheus, Grafana and Authentik.

The print service therefore needed to be added without disrupting the existing environment.

---

## 2. Existing Astra Pi State

### Raspberry Pi addresses

- LAN: `192.168.0.190`
- Tailscale: `100.76.159.33`
- Hostname: `astra-pi`

### Existing services observed

Docker services included:

- Grafana
- Authentik
- AdGuard Home
- Node Exporter
- Prometheus
- NetAlertX
- Homepage
- Uptime Kuma
- Portainer

Tailscale was active.

Avahi/mDNS was already installed and active.

---

## 3. Canon TR4500 Network State

The printer was reachable at:

```text
192.168.0.19
```

Initial connectivity tests confirmed:

```text
TCP 631  OPEN
TCP 9100 OPEN
TCP 515  OPEN
```

This meant the Canon exposed:

- IPP on TCP 631
- JetDirect/raw printing on TCP 9100
- LPD on TCP 515

The printer also advertised itself over mDNS/DNS-SD.

---

## 4. CUPS Installation

Installed:

```bash
sudo apt update
sudo apt install -y cups cups-client cups-ipp-utils
```

CUPS was then enabled:

```bash
sudo systemctl enable --now cups
```

Confirmed:

```text
cups.service
Active: active (running)
Status: Scheduler is running...
```

---

## 5. Initial Printer Discovery

The Canon was discovered as:

```text
ipp://DCE28E000000.local:631/ipp/print
```

`lpinfo` also showed:

```text
network ipps://Canon%20TR4500%20series._ipps._tcp.local/
network socket://192.168.0.19
network dnssd://Canon%20TR4500%20series._ipp._tcp.local/...
```

Driverless support was available:

```text
Canon TR4500 series, driverless
Generic IPP Everywhere Printer
IPP Everywhere
```

---

## 6. Initial CUPS Queue

A queue was created:

```text
Queue name: Canon-TR4500
```

Initial backend:

```text
ipp://DCE28E000000.local:631/ipp/print
```

The Pi default printer was set to:

```text
Canon-TR4500
```

A CUPS test page physically printed successfully during the first stage.

---

## 7. CUPS LAN / Tailscale Access

CUPS initially only listened locally.

The target was to allow access from:

```text
LAN:       192.168.0.0/24
Tailscale: 100.64.0.0/10
```

The CUPS web interface was enabled and CUPS was configured to listen on TCP 631.

Confirmed listener:

```text
0.0.0.0:631
[::]:631
```

The root CUPS location was allowed from the LAN and Tailnet.

A Windows connectivity test eventually returned:

```text
HTTP/1.1 200 OK
Server: CUPS/2.4 IPP/2.1
```

This confirmed:

```text
Windows → astra-pi:631 → CUPS
```

was working.

---

## 8. Windows Printer Discovery

Windows discovered:

```text
Canon-TR4500 @ astra-pi
```

This is the Pi/CUPS-backed queue.

Windows was able to submit jobs successfully to CUPS.

CUPS access logs showed successful:

```text
Validate-Job
Create-Job
Send-Document
```

operations from the Windows client.

However, Windows jobs were marked as printed/completed even though no physical pages were produced.

---

## 9. Troubleshooting the Pi → Canon Path

### A. Network IPP backend

Backend:

```text
ipp://DCE28E000000.local:631/ipp/print
```

Observed:

- CUPS accepted jobs.
- Canon reported itself as idle and accepting jobs.
- Canon had `queued-job-count = 0`.
- Physical pages did not print.

A direct IPP test with `ipptool` also returned:

```text
successful-ok
job-state = processing
```

but no page came out.

### B. TCP 9100 / JetDirect backend

The queue was temporarily changed to:

```text
socket://192.168.0.19:9100
```

Port 9100 was confirmed reachable.

However, CUPS jobs still stalled in:

```text
job-printing
```

without physical output.

### C. USB connection

A standard USB-A to USB-B printer cable was connected between the Pi and the Canon.

`lsusb` confirmed:

```text
04a9:1854 Canon, Inc. TR4500 series
```

`lpinfo -v` showed:

```text
direct usb://Canon/TR4500%20series?serial=40DC59&interface=1
direct usb://Canon/TR4500%20series%20FAX?serial=40DC59&interface=2
network ipp://Canon%20TR4500%20series%20(USB)._ipp._tcp.local/
```

---

## 10. ipp-usb

`ipp-usb` was found to be running:

```text
ipp-usb.service
Active: active (running)
```

Because `ipp-usb` had claimed the printer's USB interface, the raw `usb://` backend was not considered the best long-term path.

The queue was therefore moved to the driverless IPP-over-USB endpoint:

```text
ipp://Canon%20TR4500%20series%20(USB)._ipp._tcp.local/
```

The queue now exposes proper printer capabilities such as:

```text
PageSize: A4, A5, Letter, Legal, envelopes, photo sizes
InputSlot: Main
MediaType: Stationery, Photographic, Envelope
PrintQuality: Draft, Normal, High
ColorModel: RGB, Gray
Duplex: None, Long-edge, Short-edge
```

This confirms that driverless capability negotiation is working.

---

## 11. Current Queue State — Working

The CUPS queue is:

```text
Canon-TR4500
```

Current device URI:

```text
ipp://localhost:60000/ipp/print
```

This is the local IPP-over-USB endpoint exposed by `ipp-usb`.

Current working architecture:

```text
Windows / client
      ↓ IPP
CUPS on astra-pi
      ↓
ipp://localhost:60000/ipp/print
      ↓ ipp-usb
Canon TR4500 over USB
```

A CUPS test page has now physically printed successfully through this path. The print-server transport is therefore proven working.

---

## 12. Important Discovery – Canon Error 5100

After moving to the IPP-over-USB path, the printer finally physically printed a page.

Immediately afterwards, the Canon displayed:

```text
Support Code 5100
See manual
```

This is significant because it proves:

```text
Pi → CUPS → IPP-over-USB → Canon
```

can physically print.

The remaining problem is now at least partly a printer-side mechanical issue.

Do **not** continue sending test jobs until the 5100 condition is cleared.

Potential 5100 causes to inspect include:

- carriage movement obstruction
- small scraps of paper
- cartridge carriage obstruction
- incorrectly seated FINE cartridges
- other mechanical interference

Do not force the carriage or touch/damage the transparent encoder strip.

---

## 13. Known Working / Known Non-Working Paths

### Proven working

```text
Windows → Canon direct
```

The original Canon direct Windows queue physically prints.

```text
Pi → Canon via IPP-over-USB
```

This has now physically produced a page, although the printer then raised support code 5100.

### Previously problematic

```text
Pi → Canon network IPP
```

Jobs accepted but no physical output.

```text
Pi → Canon TCP 9100
```

Jobs stalled / did not physically print.

```text
CUPS → raw usb://
```

Stalled while `ipp-usb` was active.

---

## 14. Current Stable State

The Canon 5100 condition was cleared.

The printer then successfully produced:

- a nozzle-check page
- an automatic head-alignment page
- a Windows test page using the direct Canon TCP/IP queue
- a CUPS test page from `astra-pi` over IPP-over-USB

The current CUPS queue should therefore be left unchanged:

```text
Canon-TR4500
```

with:

```text
ipp://localhost:60000/ipp/print
```

The direct Windows fallback queue is also working via:

```text
192.168.0.19:9100
RAW / Standard TCP/IP Port
```

Do not rebuild the working CUPS queue unless a future fault is first diagnosed.

---

## 15. Finalisation Steps

The remaining implementation work is reliability-focused rather than fault-finding:

1. Send one Windows test page through `Canon-TR4500 @ astra-pi`.
2. Once confirmed, make that queue the preferred/default Windows printer.
3. Keep the direct Canon TCP/IP queue at `192.168.0.19:9100` as a fallback.
4. Deploy the repository's self-healing systemd service and timer.
5. Add an Uptime Kuma TCP monitor for CUPS on port 631.
6. Do not automatically delete queued jobs during recovery.

---

## 16. Hands-Off Monitoring

The repository now includes a conservative self-healing check under `raspberry-pi/printing/scripts/` and systemd unit templates under `raspberry-pi/printing/systemd/`.

The recovery design intentionally avoids deleting print jobs, rebooting the Pi, or changing networking.

Recommended monitoring:

### CUPS monitoring

Check:

```text
TCP 631 on astra-pi
```

### Printer monitoring

For USB/IPP-over-USB, monitor the CUPS queue and `ipp-usb` service rather than the printer's network port.

### Self-healing checks

Potential actions:

```text
If cups.service fails:
    restart cups

If ipp-usb.service fails:
    restart ipp-usb

If Canon-TR4500 queue becomes disabled:
    cupsenable Canon-TR4500

If queue stops accepting jobs:
    cupsaccept Canon-TR4500

If printer is temporarily unavailable:
    retain queued jobs
    do not automatically delete them

If the Canon USB device is absent:
    log the condition
    do not restart unrelated services
```

Avoid automatically cancelling queued jobs unless they are proven stale or corrupt.

---

## 17. Useful Diagnostic Commands

### CUPS status

```bash
systemctl status cups --no-pager
```

### IPP-over-USB status

```bash
systemctl status ipp-usb --no-pager
```

### Queue state

```bash
lpstat -t
```

### Current printer URI

```bash
lpstat -v Canon-TR4500
```

### Outstanding jobs

```bash
lpstat -W not-completed -l -o Canon-TR4500
```

### Completed jobs

```bash
lpstat -W completed -o Canon-TR4500
```

### USB detection

```bash
lsusb
```

### Printer discovery

```bash
lpinfo -v
```

### CUPS listener

```bash
sudo ss -tulpn | grep ':631'
```

### CUPS config validation

```bash
sudo cupsd -t
```

---

## 18. Engineering Takeaway

This started as a simple printer reliability problem but became a useful infrastructure exercise covering:

- Linux service management
- CUPS
- IPP / IPP Everywhere
- IPP-over-USB
- mDNS / Avahi
- TCP port diagnostics
- Windows print queues
- Tailscale routing
- access control
- service troubleshooting
- layered fault isolation
- separating client, print-server, transport and hardware faults

The key lesson was to isolate each layer independently rather than assuming a job marked "completed" by Windows or CUPS meant the printer had physically produced output.


---

## 19. Tailscale End-to-End Validation

The Windows CUPS queue was recreated using the Pi's Tailscale IP:

```text
http://100.76.159.33:631/printers/Canon-TR4500
```

Windows created the queue as:

```text
Name          : Canon-TR4500 @ astra-pi
DriverName    : Microsoft IPP Class Driver
PrinterStatus : Normal
```

With Tailscale enabled, a Windows test page printed successfully.

This proves the complete remote-capable path:

```text
Windows
   ↓ Tailscale
100.76.159.33:631
   ↓
CUPS on astra-pi
   ↓
ipp://localhost:60000/ipp/print
   ↓ ipp-usb
Canon TR4500 over USB
```

The direct Canon TCP/IP queue remains available as a local fallback:

```text
Canon TR4500 series
→ 192.168.0.19:9100
```

The preferred Windows queue is now:

```text
Canon-TR4500 @ astra-pi
```


---

## 20. Grafana / Prometheus Monitoring

The print health script exports Prometheus textfile metrics to:

```text
/opt/node-exporter/textfile/astra_print.prom
```

The existing node-exporter textfile collector exposes:

```text
astra_print_cups_up
astra_print_ipp_usb_up
astra_print_usb_present
astra_print_queue_enabled
astra_print_accepting_jobs
astra_print_uri_ok
astra_print_pending_jobs
astra_print_health_last_run_unixtime
```

These metrics have been verified at the node-exporter endpoint on TCP 9100.

Recommended Grafana row: `Astra Print Server`

Recommended stat panels:

- CUPS Service → `astra_print_cups_up`
- IPP-USB Service → `astra_print_ipp_usb_up`
- Canon USB Device → `astra_print_usb_present`
- Queue Enabled → `astra_print_queue_enabled`
- Accepting Jobs → `astra_print_accepting_jobs`
- IPP-over-USB URI → `astra_print_uri_ok`
- Pending Jobs → `astra_print_pending_jobs`
- Health Check Age → `time() - astra_print_health_last_run_unixtime`

For binary health metrics, map `1` to healthy/available and `0` to fault/unavailable.
