<div align="center">

# 📶 Hostel WiFi Auto-Login

**Join the hostel Wi-Fi. Get online. That's it.**

Signs you in to the VIT hostel Wi-Fi captive portal (**any block**: Q-VIT, G-VIT, VIT-Hostel and friends) the moment you connect, so you never open a browser and type your password again.

![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D4?logo=windows&logoColor=white)
![Setup](https://img.shields.io/badge/setup-1%20double--click-brightgreen)
![License](https://img.shields.io/badge/License-MIT-green)
![Dependencies](https://img.shields.io/badge/installs-nothing%20extra-brightgreen)

</div>

---

## 🚀 Set it up in 1 minute

No coding. No commands. Just three steps.

### 1. Download

Click the green **`<> Code`** button at the top of this page, then **Download ZIP**.

### 2. Extract

Find the ZIP in your Downloads folder, **right-click it → Extract All → Extract**.

> ⚠️ **Don't skip this.** Opening `Install.bat` from *inside* the ZIP won't work. Extract first.

### 3. Double-click `Install.bat`

A black window opens and walks you through it:

1. Type the **username and password** you normally use on the hostel Wi-Fi login page, then press Enter after each one. *(Your password shows as `****` while you type. That's normal.)*
2. Wait for **"All done!"**

That's it. From now on, whenever you connect to the hostel Wi-Fi or start your laptop, you're signed in automatically.

<details>
<summary><b>Windows says "Windows protected your PC"?</b></summary>

This appears for any script you download from the internet. Click **More info → Run anyway**. The whole script is a few short, readable files in this repo, so you can check exactly what it does first.

</details>

## 🛠 Managing it

Open the **Start menu** and search for **Hostel WiFi Auto-Login**. You'll find:

| Shortcut | What it does |
| --- | --- |
| **Check status** | Shows if it's installed, which network you're on, whether the internet works, and what it did recently |
| **Change password** | Use this after you change your Wi-Fi password |
| **Uninstall** | Turns it off and deletes your saved login from this PC |

You can delete the downloaded folder after installing. Everything it needs has been copied to a safe place.

## ✨ Why you'll like it

- **Zero clicks.** Runs on every Wi-Fi connect and every Windows sign-in.
- **Works in every block.** All VIT networks share one portal and one login, so one script covers them. It acts on any network with "VIT" in its name and ignores everything else (home, cafe, phone hotspot).
- **Checks first.** If you already have internet, it does nothing.
- **Retries.** Six attempts, five seconds apart, in case the portal is slow to wake up.
- **Your password stays yours.** It's encrypted with Windows' own protection and can only be read by your Windows account on your PC. It never leaves your laptop.
- **Nothing extra to install.** Uses only what's already in Windows.

## ❓ Troubleshooting

| What you see | What to do |
| --- | --- |
| Not signing in at all | Open **Check status**. It tells you what's wrong. |
| "portal did not grant access" in the log | Wrong username or password. Use **Change password**. |
| "could not resolve phc.prontonetworks.com" | The Wi-Fi portal wasn't ready yet. Disconnect and reconnect. |
| "403 Forbidden" | You're probably already logged in on another device. Log that one out. |
| You changed your Wi-Fi password | Use **Change password**. |
| Want to start over | Run **Uninstall**, then double-click `Install.bat` again. |

Still stuck? [Open an issue](../../issues) and paste what **Check status** shows. Never paste your password.

## 🧠 How it works

```
Wi-Fi connects  ──┐
                  ├──▶  wifi_login.ps1
You sign in to ───┘          │
Windows                      ▼
                  VIT network? ─no─▶ stop
                             │ yes
                             ▼
                  Already online? ─yes─▶ stop
                             │ no
                             ▼
        Send your saved login to the Pronto portal (up to 6 tries)
                             │
                             ▼
                  "Logged in." → written to log.txt
```

`Install.bat` copies the scripts to `%LOCALAPPDATA%\HostelWifiAutoLogin`, saves your login there, and creates a Windows Scheduled Task that runs `wifi_login.ps1` at logon and whenever the WLAN service reports a new connection.

<details>
<summary><b>What's in the repo</b></summary>

| File | Purpose |
| --- | --- |
| `Install.bat` | The only thing you need to double-click |
| `scripts/install.ps1` | Does the install: copies files, saves login, creates the task |
| `scripts/wifi_login.ps1` | The auto-login logic |
| `scripts/setup.ps1` | Asks for your login and encrypts it into `cred.xml` |
| `scripts/status.ps1` | Powers **Check status** |
| `scripts/uninstall.ps1` | Powers **Uninstall** |
| `scripts/*.bat` | Start-menu launchers for the scripts above |

`cred.xml` and `log.txt` are created on your PC only and are git-ignored.

</details>

## 🔒 Security notes

- Your login is encrypted with the Windows Data Protection API. It can't be read on another PC or by another Windows user.
- The hostel portal only offers plain HTTP, so only use this on the hostel network.
- Never share or upload `cred.xml`.

## 🗺 Roadmap

- [ ] A tray app with a status light and a "log in now" button
- [ ] Multi-campus support (other campuses may use different portals)
- [ ] Linux and macOS versions

## 🤝 Contributing

Issues and pull requests are welcome. If your hostel uses a different portal, open an issue with the login URL and form field names.

Want a full app with a GUI and Android support? Check out [Latch by VinnovateIT](https://github.com/vinnovateit/latch). This project is the tiny, no-frills alternative.

## 📄 License

[MIT](LICENSE) © Siddharth D
