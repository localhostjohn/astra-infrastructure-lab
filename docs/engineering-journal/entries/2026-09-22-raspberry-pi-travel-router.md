# Raspberry Pi travel router — build and validation

**Date:** 22–23 September 2026  
**Status:** Core build complete — standalone operation and cold-boot persistence validated

## Objective

Repurpose a Raspberry Pi 3 Model B as a compact travel router for use with hotel, Airbnb and other guest Wi-Fi. The design gives personal devices a consistent private SSID while a separate USB Wi-Fi adapter handles the changing upstream wireless network.

The validated traffic path is:

```text
Personal device
    |
    | Astra-Travel (2.4 GHz)
    v
Raspberry Pi 3 / OpenWrt
LAN: 10.77.0.0/24
Router: 10.77.0.1
    |
    | USB Wi-Fi client (5 GHz where available)
    v
Hotel / guest / upstream Wi-Fi
    |
    v
Internet
```

Remote access to the main Astra home lab remains a separate Tailscale layer rather than exposing management services directly to public Wi-Fi.

## Hardware and software

- Raspberry Pi 3 Model B Rev 1.2
- OpenWrt 24.10.7
- Built-in Cypress 2.4 GHz Wi-Fi used for the private access point
- USB AC1200 adapter using the Realtek RTL8822BU family, used for upstream Wi-Fi
- OpenWrt LAN address: `10.77.0.1/24`
- Private SSID: `Astra-Travel`
- Built-in AP fixed to channel 1
- USB WAN validated on 5 GHz

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
11. Enabled LAN DHCP and validated client addressing on `10.77.0.0/24`.
12. Diagnosed and corrected the AP persistence fault described below.
13. Validated wireless OpenWrt management at `10.77.0.1`.
14. Validated end-to-end Internet access from an iPhone connected to `Astra-Travel`, with cellular connectivity assistance disabled.
15. Repeated validation after reboot and after a full power-off/power-on.
16. Removed the Ethernet recovery connection and validated fully standalone operation.
17. Rotated the `Astra-Travel` Wi-Fi password after testing; no credential is recorded here.
18. Confirmed the USB WAN radio can scan for alternative upstream networks while the private AP remains active.

## Fault investigation and fix

The first reboot exposed a persistence fault: `Astra-Travel` disappeared even though its UCI configuration was present.

The saved configuration used:

```text
wireless.radio0.channel='auto'
```

Boot logs showed hostapd attempting Automatic Channel Selection (ACS), followed by:

```text
ACS: Unable to collect survey data
ACS: All study options have failed
Interface initialization failed
phy1-ap0: AP-DISABLED
```

The built-in Broadcom/Cypress radio was therefore creating the interface but hostapd could not complete ACS.

The fix was to use a known working fixed 2.4 GHz channel:

```text
wireless.radio0.channel='1'
```

After committing the change and bringing up radio0, hostapd reported:

```text
phy1-ap0: interface state COUNTRY_UPDATE->ENABLED
phy1-ap0: AP-ENABLED
```

The fixed channel persisted through subsequent reboot and cold-boot tests.

## Validation results

A test iPhone joined `Astra-Travel` and received:

- IPv4 address: `10.77.0.217`
- subnet mask: `255.255.255.0`
- router: `10.77.0.1`

With cellular connectivity assistance disabled, normal Internet browsing succeeded. This proved the complete path from the private AP through OpenWrt NAT/firewalling and the USB wireless WAN.

A later direct-Ethernet recovery test also demonstrated that OpenWrt DHCP correctly issued `10.77.0.175` to a Windows client. The Windows Ethernet adapter was subsequently returned to normal automatic DHCP operation.

Final standalone acceptance testing was performed with **no Ethernet cable connected to the Pi**. After a full power-off/power-on:

- `Astra-Travel` returned automatically.
- The client reconnected using the rotated password.
- OpenWrt remained reachable wirelessly at `10.77.0.1`.
- External Internet access succeeded.
- The USB AC1200 adapter remained available for upstream Wi-Fi.

## Safety decision

LAN DHCP was deliberately disabled while the Pi Ethernet interface was connected to the existing home network. This prevented the OpenWrt DHCP server from competing with the existing home router.

Once OpenWrt LAN DHCP was enabled, the Pi was not connected to the normal home Ethernet LAN. Direct Pi-to-workstation Ethernet was used only as an isolated recovery path.

## Acceptance criteria

The core travel-router acceptance criteria are now met:

- [x] Private `Astra-Travel` SSID starts automatically.
- [x] Client receives an OpenWrt DHCP lease.
- [x] OpenWrt management is available wirelessly at `10.77.0.1`.
- [x] Internet traffic routes through the USB Wi-Fi WAN.
- [x] DNS/normal web access works from a private client.
- [x] Configuration survives reboot.
- [x] Configuration survives full power-off/power-on.
- [x] Router operates standalone with no Ethernet connection.
- [x] USB WAN can scan for alternative upstream Wi-Fi while the private AP remains available.

## Remaining travel-environment validation

The core router is complete. The following are useful follow-up tests rather than blockers:

1. Join a different phone/hotspot or guest Wi-Fi using the USB WAN radio while remaining connected to `Astra-Travel`.
2. Validate a real captive-portal workflow on an authorised guest network.
3. Document any MAC-binding/cloning requirements encountered by captive portals.
4. Install and validate Tailscale on the travel MacBook for secure access back to the main Astra environment.

## Lessons learned

This build demonstrates more than creating another Wi-Fi network. It required explicit LAN/WAN separation, safe DHCP handling, third-party USB driver validation, route testing, hostapd troubleshooting, interpretation of ACS failure logs, persistence testing, credential rotation and an isolated recovery path.

The most important troubleshooting lesson was that an interface existing in `iw dev` did not prove the AP was usable. Hostapd state and logs identified the actual failure, and replacing automatic channel selection with a fixed validated channel produced repeatable cold-boot behaviour.
