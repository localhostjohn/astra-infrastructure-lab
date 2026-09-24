# Raspberry Pi travel router — build and validation

**Date:** 22–24 September 2026  
**Status:** Core build, Travelmate upstream switching and configuration cleanup complete — standalone, cold-boot, failback and recovery checkpoint validated

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
    | Travelmate / trm_wwan
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
- Travelmate 2.2.1-r6 with LuCI integration
- Built-in Cypress 2.4 GHz Wi-Fi used for the private access point
- USB AC1200 adapter using the Realtek RTL8822BU family, used for upstream Wi-Fi
- OpenWrt LAN address: `10.77.0.1/24`
- Private SSID: `Astra-Travel`
- Built-in AP fixed to channel 1
- USB WAN validated on 5 GHz
- Travelmate logical uplink: `trm_wwan`, DHCP, metric 100, WAN firewall zone
- Travelmate radio selection restricted to `radio1`

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
18. Installed Travelmate 2.2.1-r6 and its LuCI integration.
19. Created the Travelmate `trm_wwan` DHCP interface with metric 100 in the WAN firewall zone.
20. Restricted Travelmate to the USB upstream radio (`radio1`) so the built-in radio remains dedicated to the private AP.
21. Migrated the existing upstream station from `wwan_usb` to `trm_wwan`.
22. Removed the obsolete `wwan_usb` interface and firewall-zone reference after validating the migration.
23. Validated Travelmate recovery after a full cold boot with no Ethernet connected.
24. Added a second phone hotspot as an alternative upstream and successfully switched `radio1` to it while clients remained on `Astra-Travel`.
25. Validated LuCI and normal Internet access through the alternative hotspot with client mobile-data fallback disabled.
26. Turned off the active hotspot to simulate an upstream disappearing unexpectedly.
27. Observed Travelmate detect loss of signal and automatically recover to the saved home uplink in approximately 48 seconds.
28. Revalidated normal web access after automatic recovery.
29. Removed the obsolete disabled `radio0` upstream station that still referenced the legacy `wwan` network.
30. Removed the disabled default `OpenWrt` access point from `radio1`, leaving the USB radio dedicated to Travelmate upstream use.
31. Removed the now-orphaned `wwan` logical interface and its WAN firewall-zone reference after confirming all active upstream stations use `trm_wwan`.
32. Rebooted OpenWrt and confirmed `Astra-Travel` returned successfully. A Windows saved-profile association issue was resolved by forgetting and re-adding the SSID; a phone connected normally throughout, confirming the AP itself was healthy.
33. Confirmed Travelmate returned as `connected (net ok/100)` on `radio1` / `trm_wwan` after reboot.
34. Revalidated router Internet connectivity with four ICMP probes to `1.1.1.1`; all four succeeded with 0% packet loss.
35. Created a known-good OpenWrt configuration backup named `astra-travel-openwrt-known-good-2026-09-24.tar.gz`, copied it off `/tmp` to private workstation storage using SCP, and verified the local file size as 7,248 bytes. The archive is intentionally not committed because it may contain credentials.

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

## Travelmate migration

Travelmate was introduced after the core AP/WAN design was stable. The wizard created a dedicated upstream interface:

```text
network.trm_wwan.proto='dhcp'
network.trm_wwan.metric='100'
```

The interface was placed in the existing WAN firewall zone. Travelmate was then restricted to `radio1`, preventing it from interfering with the built-in `radio0` access point.

The existing saved upstream station was migrated from the original `wwan_usb` network to `trm_wwan`. Once Internet access and Travelmate status were confirmed, the obsolete `wwan_usb` interface and its WAN-zone membership were removed.

The resulting separation is:

```text
radio0 -> Astra-Travel -> LAN 10.77.0.0/24
radio1 -> Travelmate -> trm_wwan -> WAN zone -> upstream Wi-Fi
```

## Upstream switching and failback validation

A second Android phone hotspot was used as a stand-in for hotel or guest Wi-Fi.

Both the home uplink and the temporary hotspot were stored as Travelmate stations. The home uplink was disabled for the changeover test and Travelmate was restarted. Travelmate subsequently logged a successful connection to the alternative hotspot.

While the hotspot was active:

- the test client remained associated with `Astra-Travel`;
- LuCI remained reachable at `10.77.0.1`;
- normal Internet browsing succeeded with cellular connectivity assistance disabled on the test client.

For failback testing, both saved uplinks were enabled and the active hotspot was then turned off without making any OpenWrt changes. Travelmate logged:

```text
20:23:34  no signal from uplink
20:24:22  connected to uplink 'radio1/InvolveRestrictedAccess/-'
```

This is approximately 48 seconds from loss detection to successful recovery. Normal web access through `Astra-Travel` was then confirmed again.

This validates that client devices can remain on a consistent private LAN while the travel router changes or recovers its external Wi-Fi connection.

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
- Travelmate automatically recovered the saved upstream through `radio1`.

## Configuration cleanup and recovery checkpoint — 24 September 2026

After Travelmate failover testing was complete, the saved OpenWrt configuration was reviewed for legacy entries. The disabled built-in-radio upstream station, the disabled default `OpenWrt` AP on the USB radio, and the old `wwan` logical interface/firewall membership were no longer required and were removed. Active upstream configuration remained on `radio1` through `trm_wwan`.

The router was then rebooted. `Astra-Travel` returned, Travelmate reported `connected (net ok/100)`, and the router completed a four-packet test to `1.1.1.1` with 0% loss. This established the cleaned configuration as the new known-good state.

A configuration backup was created with:

```text
sysupgrade -b /tmp/astra-travel-openwrt-known-good-2026-09-24.tar.gz
```

The backup was copied off the router to private workstation storage and verified locally as 7,248 bytes. Because OpenWrt configuration archives can include wireless credentials and other sensitive values, the archive itself is deliberately excluded from the public repository. Only the filename, creation process and validation checkpoint are documented here.

## Safety decision

LAN DHCP was deliberately disabled while the Pi Ethernet interface was connected to the existing home network. This prevented the OpenWrt DHCP server from competing with the existing home router.

Once OpenWrt LAN DHCP was enabled, the Pi was not connected to the normal home Ethernet LAN. Direct Pi-to-workstation Ethernet was used only as an isolated recovery path.

Captive-portal registration, terms, MFA and other network access controls will be completed normally. The travel router is not intended to bypass guest-network controls.

## Acceptance criteria

The travel-router acceptance criteria are now met:

- [x] Private `Astra-Travel` SSID starts automatically.
- [x] Client receives an OpenWrt DHCP lease.
- [x] OpenWrt management is available wirelessly at `10.77.0.1`.
- [x] Internet traffic routes through the USB Wi-Fi WAN.
- [x] DNS/normal web access works from a private client.
- [x] Configuration survives reboot.
- [x] Configuration survives full power-off/power-on.
- [x] Router operates standalone with no Ethernet connection.
- [x] Travelmate manages the USB upstream through `trm_wwan`.
- [x] Travelmate cold-boot recovery is successful.
- [x] USB WAN can join a different upstream while the private AP remains available.
- [x] Client management and Internet access work through the alternative upstream.
- [x] Travelmate automatically recovers to another saved uplink when the active upstream disappears.
- [x] Internet access remains functional after automatic failback.
- [x] Legacy `radio0` station, default `radio1` AP and obsolete `wwan` interface references have been removed.
- [x] Cleaned configuration survives reboot with Travelmate and Internet access healthy.
- [x] Known-good configuration backup created, copied off-router and verified without committing the sensitive archive.

## Remaining travel-environment validation

The core router and Travelmate switching behaviour are complete. Remaining work is real-world validation rather than a blocker:

1. Validate a real captive-portal workflow on an authorised guest network.
2. Document any MAC-binding behaviour encountered by captive portals.
3. Install and validate Tailscale on the travel MacBook for secure access back to the main Astra environment.

## Lessons learned

This build demonstrates more than creating another Wi-Fi network. It required explicit LAN/WAN separation, safe DHCP handling, third-party USB driver validation, route testing, hostapd troubleshooting, interpretation of ACS failure logs, persistence testing, credential rotation, upstream lifecycle management and an isolated recovery path.

The most important AP troubleshooting lesson was that an interface existing in `iw dev` did not prove the AP was usable. Hostapd state and logs identified the actual failure, and replacing automatic channel selection with a fixed validated channel produced repeatable cold-boot behaviour.

Travelmate testing added a second operational lesson: an immediate status check can show `running (not connected)` while the service is still scanning and associating. Runtime logs provided the authoritative sequence and demonstrated successful alternative-uplink connection and automatic recovery.
