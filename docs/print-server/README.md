# Astra Print Server

## Overview

The **Astra Print Server** provides centrally managed printing for a Canon TR4500 series printer using the Raspberry Pi 5 (`astra-pi`) as a Linux print server.

The solution combines:

- **CUPS** for print queue management
- **ipp-usb** for driverless IPP-over-USB communication
- **Tailscale** for private remote printing
- **systemd** for automated health checks and service recovery
- **Node Exporter** for exposing custom printer metrics
- **Prometheus** for metrics collection
- **Grafana** for monitoring and visualisation

The project forms part of the wider **Astra Infrastructure Lab** and demonstrates Linux administration, networking, automation, monitoring, troubleshooting and secure remote service delivery.

---

## Architecture

```text
Windows Client
      |
      | Microsoft IPP Class Driver
      |
      | Tailscale
      v
+--------------------------------+
|          astra-pi              |
|                                |
| Tailscale: 100.76.159.33       |
| CUPS: TCP/631                  |
|                                |
| Canon-TR4500 CUPS Queue        |
|              |                 |
|              v                 |
| ipp://localhost:60000/ipp/print|
|              |                 |
|              v                 |
|           ipp-usb              |
|              |                 |
+--------------|-----------------+
               |
               | USB
               v
+--------------------------------+
| Canon TR4500 Series            |
|                                |
| Auto Power On: Enabled         |
| Auto Power Off: 60 minutes     |
+--------------------------------+
```

---

## Print Queue

The CUPS print queue is:

```text
Canon-TR4500
```

The printer is configured as the default CUPS destination.

The device URI is:

```text
ipp://localhost:60000/ipp/print
```

This endpoint is provided by `ipp-usb`, allowing CUPS to communicate with the Canon TR4500 using driverless IPP-over-USB.

The physical Canon USB device is identified as:

```text
04a9:1854
```

---

## CUPS Configuration

CUPS provides the central print service and queue management.

Check the CUPS service:

```bash
systemctl status cups
```

Check the Canon queue:

```bash
lpstat -p Canon-TR4500
```

A healthy queue reports:

```text
printer Canon-TR4500 is idle. enabled
```

Check whether the queue is accepting jobs:

```bash
lpstat -a Canon-TR4500
```

Expected state:

```text
Canon-TR4500 accepting requests
```

Check the configured printer URI:

```bash
lpstat -v Canon-TR4500
```

Expected URI:

```text
ipp://localhost:60000/ipp/print
```

---

## Remote Printing over Tailscale

Remote printing is provided through the Astra Tailscale network.

The Raspberry Pi exposes CUPS on:

```text
TCP/631
```

CUPS has been verified as listening on IPv4 and IPv6:

```text
0.0.0.0:631
[::]:631
```

The Raspberry Pi Tailscale address used during validation was:

```text
100.76.159.33
```

Connectivity from the Windows client was tested with:

```powershell
Test-NetConnection 100.76.159.33 -Port 631
```

The test returned:

```text
TcpTestSucceeded : True
```

The remote Windows printer is installed as:

```text
Canon-TR4500 @ astra-pi
```

using the:

```text
Microsoft IPP Class Driver
```

The resulting print path is:

```text
Windows Client
      |
      | Tailscale
      v
astra-pi:631
      |
      v
CUPS
      |
      v
Canon-TR4500 Queue
      |
      v
ipp-usb
      |
      v
Canon TR4500
```

Remote printing therefore does not require exposing the CUPS service directly to the public Internet.

---

## Remote Printing Validation

Remote printing was successfully tested from a Windows client.

The following stages were validated:

1. Windows successfully reached `astra-pi` on TCP/631 over Tailscale.
2. The Windows IPP printer reported a normal state.
3. A Windows test page was submitted to `Canon-TR4500 @ astra-pi`.
4. The job appeared in the active CUPS queue.
5. CUPS passed the job to the printer through `ipp-usb`.
6. The physical test page printed successfully.

This validates the complete path:

```text
Windows
   |
   v
Tailscale
   |
   v
CUPS
   |
   v
ipp-usb
   |
   v
Canon TR4500
   |
   v
Physical Print
```

**Result: PASSED**

---

## Power Management Validation

The Canon TR4500 is configured with:

```text
Auto Power On:  Enabled
Auto Power Off: 60 minutes
```

Remote printing was tested after the printer had automatically powered down.

Without physically interacting with the printer, another print job was submitted through:

```text
Canon-TR4500 @ astra-pi
```

The incoming job successfully caused the Canon printer to power on automatically and print the requested page.

This demonstrates that the remote print service remains usable while allowing the physical printer to enter its normal power-saving state.

**Result: PASSED**

---

## Automated Health Monitoring

Printer health is checked using:

```text
/usr/local/sbin/astra-print-health
```

The script is executed by:

```text
astra-print-health.service
```

and scheduled by:

```text
astra-print-health.timer
```

The timer runs approximately every five minutes.

The service is configured as:

```ini
Type=oneshot
```

The health script therefore runs, performs its checks, updates the Prometheus metrics and exits.

An `inactive (dead)` state between executions is expected for this type of systemd service.

A successful execution reports:

```text
status=0/SUCCESS
```

---

## Self-Healing

The health collector performs limited automatic remediation.

If CUPS is unavailable, the script attempts:

```bash
systemctl restart cups
```

If `ipp-usb` is unavailable:

```bash
systemctl restart ipp-usb
```

If the Canon queue becomes disabled:

```bash
cupsenable Canon-TR4500
```

If the queue stops accepting jobs:

```bash
cupsaccept Canon-TR4500
```

The printer URI is also validated against:

```text
ipp://localhost:60000/ipp/print
```

However, the script deliberately **does not automatically reconfigure an incorrect URI**.

Instead, it logs a warning.

This prevents the automated health process from making potentially unintended print queue configuration changes.

---

## Prometheus Metrics

The Astra health collector writes Prometheus-compatible metrics to:

```text
/opt/node-exporter/textfile/astra_print.prom
```

Node Exporter exposes these metrics through its textfile collector.

The current metrics are:

| Metric | Purpose | Healthy State |
|---|---|---:|
| `astra_print_overall_health` | Overall print server health | `1` |
| `astra_print_cups_up` | CUPS service running | `1` |
| `astra_print_ipp_usb_up` | ipp-usb service running | `1` |
| `astra_print_usb_present` | Canon USB device detected | `1` |
| `astra_print_queue_enabled` | CUPS queue enabled | `1` |
| `astra_print_accepting_jobs` | Queue accepting jobs | `1` |
| `astra_print_uri_ok` | Expected ipp-usb URI configured | `1` |
| `astra_print_pending_jobs` | Incomplete jobs | `0` normally |
| `astra_print_health_last_run_unixtime` | Last health-check execution | Recent timestamp |

Metrics can be checked locally with:

```bash
curl -s http://localhost:9100/metrics | grep '^astra_print'
```

A healthy system currently resembles:

```text
astra_print_accepting_jobs 1
astra_print_cups_up 1
astra_print_health_last_run_unixtime <timestamp>
astra_print_ipp_usb_up 1
astra_print_overall_health 1
astra_print_pending_jobs 0
astra_print_queue_enabled 1
astra_print_uri_ok 1
astra_print_usb_present 1
```

---

## Overall Health Metric

`astra_print_overall_health` provides a single high-level indication of print server health.

```text
1 = Healthy
0 = Unhealthy
```

The overall health calculation checks:

- CUPS is active
- `ipp-usb` is active
- Canon USB device is detected
- CUPS queue is enabled
- Queue is accepting jobs
- Expected printer URI is configured

Pending jobs are deliberately excluded from the overall health calculation.

A pending print job does not necessarily represent a fault because a job could legitimately be waiting or actively processing.

---

## Grafana Dashboard

The custom metrics are designed to feed an Astra Grafana printer dashboard.

The planned dashboard layout is:

```text
+--------------------------------------------------+
|              ASTRA PRINT SERVER                  |
|                                                  |
|                    HEALTHY                       |
+--------------------------------------------------+

+--------------+ +--------------+ +--------------+
| USB          | | IPP-USB      | | CUPS         |
| PRESENT      | | UP           | | UP           |
+--------------+ +--------------+ +--------------+

+--------------+ +--------------+ +--------------+
| QUEUE        | | ACCEPTING    | | URI          |
| ENABLED      | | JOBS         | | CORRECT      |
+--------------+ +--------------+ +--------------+

+----------------------+ +-------------------------+
| Pending Jobs         | | Health Check Age        |
| 0                    | | < 5 minutes             |
+----------------------+ +-------------------------+
```

### Overall Health

PromQL:

```promql
astra_print_overall_health
```

### CUPS

```promql
astra_print_cups_up
```

### IPP-USB

```promql
astra_print_ipp_usb_up
```

### USB Device

```promql
astra_print_usb_present
```

### Queue Enabled

```promql
astra_print_queue_enabled
```

### Accepting Jobs

```promql
astra_print_accepting_jobs
```

### Correct URI

```promql
astra_print_uri_ok
```

### Pending Jobs

```promql
astra_print_pending_jobs
```

### Health Check Age

```promql
time() - astra_print_health_last_run_unixtime
```

The Raspberry Pi monitoring instrumentation is complete.

The remaining Grafana work consists primarily of creating and refining the visual dashboard panels.

---

## Security Considerations

Remote access uses Tailscale rather than directly exposing the print service to the public Internet.

The design separates remote connectivity from the physical printer:

```text
Remote Client
      |
      v
Tailscale
      |
      v
CUPS
      |
      v
Local ipp-usb Endpoint
      |
      v
Physical USB Printer
```

The `ipp-usb` endpoint remains local to the Raspberry Pi:

```text
ipp://localhost:60000/ipp/print
```

Remote clients communicate with CUPS rather than directly connecting to the local USB endpoint.

Future hardening may include reviewing CUPS access controls and Tailscale ACL/grant policies so TCP/631 access is restricted to explicitly authorised Astra devices or users.

---

## Operational Commands

### Check CUPS

```bash
systemctl status cups
```

### Check ipp-usb

```bash
systemctl status ipp-usb
```

### Check Printer

```bash
lpstat -p Canon-TR4500
```

### Check Accepting Status

```bash
lpstat -a Canon-TR4500
```

### Check Printer URI

```bash
lpstat -v Canon-TR4500
```

### Check Pending Jobs

```bash
lpstat -W not-completed -o Canon-TR4500
```

### Check Tailscale

```bash
tailscale status
```

### Check CUPS Listener

```bash
sudo ss -lntp | grep ':631'
```

### Run Health Check Manually

```bash
sudo systemctl start astra-print-health.service
```

### Check Health Service

```bash
systemctl status astra-print-health.service --no-pager
```

### View Astra Printer Metrics

```bash
curl -s http://localhost:9100/metrics | grep '^astra_print'
```

### Check Health Timer

```bash
systemctl list-timers --all | grep astra-print-health
```

---

## Validation Status

| Test | Status |
|---|---|
| Canon USB detection | Passed |
| ipp-usb operational | Passed |
| CUPS operational | Passed |
| CUPS queue enabled | Passed |
| Queue accepting jobs | Passed |
| Correct IPP-over-USB URI | Passed |
| Node Exporter metrics | Passed |
| Automated health timer | Passed |
| Overall health metric | Passed |
| Windows to Tailscale connectivity | Passed |
| Remote IPP printing | Passed |
| Physical test page | Passed |
| Automatic printer power-on | Passed |
| Grafana dashboard | In Progress |

---

## Evidence

Supporting screenshots and monitoring evidence will be stored under:

```text
docs/print-server/evidence/
```

Evidence will include:

- Successful Windows IPP print job
- CUPS queue state
- Tailscale connectivity
- Printer health metrics
- Grafana dashboard
- Remote printing validation

---

## Next Steps

Remaining work:

1. Complete the Grafana printer dashboard.
2. Add Grafana screenshots to the evidence directory.
3. Consider Prometheus/Grafana alerting for unhealthy printer states.
4. Review CUPS and Tailscale access controls for further hardening.
5. Investigate reliable CUPS job-history monitoring.

Potential future metrics include:

```text
astra_print_jobs_total
astra_print_last_job_unixtime
```

These should only be implemented once a reliable source for completed CUPS job history has been established.

---

## Skills Demonstrated

This project demonstrates practical experience with:

- Linux administration
- Raspberry Pi infrastructure
- CUPS print services
- IPP and IPP-over-USB
- systemd services and timers
- Bash scripting
- Infrastructure automation
- Self-healing services
- Tailscale networking
- Secure remote access
- TCP/IP troubleshooting
- Prometheus metrics
- Node Exporter textfile collectors
- Grafana observability
- Infrastructure monitoring
- Service validation
- Technical documentation

---

## Astra Infrastructure Lab

The Astra Print Server forms part of the wider **Astra Infrastructure Lab**.

The lab is being developed as an enterprise-style environment for practical experience across:

- Networking
- Linux infrastructure
- Windows Server
- Microsoft Azure
- Identity and access management
- Containers
- Monitoring and observability
- Automation
- Infrastructure as Code
- Security
- Infrastructure engineering
