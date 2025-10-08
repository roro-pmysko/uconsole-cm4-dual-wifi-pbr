# uConsole CM4 Dual Wi‑Fi: Surf + Pentest ⚡📶

Use the internal CM4 Wi‑Fi together with a USB Wi‑Fi adapter (e.g., Panda Wireless PAU0B AC600) to connect the Clockwork uConsole to two different networks at once. Route normal traffic over one network while dedicating the other to tools like angryoxide and hashcat. ✨

- Raspberry Pi OS Bookworm uses NetworkManager (recommended)
- Notes for older dhcpcd/wpa_supplicant setups
- Policy‑Based Routing (PBR) example included
- Tips: ZRAM (Pi‑Apps) and overclocking

## Requirements ✅
- Clockwork uConsole Kit RPI‑CM4 Lite
- Compatible USB Wi‑Fi (Panda PAU0B AC600 or similar)
- Raspberry Pi OS (Bookworm preferred)
- Two Wi‑Fi networks (SSIDs + passwords)
- Basic Linux networking familiarity

## Quick Start (Bookworm/NetworkManager) 🚀
Connect each interface to a different network:
```bash
# wlan0 → SSID_1 (primary internet)
nmcli device wifi connect "SSID_1" password "PASS_1" ifname wlan0
# wlan1 → SSID_2 (pentest)
nmcli device wifi connect "SSID_2" password "PASS_2" ifname wlan1
```
Prefer wlan0 for default internet, keep wlan1 for targeted tasks:
```bash
nmcli con mod "SSID_1" ipv4.route-metric 100 connection.autoconnect-priority 10
nmcli con mod "SSID_2" ipv4.never-default yes connection.autoconnect-priority 5
nmcli con up "SSID_1" && nmcli con up "SSID_2"
```
Verify:
```bash
ip -4 addr show wlan0; ip -4 addr show wlan1
ip route show
```

## Older OS (dhcpcd + wpa_supplicant) 🛠
Prevent a second default route on wlan1:
```
/etc/dhcpcd.conf:
interface wlan1
  nogateway
  metric 200
# Keep wlan0 with a lower metric (e.g., 100)
```
Use per‑interface wpa_supplicant configs; see USER_GUIDE.md for details.

## Policy‑Based Routing (PBR) 🎯
Send traffic sourced from wlan1 over wlan1’s gateway, while everything else uses wlan0. Use pbr-setup.sh and the optional systemd unit in this repo. See USER_GUIDE.md.

## Performance Tips 💡
- ZRAM (Pi‑Apps) can improve responsiveness under load.
- Overclocking can help CPU‑heavy tools: https://github.com/roro-pmysko/uconsole-cm4-overclock

## Disclaimer ⚠️
Use at your own risk. Only test networks you’re authorized to assess. Behavior varies by OS, drivers, and hardware.