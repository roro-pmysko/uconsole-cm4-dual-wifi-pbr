# User Guide: Dual Wi‑Fi on uConsole CM4 ✨

Use internal CM4 Wi‑Fi plus a USB Wi‑Fi adapter to connect to two networks simultaneously—one for general internet, the other for pentesting tools (angryoxide, hashcat). 🧰

> Warning ⚠️  
> Use at your own risk. Only run security tools on networks you’re authorized to test.

---

## 1) Identify Interfaces
```bash
ip a
```
Typically:
- wlan0 = internal (CM4)
- wlan1 = USB (Panda PAU0B AC600, etc.)

---

## 2) Bookworm/NetworkManager (Recommended)

Option A — nmcli (CLI)
```bash
# Connect networks
nmcli device wifi connect "SSID_1" password "PASS_1" ifname wlan0
nmcli device wifi connect "SSID_2" password "PASS_2" ifname wlan1

# Prefer wlan0 for default route; keep wlan1 no-default
nmcli con mod "SSID_1" ipv4.route-metric 100 connection.autoconnect-priority 10
nmcli con mod "SSID_2" ipv4.never-default yes connection.autoconnect-priority 5

# Apply
nmcli con up "SSID_1"
nmcli con up "SSID_2"
```

Option B — nmtui (TUI)
```bash
sudo nmtui
# Activate a connection → choose wlan0 and wlan1 → select networks and enter passwords
```

Verify
```bash
ip -4 addr show wlan0
ip -4 addr show wlan1
ip route show
```
You should see a single default route via wlan0.

---

## 3) Older OS (wpa_supplicant + dhcpcd)

Per‑interface wpa_supplicant:
```bash
sudo nano /etc/wpa_supplicant/wpa_supplicant-wlan0.conf   # Network A
sudo nano /etc/wpa_supplicant/wpa_supplicant-wlan1.conf   # Network B
```

Prevent default gateway on wlan1:
```
/etc/dhcpcd.conf:
interface wlan1
  nogateway
  metric 200
# wlan0 keeps default route (lower metric, e.g., 100)
```

Apply:
```bash
sudo systemctl restart dhcpcd
```

---

## 4) Policy‑Based Routing (PBR) 🎯

Goal: Traffic sourced from wlan1 uses wlan1’s gateway; everything else uses wlan0.

Optional table name:
```
/etc/iproute2/rt_tables:
100 wlan1
```

Install the helper script:
```bash
sudo install -m 0755 pbr-setup.sh /usr/local/sbin/pbr-setup.sh
```

Run once after both links are up:
```bash
sudo /usr/local/sbin/pbr-setup.sh
```

Make persistent with systemd:
```bash
sudo cp pbr-setup.service /etc/systemd/system/pbr-setup.service
sudo systemctl daemon-reload
sudo systemctl enable --now pbr-setup.service
```

Inspect rules/routes:
```bash
ip rule show
ip route show table 100
```

Notes
- If IPs change on boot, the oneshot service re-applies rules.
- For more granular splits (destinations or apps), use fwmark with nftables/iptables and ip rule fwmark.

---

## 5) Tips, Tools, and Tuning 🧪
- USB adapter with good drivers improves stability.
- ZRAM (Pi‑Apps) helps under memory pressure.
- Overclock for CPU‑bound work: https://github.com/roro-pmysko/uconsole-cm4-overclock

---

## 6) Troubleshooting 🔎
```bash
nmcli dev status
nmcli con show
journalctl -u NetworkManager --no-pager -g wlan
ip a; ip route; ip rule
dmesg | tail -n 100
```
- If wlan1 grabs default route, set ipv4.never-default yes on that connection.
- If routes “fight,” set explicit metrics (wlan0 100, wlan1 200).
- On dhcpcd, confirm nogateway/metric in /etc/dhcpcd.conf.

---

## Disclaimer ⚠️
Provided “as is,” without warranty. You are responsible for device safety, legality, and data. Monitor behavior after changes.