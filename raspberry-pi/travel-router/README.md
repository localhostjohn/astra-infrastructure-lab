# Raspberry Pi Travel Router

This workstream documents a portable OpenWrt travel router based on a Raspberry Pi 3 Model B.

## Design

- **LAN/private Wi-Fi:** built-in Raspberry Pi 2.4 GHz radio
- **Private SSID:** `Astra-Travel`
- **Travel LAN:** `10.77.0.0/24`
- **Router/management address:** `10.77.0.1`
- **AP channel:** fixed channel 1
- **WAN/upstream Wi-Fi:** USB AC1200 adapter (Realtek RTL8822BU family)
- **Operating system:** OpenWrt 24.10.7
- **Remote home-lab access:** Tailscale is planned as a separate secure overlay

## Status

The core travel router is **complete and validated**.

The private AP, DHCP, wireless management, NAT/routing, USB Wi-Fi WAN and Internet access have all been tested. The configuration has survived both a normal reboot and a full power-off/power-on, and the router has been validated in standalone mode with **no Ethernet cable connected**.

The initial AP persistence issue was traced to hostapd Automatic Channel Selection on the built-in radio. OpenWrt created the AP interface, but ACS failed to collect survey data and hostapd disabled the AP. Fixing the built-in radio to channel 1 resolved the issue and has remained persistent across cold boots.

The USB WAN radio can also scan for alternative upstream networks while `Astra-Travel` remains active, which provides the basis for changing hotel/Airbnb/guest Wi-Fi without an Ethernet recovery connection.

See the [engineering journal entry](../../docs/engineering-journal/entries/2026-09-22-raspberry-pi-travel-router.md) for the implementation record, troubleshooting evidence and acceptance tests.

## Validated behaviour

- `Astra-Travel` starts automatically.
- Clients receive `10.77.0.x` addresses from OpenWrt DHCP.
- LuCI is reachable wirelessly at `10.77.0.1`.
- Internet access routes through the USB AC1200 Wi-Fi WAN.
- The router survives reboot and full power cycles.
- Normal operation requires only power and the USB Wi-Fi adapter; Ethernet is not required.
- The travel Wi-Fi credential was rotated after testing and is not stored in the repository.

## Remaining optional tests

- Switch the USB WAN to a different hotspot/guest SSID while managing OpenWrt through `Astra-Travel`.
- Validate an authorised captive portal in a real travel environment.
- Document any captive-portal MAC-binding/cloning behaviour.
- Install and validate Tailscale on the travel MacBook for access back to the Astra home lab.

## Security notes

- No Wi-Fi pre-shared keys or credentials are committed.
- OpenWrt LAN DHCP must not be allowed to compete with the existing home router.
- Do not connect the Pi's OpenWrt LAN Ethernet interface directly to the normal home LAN while its DHCP server is active.
- Management services should not be exposed directly to public/guest Wi-Fi.
- Public/captive-portal testing should be performed only on networks the operator is authorised to use.
