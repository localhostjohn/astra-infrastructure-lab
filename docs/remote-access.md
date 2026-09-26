# Astra Remote Access, Private DNS and TLS

## Purpose

This document records the validated remote-access architecture for the Astra home lab. It deliberately describes the design without publishing live private DNS records, home IP addresses, certificate keys or device identifiers.

## Validated architecture

```text
Authorised endpoint
       |
       | Tailscale
       v
Astra Pi 5
       |
       | subnet route to home LAN
       v
Home LAN services
       |
       +--> AdGuard Home
       |      |
       |      +--> Split DNS for private home namespace
       |
       +--> Nginx Proxy Manager
              |
              +--> HTTPS
                     |
                     +--> Astra Root CA
                     +--> wildcard Astra service certificate
```

Tailscale remains the remote-access boundary. No public port forwarding is required for this service path, and the travel router is intentionally not part of the Tailscale access design.

## Tailscale subnet routing

The Astra Pi advertises the home LAN as a subnet route. The route has been approved in the Tailscale administration interface.

This allows an authorised Tailscale endpoint to reach devices and services on the home LAN that do not themselves run Tailscale.

The route is deliberately limited to the home LAN subnet rather than advertising a broader network range.

### Validation

The following state was verified on 26 September 2026:

- Astra Pi has a Tailscale address.
- The Pi advertises the home LAN subnet route.
- The route is approved in the Tailscale administration interface.
- The iPhone is registered as a Tailscale endpoint.
- The iPhone successfully reached the private service portal while using cellular data rather than the home Wi-Fi network.

**Status: Passed for the tested endpoint and service path.**

This does not establish that every home service is reachable remotely. Service-specific access should be tested independently.

## Private DNS

AdGuard Home is the DNS service for the Astra home network.

Tailscale Split DNS is configured so that queries for the private home.arpa namespace are sent to the Astra DNS server rather than the tailnet's general DNS resolver.

This avoids publishing the private service names to public DNS.

The exact DNS records and private addresses are intentionally omitted from this public repository.

### Validation

The following was verified:

1. The private service name resolves correctly when the client uses the Astra DNS server.
2. The same name was initially unresolved through the Tailscale default resolver.
3. Tailscale Split DNS was configured for the private namespace.
4. The private service subsequently loaded from the iPhone while away from the home Wi-Fi network.

**Status: Passed for the tested private namespace and endpoint.**

## HTTPS and certificate trust

Nginx Proxy Manager terminates HTTPS for the private service portal.

The Astra service certificate:

- is issued by the Astra Root CA;
- contains a wildcard SAN covering the Astra service namespace;
- is presented through Nginx Proxy Manager;
- chains back to the Astra Root CA.

The Astra Root CA was imported into the test client and the previous browser **Not Secure** warning disappeared.

The certificate and private key are not stored in GitHub.

### Validation

Certificate inspection confirmed:

- subject: wildcard Astra service certificate;
- issuer: Astra Root CA;
- validity period includes the test date;
- SAN contains the wildcard service namespace;
- the full chain contains the service certificate followed by the Astra Root CA.

Nginx Proxy Manager also passed its configuration syntax test and could reach the Homepage container over the Docker network.

**Status: Passed for the tested service.**

## Security decisions

| Decision | Rationale |
| --- | --- |
| Tailscale as remote-access boundary | Avoids exposing management services directly to the public internet |
| Subnet route limited to home LAN | Reduces the scope of remote network access |
| Split DNS for private namespace | Keeps internal service names private while allowing remote resolution |
| AdGuard Home as internal DNS | Centralises local DNS resolution and filtering |
| Nginx Proxy Manager for HTTPS | Provides one service entry point and TLS termination |
| Private Astra Root CA | Allows trusted HTTPS for internal-only services |
| Tailscale remains on endpoints | Avoids coupling the travel router to the remote-access control plane |
| No public DNS records for private services | Prevents accidental publication of internal service names |

## Limitations

This milestone is an end-to-end validation of the tested path, not a complete remote-access acceptance test for the entire lab.

It does not prove:

- every Docker service is reachable remotely;
- every endpoint has Tailscale configured;
- application-level authentication is correctly configured for every service;
- DNS remains available during every possible home-network failure;
- the certificate authority has a complete automated renewal/revocation process;
- the home network has been segmented into VLANs.

Those remain separate operational or future validation exercises.

## Recovery considerations

If AdGuard Home is unavailable, private DNS names may stop resolving through the configured Split DNS path. A recovery plan should therefore preserve direct management access to the Pi and a known-good DNS configuration.

If the Astra Root CA is unavailable or removed from a client, the service may still be reachable but the client may no longer trust the HTTPS certificate.

If the Pi is offline, its Tailscale subnet route and services hosted on the Pi are unavailable through this path.

These dependencies should be considered before future changes to DNS, certificates, Docker networking or Tailscale.

## Evidence standard

Public documentation records the architecture and outcome only. Do not publish:

- private DNS zone files;
- real home IP addresses;
- Tailscale auth keys;
- certificate private keys;
- device serial numbers;
- personal account identifiers;
- raw terminal output containing sensitive infrastructure details.

**Milestone:** Remote access + private DNS + trusted TLS — **validated 26 September 2026**.
