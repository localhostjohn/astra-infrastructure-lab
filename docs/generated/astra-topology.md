# Astra Raspberry Pi — Generated Topology

> Generated from the sanitised v0.3 discovery model. Connections shown are Docker network memberships observed by the collector.

```mermaid
flowchart LR
    LAN["LAN / Ethernet"] --> PI["astra-pi"]
    TS["Tailscale"] --> PI
    PI --> N1["Docker: authentik_default"]
    N1 --> N1C1["authentik-postgresql"]
    N1 --> N1C2["authentik-server"]
    N1 --> N1C3["authentik-worker"]
    PI --> N2["Docker: bridge"]
    N2 --> N2C1["portainer"]
    PI --> N3["Docker: homepage_default"]
    N3 --> N3C1["homepage"]
    PI --> N4["Docker: host"]
    N4 --> N4C1["adguardhome"]
    N4 --> N4C2["netalertx"]
    N4 --> N4C3["node-exporter"]
    PI --> N5["Docker: monitoring_default"]
    N5 --> N5C1["grafana"]
    N5 --> N5C2["prometheus"]
    PI --> N6["Docker: uptime-kuma_default"]
    N6 --> N6C1["uptime-kuma"]
```

Only observed Docker network membership is represented; application-level dependencies are not inferred.
