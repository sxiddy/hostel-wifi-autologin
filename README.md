<div align="center">

# 📶 Hostel WiFi Auto-Login

**Join the hostel Wi-Fi. Get online. That's it.**

A tiny PowerShell script that signs you in to the VIT hostel Wi-Fi captive portal (**any block**: Q-VIT, G-VIT, VIT-Hostel and friends) the moment you connect, so you never open a browser and type your password again.

![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D4?logo=windows&logoColor=white)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-5391FE?logo=powershell&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green)
![Dependencies](https://img.shields.io/badge/dependencies-none-brightgreen)

</div>

---

## ✨ Why

Every time your laptop wakes up, roams, or reconnects, the hostel network drops you at a login page. This script does the typing for you, silently, in the background.

- **Zero clicks.** Runs on every Wi-Fi connect and at logon.
- **Works in every block.** All VIT networks share one portal and one login, so one script covers them. It acts on any network with "VIT" in its name and exits immediately on anything else (home, cafe, phone hotspot).
- **Checks first.** If you already have internet it does nothing.
- **Retries.** Six attempts, five seconds apart, in case the portal is slow to wake.
- **Your password stays yours.** Stored encrypted with Windows DPAPI, readable only by your Windows account on your PC.
- **No installs, no dependencies.** Just PowerShell, which ships with Windows.

## 🚀 Install (1 minute)

1. **Download** this repo (`Code → Download ZIP`) and extract it somewhere permanent, for example `C:\Users\<you>\WifiAutoLogin`.
2. Open **PowerShell** in that folder and run:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\install.ps1
   ```

3. Enter your hostel Wi-Fi username and password when prompted. They are saved encrypted to `cred.xml` next to the script.

Done. Connect to your hostel network and you're online.

> Don't move or delete the folder afterwards, because the scheduled task points to it.

## 🧠 How it works

```
Wi-Fi connects (event 8001)  ──┐
                               ├──▶  wifi_login.ps1
You log in to Windows ─────────┘          │
                                          ▼
                         VIT network? ─no─▶ exit
                                          │ yes
                                          ▼
                       Already online?  ──yes──▶ exit
                                          │ no
                                          ▼
              POST credentials to the Pronto portal  (up to 6 tries)
                                          │
                                          ▼
                              "Logged in." → log.txt
```

1. A Windows **Scheduled Task** fires at logon and whenever the WLAN service reports a new connection.
2. The script reads the current SSID with `netsh` and exits unless its name contains `VIT`.
3. It requests Microsoft's connectivity-test URL. If the expected text comes back, you're already online.
4. Otherwise it posts your saved credentials to the portal's login endpoint and checks for `Access Granted`.
5. Every outcome is appended to `log.txt`.

## 📁 What's inside

| File | Purpose |
| --- | --- |
| `wifi_login.ps1` | The auto-login logic |
| `setup.ps1` | Prompts for and encrypts your credentials into `cred.xml` |
| `install.ps1` | Registers the scheduled task (runs `setup.ps1` first if needed) |
| `cred.xml` | *Created on your PC, git-ignored.* Your encrypted login |
| `log.txt` | *Created on your PC, git-ignored.* What the script did and when |

## 🔧 Handy commands

```powershell
# See what happened recently
Get-Content .\log.txt -Tail 20

# Run it manually
powershell -ExecutionPolicy Bypass -File .\wifi_login.ps1

# Change your password
powershell -ExecutionPolicy Bypass -File .\setup.ps1

# Uninstall
Unregister-ScheduledTask -TaskName "Hostel WiFi Auto Login" -Confirm:$false
```

## 🛠 Troubleshooting

| Symptom | Likely cause |
| --- | --- |
| `No saved login. Run setup.ps1 first.` | `cred.xml` is missing. Run `setup.ps1`. |
| `could not resolve phc.prontonetworks.com` | The portal wasn't reachable yet (common right after connecting). Reconnect and it retries. |
| `403 Forbidden` | The portal rejected the request, usually because you're already logged in elsewhere. |
| `portal did not grant access` | Wrong username or password. Re-run `setup.ps1`. |
| Nothing happens | Check the task exists: `Get-ScheduledTask "Hostel WiFi Auto Login"`. |

## 🔒 Security notes

- Credentials are encrypted with the Windows Data Protection API. They can't be read on another PC or by another Windows user.
- The portal login uses plain HTTP, because that's what the hostel portal offers. Only use this on the hostel network.
- Never commit `cred.xml`. It is in `.gitignore`.

## 🗺 Roadmap

- [ ] A small tray app with a status light and a one-click "log in now"
- [ ] Multi-campus support (other campuses may use different portals)
- [ ] Cross-platform version for Linux and macOS

## 🤝 Contributing

Issues and pull requests are welcome. If your hostel uses a different portal, open an issue with the login URL and form field names.

Looking for a full-featured app with a GUI and Android support? Check out [Latch by VinnovateIT](https://github.com/vinnovateit/latch). This project is the minimal, no-install alternative.

## 📄 License

[MIT](LICENSE) © Siddharth D
