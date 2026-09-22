# Raspberry Pi Travel Router

This workstream documents the build and validation of a portable OpenWrt travel router based on a Raspberry Pi 3 Model B.

## Intended design

- **LAN/private Wi-Fi:** built-in Raspberry Pi 2.4 GHz radio
- **Private SSID:** `Astra-Travel`
- **Travel LAN:** `10.77.0.0/24`
- **Router address:** `10.77.0.1`
- **WAN/upstream Wi-Fi:** USB AC1200 adapter (Realtek RTL8822BU family)
- **Operating system:** OpenWrt 24.10.7
- **Remote home-lab access:** Tailscale is planned as a separate secure overlay

## Current status

The USB wireless WAN has been validated against a test upstream network, including an Internet test forced through the USB station interface. The `Astra-Travel` access point was configured and observed active before reboot, but it did not appear in a Windows wireless scan after the first isolated reboot.

The build therefore remains **in progress**. No end-to-end or reboot-persistence success is claimed yet.

See the [22 September 2026 engineering journal entry](../../docs/engineering-journal/entries/2026-09-22-raspberry-pi-travel-router.md) for the implementation record, safety decisions, current fault and next validation steps.

## Security notes

- No Wi-Fi pre-shared keys or credentials are committed.
- LAN DHCP must not be allowed to compete with the existing home router.
- The Pi should remain isolated from the normal home Ethernet LAN while its OpenWrt LAN DHCP service is enabled.
- Management services should not be exposed directly to public/guest Wi-Fi.
- Public/captive-portal testing should be performed only on networks the operator is authorised to use.
