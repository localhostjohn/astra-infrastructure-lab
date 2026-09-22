# Raspberry Pi travel router — initial build

**Date:** 22 September 2026  
**Status:** In progress — upstream Wi-Fi validated; private AP requires post-reboot recovery/validation

## Objective

Repurpose a Raspberry Pi 3 Model B as a compact travel router for use with hotel, Airbnb and other guest Wi-Fi. The design should give personal devices a consistent private SSID while a separate USB Wi-Fi adapter handles the changing upstream wireless network.

The intended traffic path is:

```text
Personal device
    |
    | Astra-Travel (2.4 GHz)
    v
Raspberry Pi 3 / OpenWrt
LAN: 10.77.0.0/24
    |
    | USB Wi-Fi client
    v
Hotel / guest Wi-Fi
    |
    v
Internet
```

Remote access to the main Astra home lab will remain a separate Tailscale layer rather than exposing management services directly to public Wi-Fi.

## Hardware and software

- Raspberry Pi 3 Model B Rev 1.2
- OpenWrt 24.10.7
- Built-in Cypress 2.4 GHz Wi-Fi intended for the private access point
- USB AC1200 adapter using the Realtek RTL8822BU family, intended for upstream Wi-Fi
- OpenWrt LAN address: `10.77.0.1/24`
- Planned private SSID: `Astra-Travel`

No wireless passwords or other credentials are stored in this repository.

## Work completed

1. Installed OpenWrt for the Raspberry Pi 3 (`bcm27xx/bcm2710`).
2. Changed the OpenWrt management LAN from its default to `10.77.0.1/24`.
3. Installed the OpenWrt `rtw88_8822bu` driver stack for the USB Wi-Fi adapter.
4. Confirmed the USB adapter appeared as a second wireless radio.
5. Configured the USB radio as a wireless client on a test upstream network.
6. Assigned the USB client to a WAN-side logical network/firewall zone.
7. Validated that the USB client obtained an upstream DHCP lease and default route.
8. Forced an Internet test through the USB station interface; four ICMP probes to `1.1.1.1` succeeded with 0% loss.
9. Disabled the temporary built-in-radio upstream client so the USB adapter became the sole wireless WAN.
10. Configured the built-in radio as the `Astra-Travel` access point on the LAN side.
11. Prepared the LAN DHCP scope with leases beginning at `10.77.0.100`.

## Safety decision

LAN DHCP was deliberately disabled while the Pi Ethernet interface was connected to the existing home network. This prevented the OpenWrt DHCP server from competing with the existing home router.

The saved DHCP configuration was enabled only immediately before isolating the Pi from the home Ethernet network. The Pi must not be reconnected to the normal home LAN in this state without first reviewing the interface/DHCP design.

## Current issue

Before reboot, `Astra-Travel` was visible as an active access point and the USB adapter remained connected to the upstream 5 GHz Wi-Fi.

After the Pi was isolated from Ethernet and rebooted, a Windows wireless scan no longer detected `Astra-Travel`. The upstream configuration had previously been validated, so the next session will focus on why the built-in radio/AP did not return after reboot.

This is intentionally recorded as an unresolved result rather than claiming the travel router is complete.

## Next test session

1. Connect the Windows workstation directly to the Pi Ethernet port.
2. Use the temporary management address `10.77.0.2/24` on the workstation and verify `10.77.0.1` responds.
3. SSH to OpenWrt and inspect:
   - `wifi status`
   - `ubus call network.wireless status`
   - `uci show wireless`
   - relevant `logread` output
4. Determine why the built-in radio/AP did not persist after reboot.
5. Restore `Astra-Travel` without disturbing the validated USB WAN.
6. Join a test client to `Astra-Travel` and confirm it receives a `10.77.0.x` DHCP lease.
7. Validate gateway reachability, DNS resolution and Internet access through the USB WAN.
8. Reboot again and prove the complete configuration persists.
9. Test against a phone hotspot as a safer simulation of a changing hotel/guest network.
10. Document captive-portal behaviour and recovery procedure.

## Acceptance criteria

The travel router will not be marked complete until a client can join `Astra-Travel`, receive an address from OpenWrt, resolve DNS, reach the Internet through the USB Wi-Fi WAN, and repeat the same behaviour after a cold reboot.

## Lessons so far

The main engineering value of the build is not simply creating another Wi-Fi network. It requires explicit separation of LAN and WAN roles, safe DHCP handling, driver validation, route testing, persistence testing and a recovery path that does not risk disrupting the existing home network.
