# Linux, Containers and Operations

## Purpose

The Raspberry Pi workstream supports practical Linux administration, container management, private remote access, service monitoring, DNS filtering and backup/recovery learning.

## Recorded lab progress

- Assembled and configured a Raspberry Pi 5, with Ethernet as the primary connection.
- Installed Docker and validated the engine with a basic test container.
- Deployed Portainer and Uptime Kuma and accessed their interfaces in the lab.
- Installed Tailscale on the Pi host and validated private remote SSH access.
- Configured Tailscale Serve for private access to selected services.
- Created AdGuard Home directories and developed a custom blocklist; a fully validated network-wide DNS deployment is not claimed.
- Recorded a successful scheduled Restic backup, non-destructive retention dry run and isolated disposable-file restore on 9 September 2026. Repository integrity and application-level recovery remain outstanding.

## Operating principles

### Access

Keep management interfaces on a private management network or authenticated private access path. Review both the container's published ports and the host firewall. Use individual accounts, strong authentication and least privilege. Never commit `.env` files, Tailscale auth keys, API tokens, passwords or real endpoint names.

### Container maintenance

Record the image name and pinned version/digest, persistent volume paths, dependencies, exposed ports and health checks. Before an upgrade, review release notes and take a suitable application-consistent backup. Test the upgraded service before removing the previous image or backup. Do not use `latest` as a substitute for a controlled update policy.

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
