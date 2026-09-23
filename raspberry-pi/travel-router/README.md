# Raspberry Pi Travel Router

This workstream documents a portable OpenWrt travel router based on a Raspberry Pi 3 Model B.

## Design

- **LAN/private Wi-Fi:** built-in Raspberry Pi 2.4 GHz radio
- **Private SSID:** `Astra-Travel`
- **Travel LAN:** `10.77.0.0/24`
- **Router/management address:** `10.77.0.1`
- **AP channel:** fixed channel 1
- **WAN/upstream Wi-Fi:** USB AC1200 adapter (Realtek RTL8822BU family)
- **Upstream manager:** Travelmate 2.2.1-r6
- **Travelmate interface:** `trm_wwan`, DHCP, metric 100, WAN firewall zone
- **Operating system:** OpenWrt 24.10.7
- **Remote home-lab access:** Tailscale is planned as a separate secure overlay

## Status

The core travel router and Travelmate upstream-management workflow are **complete and validated**.

The private AP, DHCP, wireless management, NAT/routing, USB Wi-Fi WAN and Internet access have all been tested. The configuration has survived both a normal reboot and a full power-off/power-on, and the router has been validated in standalone mode with **no Ethernet cable connected**.

Travelmate is restricted to the USB WAN radio (`radio1`). The previous `wwan_usb` logical interface was migrated to the dedicated Travelmate-managed `trm_wwan` interface and then removed. Cold-boot recovery, switching to a completely different upstream hotspot, and automatic recovery when that hotspot disappeared have all been validated.

The initial AP persistence issue was traced to hostapd Automatic Channel Selection on the built-in radio. OpenWrt created the AP interface, but ACS failed to collect survey data and hostapd disabled the AP. Fixing the built-in radio to channel 1 resolved the issue and has remained persistent across cold boots.

See the [engineering journal entry](../../docs/engineering-journal/entries/2026-09-22-raspberry-pi-travel-router.md) for the implementation record, troubleshooting evidence and acceptance tests.

## Validated behaviour

- `Astra-Travel` starts automatically.
- Clients receive `10.77.0.x` addresses from OpenWrt DHCP.
- LuCI is reachable wirelessly at `10.77.0.1`.
- Internet access routes through the USB AC1200 Wi-Fi WAN.
- Travelmate manages upstream Wi-Fi through `trm_wwan`.
- Travelmate is restricted to `radio1`, leaving `radio0` dedicated to `Astra-Travel`.
- The obsolete `wwan_usb` interface has been removed.
- Travelmate reconnects after a full cold boot.
- A second phone hotspot was successfully added as an alternative upstream and used for Internet access without disconnecting clients from `Astra-Travel`.
- When the active hotspot disappeared, Travelmate detected loss of signal and automatically recovered to the saved home uplink in approximately 48 seconds.
- LuCI and normal web access remained available after upstream recovery.
- The router survives reboot and full power cycles.
- Normal operation requires only power and the USB Wi-Fi adapter; Ethernet is not required.
- The travel Wi-Fi credential was rotated after testing and is not stored in the repository.

## Remaining travel-environment validation

The core router and upstream switching behaviour are complete. Remaining work is real-world validation rather than a core-build blocker:

- Validate an authorised captive portal in a real guest/travel environment.
- Document any captive-portal MAC-binding behaviour encountered.
- Install and validate Tailscale on the travel MacBook for access back to the Astra home lab.

## Security notes

- No Wi-Fi pre-shared keys or credentials are committed.
- Captive-portal registration, terms, MFA and other access controls must be completed normally; the router is not intended to bypass them.
- OpenWrt LAN DHCP must not be allowed to compete with the existing home router.
- Do not connect the Pi's OpenWrt LAN Ethernet interface directly to the normal home LAN while its DHCP server is active.
- Management services should not be exposed directly to public/guest Wi-Fi.
- Public/captive-portal testing should be performed only on networks the operator is authorised to use.
