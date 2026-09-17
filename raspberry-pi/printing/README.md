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

## 11. Current Queue State

The current CUPS queue is:

```text
Canon-TR4500
```

Current device URI:

```text
ipp://Canon%20TR4500%20series%20(USB)._ipp._tcp.local/
```

Current architecture:

```text
Windows
   ↓ IPP
CUPS on astra-pi
   ↓ IPP-over-USB
Canon TR4500
```

This is the preferred design at the moment.

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

## 14. Current Stop Point

**STOP HERE until Canon support code 5100 is cleared.**

Do not:

- rebuild the CUPS queue
- reinstall CUPS
- remove the Windows CUPS printer
- remove the original Canon direct Windows printer
- change Docker networking
- change Tailscale configuration
- restart or reconfigure unrelated Astra services

The current printer queue should remain:

```text
Canon-TR4500
```

with:

```text
ipp://Canon%20TR4500%20series%20(USB)._ipp._tcp.local/
```

---

## 15. Next Steps After Clearing Error 5100

After the Canon is mechanically healthy again:

1. Power the Canon back on.
2. Confirm no 5100 code is present.
3. Test the original Canon direct Windows queue.
4. Send **one** CUPS test page from `astra-pi`.
5. Confirm the page physically prints.
6. Send **one** Windows test page to `Canon-TR4500 @ astra-pi`.
7. Confirm physical output.
8. Only after the print path is proven stable:
   - make the Astra Pi queue the preferred/default printer
   - decide whether the old direct Windows queue should remain as fallback
   - add Uptime Kuma checks
   - add self-healing CUPS/queue monitoring
   - document the service in the Astra engineering journal

---

## 16. Planned Hands-Off Monitoring

Once printing is stable, add:

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
