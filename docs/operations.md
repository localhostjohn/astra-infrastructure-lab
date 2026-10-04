# Linux, Containers and Operations

## Purpose

The Raspberry Pi workstream supports practical Linux administration, container management, private remote access, service monitoring, DNS filtering and backup/recovery learning.

## Recorded lab progress

- Assembled and configured a Raspberry Pi 5, with Ethernet as the primary connection.
- Installed Docker and validated the engine with a basic test container.
- Deployed Portainer and Uptime Kuma and accessed their interfaces in the lab.
- Installed Tailscale on the Pi host and validated private remote SSH access.
- Deployed a self-hosted RustDesk OSS server on the Pi and validated Windows client registration over Tailscale; cross-device remote-control testing remains pending.
- Configured the Pi as a Tailscale subnet router for the home LAN and approved the advertised route in the Tailscale administration interface.
- Configured Tailscale Split DNS for the private home.arpa namespace, forwarding those queries to AdGuard Home.
- Validated the private service portal from an iPhone over cellular data with Tailscale enabled.
- Nginx Proxy Manager provides HTTPS for the private portal using an Astra Root CA and wildcard service certificate.
- Established a two-tier internal PKI with an Astra Root CA and Astra Internal Issuing CA for service and client certificate issuance.
- Issued and installed the first Windows client certificate for TLS client authentication and validated the full certificate chain.
- Configured a dedicated Nginx Proxy Manager mTLS test path; browser access with the Astra client certificate succeeded and a request without a client certificate was rejected with HTTP 400.
- Issued a separate client certificate to a macOS administrator endpoint, anchored trust at the Astra Root CA, and validated both positive and negative mTLS paths.
- Moved Portainer from test-only validation to selective mTLS enforcement on its reverse-proxied administration path while retaining direct management access as a recovery route.
- Upgraded Portainer from 2.45.0 to 2.45.1 with a pre-change data-volume backup; Portainer completed its internal database migration successfully.
- Revalidated the protected Portainer path after the upgrade. Recreating the container removed the previous shared Docker-network dependency, so the NPM upstream was changed from container-name resolution to the Pi host's stable management address; mTLS rejection and direct recovery access remained intact.
- Created AdGuard Home directories and developed a custom blocklist; broader network-wide filtering validation remains a separate workstream.
- Recorded a successful scheduled Restic backup, non-destructive retention dry run and isolated disposable-file restore on 9 September 2026. Repository integrity and application-level recovery remain outstanding.

## Operating principles

### Access

Keep management interfaces on a private management network or authenticated private access path. Review both the container's published ports and the host firewall. Use individual accounts, strong authentication and least privilege. Never commit `.env` files, Tailscale auth keys, API tokens, passwords or real endpoint names.

For selected administration endpoints, Astra can add a device-trust layer with mTLS at the reverse proxy. Treat the client certificate as a device credential: issue a unique certificate per trusted endpoint, keep its private key protected, retain revocation/replacement procedures, and preserve an emergency management route so certificate or identity failures do not create a lockout condition. Do not publish CA private keys, client private keys, PFX files or live internal hostnames.

### Container maintenance

Record the image name and pinned version/digest, persistent volume paths, dependencies, exposed ports and health checks. Before an upgrade, review release notes and take a suitable application-consistent backup. Test the upgraded service before removing the previous image or backup. Do not use `latest` as a substitute for a controlled update policy.

### Remote endpoint control

RustDesk is used as a private remote endpoint-control layer rather than as a public-facing service. The Astra design keeps Tailscale as the remote network boundary and uses the Pi-hosted RustDesk rendezvous and relay services for endpoint coordination. Do not publish server keys, endpoint IDs, passwords or live private addresses. Treat a client showing Ready as registration evidence only; unattended access and an actual remote session should be tested separately before claiming end-to-end control.

### Monitoring

Uptime Kuma can report service availability, but a successful HTTP response is not proof that an application is fully healthy. Define the expected check, threshold, notification route and escalation response. Test alerts in a controlled way and document the outcome. Monitoring the monitoring service itself is a useful later exercise.

### DNS

A custom blocklist is a configuration-management exercise, not a complete security solution. Test changes with a small group of devices, review query logs and retain a rollback path. DNS filtering should not be allowed to become a single point of failure without an understood recovery plan.

### Backup and recovery

A backup is not proven recoverable merely because a snapshot command completes. Record the source data, repository destination, encryption/key-recovery arrangements, retention policy and restore procedure. Keep backup credentials separate from the source host where practical. Test a restore to an isolated location and compare files or checksums before claiming recovery is validated.

The dedicated [Backup and Recovery Engineering](backup-recovery.md) page records the control model, current evidence and staged route from file recovery through repository integrity to application-level recovery.

## Example checks (run only on your own lab)

```bash
# Identify the host and current network configuration.
hostnamectl
ip -br address
ip route

# Inspect service and container state without changing it.
systemctl status docker --no-pager
docker ps

# Inspect available disk space and mounted filesystems.
df -h
lsblk -f
```

These are read-only diagnostic examples, not output captured from the actual Pi. Do not run administrative changes from a public README without checking their effect on your own host.

## Recovery validation status

A file-level recovery exercise was completed on 9 September 2026 using a disposable test file and an isolated restore directory. The restored file matched the original by SHA-256 and byte comparison. See [Raspberry Pi Backup and Recovery Validation](../evidence/2026-09-09-raspberry-pi-backup-recovery.md).

That result proves recovery of the selected test file only. It does not establish repository-wide integrity, application-consistent backup or full service recovery.

The next recovery checks are:

1. record an actual successful repository integrity check;
2. define RPO and RTO targets for one low-risk lab service;
3. restore that service's data/configuration into an isolated instance;
4. validate permissions, application startup, functional behaviour and monitoring;
5. record measured recovery time and limitations.

## References

- [Docker Engine](https://docs.docker.com/engine/)
- [Portainer documentation](https://docs.portainer.io/)
- [Tailscale documentation](https://tailscale.com/kb/)
- [Uptime Kuma](https://github.com/louislam/uptime-kuma)
- [AdGuard Home](https://github.com/AdguardTeam/AdGuardHome)
- [Restic](https://restic.readthedocs.io/)
