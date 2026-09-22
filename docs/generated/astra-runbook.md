# Astra Infrastructure Runbook — Generated Public Snapshot

> Generated automatically at 2026-09-22T21:01:25.569644+00:00. Collector mode: **read-only**.

This public snapshot is rendered only from sanitised discovery data. Raw discovery remains local in a Git-ignored private directory.

## Host

```text
Static hostname: astra-pi
       Icon name: computer
      Machine ID: <ID_REDACTED>
         Boot ID: <ID_REDACTED>
Operating System: Debian GNU/Linux 13 (trixie)
          Kernel: Linux 6.18.39+rpt-rpi-2712
    Architecture: arm64
```

## Operating System

```text
PRETTY_NAME="Debian GNU/Linux 13 (trixie)"
NAME="Debian GNU/Linux"
VERSION_ID="13"
VERSION="13 (trixie)"
VERSION_CODENAME=trixie
DEBIAN_VERSION_FULL=13.6
ID=debian
HOME_URL="https://www.debian.org/"
SUPPORT_URL="https://www.debian.org/support"
BUG_REPORT_URL="https://bugs.debian.org/"
```

## Network Interfaces

```text
lo               UNKNOWN        <IPV4_REDACTED>/8 ::1/128 
eth0             UP             <IPV4_REDACTED>/24 <IPV6_REDACTED>/128 <IPV6_REDACTED>/64 <IPV6_REDACTED>/64 
wlan0            DOWN           
tailscale0       UNKNOWN        <IPV4_REDACTED>/32 <IPV6_REDACTED>/128 <IPV6_REDACTED>/64 
br-<ID_REDACTED>  UP             <IPV4_REDACTED>/16 <IPV6_REDACTED>/64 
br-<ID_REDACTED>  UP             <IPV4_REDACTED>/16 <IPV6_REDACTED>/64 
br-<ID_REDACTED>  UP             <IPV4_REDACTED>/16 <IPV6_REDACTED>/64 
br-<ID_REDACTED>  UP             <IPV4_REDACTED>/16 <IPV6_REDACTED>/64 
docker0          UP             <IPV4_REDACTED>/16 <IPV6_REDACTED>/64 
veth9d1db05@if2  UP             <IPV6_REDACTED>/64 
vethc99d865@if2  UP             <IPV6_REDACTED>/64 
vetha12e413@if2  UP             <IPV6_REDACTED>/64 
veth6c2f5a4@if2  UP             <IPV6_REDACTED>/64 
veth4dd7b38@if2  UP             <IPV6_REDACTED>/64 
veth06cd123@if2  UP             <IPV6_REDACTED>/64 
veth01b3740@if2  UP             <IPV6_REDACTED>/64 
veth9b582c7@if2  UP             <IPV6_REDACTED>/64
```

## Routing Table

```text
default via <IPV4_REDACTED> dev eth0 proto static metric 100 
<IPV4_REDACTED>/16 dev docker0 proto kernel scope link src <IPV4_REDACTED> 
<IPV4_REDACTED>/16 dev br-<ID_REDACTED> proto kernel scope link src <IPV4_REDACTED> 
<IPV4_REDACTED>/16 dev br-<ID_REDACTED> proto kernel scope link src <IPV4_REDACTED> 
<IPV4_REDACTED>/16 dev br-<ID_REDACTED> proto kernel scope link src <IPV4_REDACTED> 
<IPV4_REDACTED>/16 dev br-<ID_REDACTED> proto kernel scope link src <IPV4_REDACTED> 
<IPV4_REDACTED>/24 dev eth0 proto kernel scope link src <IPV4_REDACTED> metric 100
```

## Network Neighbours

```text
<IPV4_REDACTED> dev eth0 lladdr <MAC_REDACTED> STALE 
<IPV4_REDACTED> dev eth0 lladdr <MAC_REDACTED> STALE 
<IPV4_REDACTED> dev br-<ID_REDACTED> lladdr <MAC_REDACTED> STALE 
<IPV4_REDACTED> dev eth0 FAILED 
<IPV4_REDACTED> dev eth0 FAILED 
<IPV4_REDACTED> dev eth0 lladdr <MAC_REDACTED> DELAY 
<IPV4_REDACTED> dev br-<ID_REDACTED> lladdr <MAC_REDACTED> STALE 
<IPV4_REDACTED> dev eth0 FAILED 
<IPV4_REDACTED> dev eth0 lladdr <MAC_REDACTED> DELAY 
<IPV4_REDACTED> dev br-<ID_REDACTED> lladdr <MAC_REDACTED> STALE 
<IPV4_REDACTED> dev eth0 lladdr <MAC_REDACTED> STALE 
<IPV4_REDACTED> dev eth0 lladdr <MAC_REDACTED> REACHABLE 
<IPV4_REDACTED> dev eth0 lladdr <MAC_REDACTED> STALE 
<IPV4_REDACTED> dev eth0 lladdr <MAC_REDACTED> DELAY 
<IPV4_REDACTED> dev eth0 lladdr <MAC_REDACTED> DELAY 
<IPV4_REDACTED> dev br-<ID_REDACTED> lladdr <MAC_REDACTED> REACHABLE 
<IPV4_REDACTED> dev docker0 lladdr <MAC_REDACTED> STALE 
<IPV4_REDACTED> dev eth0 FAILED 
<IPV4_REDACTED> dev eth0 lladdr <MAC_REDACTED> DELAY 
<IPV4_REDACTED> dev eth0 FAILED 
<IPV4_REDACTED> dev br-<ID_REDACTED> lladdr <MAC_REDACTED> STALE 
<IPV4_REDACTED> dev br-<ID_REDACTED> lladdr <MAC_REDACTED> STALE 
<IPV6_REDACTED> dev eth0 lladdr <MAC_REDACTED> router STALE 
<IPV6_REDACTED> dev eth0 lladdr <MAC_REDACTED> STALE 
<IPV6_REDACTED> dev eth0 lladdr <MAC_REDACTED> STALE 
<IPV6_REDACTED> dev eth0 router FAILED 
<IPV6_REDACTED> dev eth0 lladdr <MAC_REDACTED> STALE 
<IPV6_REDACTED> dev eth0 lladdr <MAC_REDACTED> STALE 
<IPV6_REDACTED> dev eth0 lladdr <MAC_REDACTED> STALE 
<IPV6_REDACTED> dev eth0 lladdr <MAC_REDACTED> STALE 
<IPV6_REDACTED> dev eth0 lladdr <MAC_REDACTED> STALE 
<IPV6_REDACTED> dev eth0 lladdr <MAC_REDACTED> STALE 
<IPV6_REDACTED> dev eth0 lladdr <MAC_REDACTED> STALE
```

## Block Storage

```text
NAME         SIZE FSTYPE MOUNTPOINTS
loop0          2G swap   
mmcblk0     29.5G        
├─mmcblk0p1  512M vfat   /boot/firmware
└─mmcblk0p2   29G ext4   /
zram0          2G swap   [SWAP]
```

## Filesystem Usage

```text
Filesystem     Type      Size  Used Avail Use% Mounted on
udev           devtmpfs  2.0G     0  2.0G   0% /dev
tmpfs          tmpfs     810M   37M  774M   5% /run
/dev/mmcblk0p2 ext4       29G   13G   15G  47% /
tmpfs          tmpfs     2.0G     0  2.0G   0% /dev/shm
tmpfs          tmpfs     5.0M   48K  5.0M   1% /run/lock
tmpfs          tmpfs     1.0M     0  1.0M   0% /run/credentials/systemd-journald.service
tmpfs          tmpfs     2.0G     0  2.0G   0% /tmp
/dev/mmcblk0p1 vfat      505M   66M  439M  14% /boot/firmware
tmpfs          tmpfs     1.0M     0  1.0M   0% /run/credentials/getty@tty1.service
tmpfs          tmpfs     1.0M     0  1.0M   0% /run/credentials/serial-getty@ttyAMA10.service
tmpfs          tmpfs     405M   32K  405M   1% /run/user/1000
```

## Docker Containers

| Container | Image | Status | Networks | Ports |
| --- | --- | --- | --- | --- |
| grafana | grafana/grafana:latest | Up 3 days | monitoring_default | <IPV4_REDACTED>:3003->3000/tcp, [::]:3003->3000/tcp |
| authentik-worker | ghcr.io/goauthentik/server:2026.8.1 | Up 5 days (healthy) | authentik_default | — |
| authentik-server | ghcr.io/goauthentik/server:2026.8.1 | Up 5 days (healthy) | authentik_default | <IPV4_REDACTED>:9000->9000/tcp, [::]:9000->9000/tcp, <IPV4_REDACTED>:9449->9443/tcp, [::]:9449->9443/tcp |
| authentik-postgresql | postgres:16-alpine | Up 5 days (healthy) | authentik_default | 5432/tcp |
| adguardhome | adguard/adguardhome:latest | Up 5 days | host | — |
| node-exporter | prom/node-exporter:latest | Up 5 days | host | — |
| prometheus | prom/prometheus:latest | Up 5 days | monitoring_default | <IPV4_REDACTED>:9090->9090/tcp, [::]:9090->9090/tcp |
| netalertx | ghcr.io/netalertx/netalertx:latest | Up 5 days (healthy) | host | — |
| homepage | ghcr.io/gethomepage/homepage:latest | Up 5 days (healthy) | homepage_default | <IPV4_REDACTED>:3002->3000/tcp, [::]:3002->3000/tcp |
| uptime-kuma | louislam/uptime-kuma:latest | Up 5 days (healthy) | uptime-kuma_default | <IPV4_REDACTED>:3001->3001/tcp, [::]:3001->3001/tcp |
| portainer | portainer/portainer-ce:lts | Up 5 days | bridge | 8000/tcp, 9000/tcp, <IPV4_REDACTED>:9443->9443/tcp, [::]:9443->9443/tcp |

## Docker Networks

```text
authentik_default	bridge	local
bridge	bridge	local
homepage_default	bridge	local
host	host	local
monitoring_default	bridge	local
none	null	local
uptime-kuma_default	bridge	local
```

## Docker Volumes

```text
authentik_authentik-media	local
authentik_authentik-postgresql-data	local
authentik_authentik-templates	local
authentik_database	local
monitoring_grafana-data	local
monitoring_prometheus-data	local
portainer_data	local
uptime-kuma_uptime-kuma-data	local
```

## Tailscale

```text
<IPV4_REDACTED>  <DEVICE_REDACTED>  <ACCOUNT_REDACTED>  linux  -
<IPV4_REDACTED>  <DEVICE_REDACTED>  <ACCOUNT_REDACTED>  windows  active;  direct  <IPV4_REDACTED>:41641,  tx  2023104  rx  2033496
<IPV4_REDACTED>  <DEVICE_REDACTED>  <ACCOUNT_REDACTED>  iOS  -
```

## Operational Notes

- This snapshot is evidence of observed state, not desired state.
- Validate critical services after any infrastructure change.
- Never commit the private raw inventory.
- Review generated public artefacts before publishing.
- The topology represents observed Docker network membership only.
- Future milestones will add service dependencies, recovery procedures, Azure/AD discovery and desired-state comparison.
