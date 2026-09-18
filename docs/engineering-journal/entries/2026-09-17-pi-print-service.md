# 2026-09-17 - Raspberry Pi print service

**Status:** In progress

## Problem

Windows printing currently depends on direct printer discovery and a WSD/Web Services queue. The operational goal is to reduce routine printer troubleshooting by introducing a stable, always-on print path through the Astra Raspberry Pi.

## Objective

Provide a local print service that:

- survives Windows client restarts and rediscovery issues;
- runs independently of the existing Docker stack;
- coexists with Portainer, Uptime Kuma, AdGuard Home and Tailscale;
- can be monitored;
- does not use broad or destructive automatic resets;
- preserves a clear recovery path when printing genuinely fails.

## Constraints

- The Raspberry Pi already hosts important lab services.
- Existing Docker networking must not be restructured for printing.
- Tailscale must remain available for remote management.
- No automatic job deletion or unrelated service restart is permitted.
- The public repository must not contain the real home-lab addressing.

## Options considered

### CUPS in Docker

Rejected for the initial implementation. It would add another container-networking dependency to a function that should remain available even if the Docker stack is being maintained.

### Native CUPS and Avahi

Selected for the initial implementation. CUPS and Avahi run as normal systemd services and therefore remain separate from the container workload.

### Continue using direct Windows WSD printing

Retained as a rollback path during testing, but not the preferred long-term client path because it does not address the reliability objective.

## Current design

```text
Windows client
   |
   | IPP
   v
Astra Pi - CUPS / Avahi
   |
   | driverless IPP where validated
   v
Canon TR4500 series
```

The installer checks the printer before creating a queue. If driverless IPP cannot be established, it stops without creating an unverified raw queue or changing unrelated services.

## Implementation added

- `services/print-service/README.md`
- `services/print-service/install.sh`
- `services/print-service/healthcheck.sh`

The installer is deliberately conservative. It enables CUPS and Avahi, checks printer reachability, attempts a driverless IPP queue, shares only the selected queue to the local network and does not enable CUPS `--remote-any` access.

## Validation still required

This entry must not be marked **Validated** until the following are observed in the live lab:

1. CUPS and Avahi start successfully on the Pi.
2. The Canon printer accepts the selected IPP URI.
3. A one-page print from the Pi succeeds.
4. A Windows test client prints through the Astra queue.
5. The Pi is rebooted and the print service returns without manual intervention.
6. Existing Docker, DNS, monitoring and Tailscale services remain healthy.
7. The health check reports expected states during both normal operation and a bounded printer-offline test.

## Measurements to record

- queue setup result;
- test-print success/failure;
- time from Pi boot to print queue availability;
- behaviour when the printer is temporarily offline;
- behaviour when the printer returns;
- number of manual recovery actions required;
- any impact on existing Astra services.

## Next action

Deploy the service on `astra-pi` using the real printer address supplied locally, then record the actual output and results. Do not claim hands-off recovery until controlled failure testing demonstrates it.
