# Astra Pi Print Service

## Purpose

Provide a stable, low-touch print path through the always-on Astra Raspberry Pi without disrupting Docker, Portainer, Uptime Kuma, AdGuard Home or Tailscale.

The service runs **CUPS and Avahi natively under systemd** rather than inside Docker. This keeps printing independent of the container stack and avoids competing with existing host-networked services.

## Target architecture

```text
Windows client
    |
    | IPP to Astra Pi
    v
CUPS on astra-pi
    |
    | IPP Everywhere where supported
    v
Canon TR4500 series
```

The public repository does not contain the real home-lab addresses. Pass the printer address locally when running the installer.

## Design principles

- Keep the print path independent of Docker.
- Do not expose CUPS administration to arbitrary remote networks.
- Share the queue only to the local network.
- Prefer driverless IPP when the printer confirms support.
- Do not blindly purge print jobs or reset unrelated services.
- Do not change existing Docker, AdGuard Home or Tailscale networking.
- Treat automatic recovery as a later, tested enhancement rather than hiding recurring faults.

## Why this should be more stable than the current Windows path

The existing Windows queue uses WSD/Web Services discovery. The Astra design gives clients a consistent print-server endpoint instead of relying on Windows to rediscover and manage the printer directly.

The Canon TR4500 family advertises Bonjour by default and has RAW/LPR network printing enabled in its default network settings. The installer first attempts a driverless IPP queue and fails safely if the printer does not accept that path. It does not silently fall back to a raw queue that may require a model-specific filter.

## Files

- `install.sh` - installs CUPS/Avahi and creates the queue only after connectivity checks.
- `healthcheck.sh` - read-only health check suitable for manual use, systemd or Uptime Kuma integration.

## Deployment

Run from the Raspberry Pi:

```bash
cd services/print-service
chmod +x install.sh healthcheck.sh
sudo PRINTER_IP='<printer-ip>' ./install.sh
```

The installer intentionally requires `PRINTER_IP` to be supplied at runtime so the real home-lab address is not committed to the public repository.

## Validation

After installation:

```bash
lpstat -t
./healthcheck.sh
```

Then perform three bounded tests:

1. Print a one-page test from the Pi/CUPS queue.
2. Add the shared Astra queue from a Windows test client and print one page.
3. Reboot the Pi and confirm CUPS, Avahi and the queue return without manual repair.

Record timings and results in the Engineering Journal. A queue is not considered validated merely because it exists.

## Monitoring

The health check verifies:

- CUPS service is active;
- the configured queue exists;
- the queue is enabled;
- the printer is reachable on IPP (631) or RAW (9100).

Uptime Kuma can monitor the CUPS endpoint separately after the local deployment is validated.

## Recovery policy

Initial recovery is deliberately conservative. The service must not automatically delete jobs, recreate queues or restart unrelated networking. Once failure modes have been observed, a narrow recovery action can be added and tested as a separate experiment.
