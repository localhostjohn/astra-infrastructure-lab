# Astra Travel Router Runbook

Operational runbook for the Raspberry Pi 3 Model B OpenWrt travel router.

> **Purpose:** provide a repeatable procedure for using, validating and recovering the Astra travel router while away from home.

## Known-good design

```text
Client device
    |
    | Astra-Travel
    v
radio0 / OpenWrt LAN
10.77.0.0/24
Router: 10.77.0.1
    |
    | NAT / firewall
    v
Travelmate / trm_wwan
    |
    v
radio1 / USB AC1200
    |
    v
Hotel / Airbnb / authorised guest Wi-Fi
    |
    v
Internet
```

- OpenWrt: 24.10.7
- Travelmate: 2.2.1-r6
- Private SSID: `Astra-Travel`
- Management address: `10.77.0.1`
- `radio0`: private 2.4 GHz AP, fixed channel 1
- `radio1`: USB AC1200 upstream Wi-Fi
- Travelmate interface: `trm_wwan`
- Travelmate is restricted to `radio1`
- Captive portal detection is enabled
- MAC randomisation is disabled
- Ethernet is not required for normal operation
- Tailscale is intentionally kept off the router; authorised endpoint devices join the tailnet individually

## Before travelling

1. Confirm the USB AC1200 adapter is attached.
2. Power on the router and allow it to boot.
3. Connect a client to `Astra-Travel`.
4. Open LuCI at `http://10.77.0.1`.
5. Confirm Travelmate is available under **Services > Travelmate**.
6. Confirm normal Internet access using a known upstream before departure.
7. Keep the current OpenWrt root password and `Astra-Travel` password available securely. Do not store credentials in this repository.
8. Keep the known-good OpenWrt backup in private storage.

Known-good backup checkpoint:

```text
astra-travel-openwrt-known-good-2026-09-24.tar.gz
```

The backup archive is deliberately not committed because OpenWrt configuration backups may contain credentials.

## Arriving at a hotel, Airbnb or guest network

### 1. Start the router

Connect power with the USB AC1200 adapter already attached. Allow approximately 1–2 minutes for OpenWrt and Travelmate to start.

Do not connect the OpenWrt LAN Ethernet port to an unknown or normal LAN as part of the standard travel workflow.

### 2. Join Astra-Travel

On the MacBook, phone or other client:

1. Connect to `Astra-Travel`.
2. Confirm the client receives a `10.77.0.x` address.
3. Open `http://10.77.0.1`.
4. Confirm LuCI loads.

If LuCI loads, the private LAN is operational even if the router does not yet have Internet access.

### 3. Add the venue Wi-Fi

In LuCI:

1. Open **Services > Travelmate**.
2. Open **Wireless Stations**.
3. Scan using **radio1** only.
4. Identify the venue's authorised guest SSID.
5. Add it as a Travelmate uplink using `trm_wwan`.
6. If the Wi-Fi itself requires a pre-shared key, enter it privately in LuCI.
7. Save and apply the change.

Do not paste guest-network credentials, registration details, MFA codes or Wi-Fi passwords into project documentation.

### 4. Captive portal

If the guest network uses browser registration, terms or sign-in:

1. Remain connected to `Astra-Travel`.
2. Allow Travelmate to associate `radio1` with the guest SSID.
3. Open a normal browser on the client.
4. If the portal does not appear automatically, open `http://neverssl.com` to generate a plain HTTP request that may trigger the authorised portal redirect.
5. Complete the venue's registration, terms, sign-in or MFA normally.
6. Do not attempt to bypass device limits, authentication, payment, terms or other access controls.

The upstream MAC should normally remain stable because Travelmate MAC randomisation is disabled. Some captive portals may associate authorisation with the router's upstream radio MAC.

Only use the travel router where the network operator permits personal routers/rebroadcast/NAT.

## Validation after connecting

Confirm all of the following:

- client remains connected to `Astra-Travel`;
- LuCI opens at `10.77.0.1`;
- Travelmate reports a connected/healthy upstream;
- normal websites load;
- client cellular fallback is disabled during acceptance testing where practical, so it cannot hide a routing failure.

For SSH diagnostics from a connected client:

```text
ssh root@10.77.0.1
```

Then:

```text
/etc/init.d/travelmate status
ping -c 4 1.1.1.1
```

A successful known-good state has previously shown Travelmate as `connected (net ok/100)` and four successful probes with 0% packet loss.

## If Internet is not available

Work from LAN to WAN rather than changing several settings at once.

### A. Can the client reach OpenWrt?

Try:

```text
http://10.77.0.1
```

If this works, `Astra-Travel` and the private LAN are functioning. Continue upstream troubleshooting.

### B. Check Travelmate

SSH to the router and run:

```text
/etc/init.d/travelmate status
```

Travelmate can temporarily show `running (not connected)` while scanning or associating. Do not treat one immediate status check as a permanent failure.

Inspect the recent Travelmate sequence with:

```text
logread -e "trm-" | tail -n 50
```

### C. Test router Internet connectivity

```text
ping -c 4 1.1.1.1
```

If this works from OpenWrt but a client cannot browse, investigate DNS/captive-portal state before changing the radio configuration.

### D. Suspect a captive portal

Try `http://neverssl.com` from the client and complete any legitimate portal flow.

If the portal refuses the connection or the venue prohibits NAT/rebroadcast, stop rather than attempting to circumvent the restriction.

## Upstream disappears

Travelmate has already been validated recovering automatically when an active hotspot disappeared. In testing, loss detection to reconnection on another saved uplink took approximately 48 seconds.

Allow Travelmate time to scan and recover before making manual changes.

Check:

```text
/etc/init.d/travelmate status
```

and, if required:

```text
logread -e "trm-" | tail -n 50
```

Client devices should remain connected to `Astra-Travel` while the upstream changes.

## Astra-Travel does not appear

1. Wait for OpenWrt to finish booting.
2. Check from a second client before assuming the AP has failed. A Windows saved Wi-Fi profile has previously produced a client-side **Can't connect to this network** error while a phone connected successfully.
3. On Windows, forgetting and re-adding the `Astra-Travel` profile resolved that client-side issue.
4. If multiple clients cannot see/connect to the AP, use an isolated direct-Ethernet recovery connection if available and inspect OpenWrt/hostapd state.

The previous OpenWrt AP persistence fault was caused by Automatic Channel Selection. The known-good configuration fixes `radio0` to channel 1. Do not return it to automatic channel selection without a reason and a new validation cycle.

## Reboot / power-cycle recovery

A normal reboot and full cold boot have both been validated.

After reboot:

1. Wait approximately 1–2 minutes.
2. Reconnect to `Astra-Travel`.
3. Confirm LuCI at `10.77.0.1`.
4. Check Travelmate status.
5. Confirm Internet access.

Avoid changing configuration during the initial Travelmate scan/association period.

## Configuration backup and restore

Known-good backup:

```text
astra-travel-openwrt-known-good-2026-09-24.tar.gz
```

It was created with:

```text
sysupgrade -b /tmp/astra-travel-openwrt-known-good-2026-09-24.tar.gz
```

and copied off the router to private storage.

Treat the archive as sensitive. Do not upload it to the public repository, paste its contents into issues, or share it publicly.

A restore should be used as a recovery action only when necessary. Before restoring, confirm the backup belongs to the expected OpenWrt travel-router build and preserve any newer configuration that may be required.

## Tailscale design and client validation

On 25 September 2026, Tailscale was temporarily installed on the OpenWrt router and confirmed running. It was then deliberately removed. The operational design is to keep the router responsible for Wi-Fi routing/upstream management and keep Tailscale on individual authorised client devices.

Tailscale on the travel MacBook is therefore a separate endpoint overlay and does not replace the OpenWrt/Travelmate WAN workflow.

Planned validation:

1. Install Tailscale on the travel MacBook.
2. Join the existing authorised tailnet.
3. Connect the MacBook to `Astra-Travel`.
4. Confirm normal Internet access through the travel router.
5. Confirm permitted Astra home-lab resources are reachable through Tailscale.
6. Reconnect/reboot and repeat the test.

Do not expose Astra management services directly to hotel/public Wi-Fi to replace Tailscale.

## Known-good acceptance checklist

- [x] `Astra-Travel` starts automatically.
- [x] Client DHCP works on `10.77.0.0/24`.
- [x] LuCI is reachable at `10.77.0.1`.
- [x] USB `radio1` provides the upstream Wi-Fi connection.
- [x] Travelmate manages upstreams through `trm_wwan`.
- [x] Router works without Ethernet.
- [x] Reboot persistence validated.
- [x] Cold-boot persistence validated.
- [x] Alternative upstream validated.
- [x] Automatic upstream recovery/failback validated.
- [x] Legacy wireless/network configuration removed.
- [x] Known-good private backup created and copied off-router.
- [x] Router-level Tailscale evaluated and deliberately removed.
- [ ] Real captive-portal guest network validated.
- [ ] Tailscale on travel MacBook validated through `Astra-Travel`.

## Change-control rule

Once the router is in a known-good travel state, avoid unnecessary package or network changes immediately before a trip. Any material change to wireless, firewall, DHCP, Travelmate or OpenWrt should be followed by the relevant acceptance tests and documented before it becomes the new known-good state.
