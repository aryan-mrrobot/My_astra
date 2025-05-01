<h1 align="center">🧨 My Astra Arsenal 🧨</h1>

<p align="center">
  <img src="https://img.shields.io/badge/status-active-success?style=flat-square&logo=hack-the-box&logoColor=white&color=green" />
  <img src="https://img.shields.io/badge/tools-penetration%20testing-blueviolet?style=flat-square&logo=kalilinux&logoColor=white" />
  <img src="https://img.shields.io/badge/built%20for-bugbounty-red?style=flat-square&logo=bugcrowd" />
</p>

---

## ⚔️ What is *My Astra*?

**My Astra** is a personal arsenal of powerful recon and exploitation tools — built by a hacker, for hackers.  
It’s designed to automate, customize, and streamline your bug bounty and recon workflow with zero clutter.

---

## 📦 Structure Overview

My_wepons/ ├── THEX/ # Ultimate toolset with recon & attack scripts │ ├── Archive.zip │ ├── wordlists/ │ │ ├── extensoon_part_000.txt │ │ └── xml.txt │ └── templates-particular 5.zip │ ├── wepon-main/ # Companion tools and wordlists │ └── wordlist.zip │ ├── Basic tools/ # Lightweight utilities ├── trikuta/ # Custom shell scripts ├── fuzz.txt ├── THEX.v1.zip ├── Archive.zip


---


---

## 🛠️ Setup Instructions

### 🔑 1. Configure API Keys

Update API keys before using tools like:

- **[subfinder](https://github.com/projectdiscovery/subfinder)**  
  → Edit `~/.config/subfinder/provider-config.yaml`  
- **[waymore](https://github.com/xnl-h4ck3r/waymore)**  
  → Insert your Shodan, Censys, etc., keys in `config.json` or headers.

---

### ⚙️ 2. Python Compatibility

Some older tools (like `xss_scraper`) are written in **Python 2**.

> ⚠️ You must use a Python 2 virtual environment for them:
```bash
sudo apt install python2
python2 -m pip install -r requirements.txt
```
🧾 Recent Updates
🔥 extensoon.txt was split into 2 parts to avoid oversized files:

extensoon_part_000.txt

extensoon_part_001.txt (coming soon)

🔄 Outdated tools and files over 100MB were removed.

🔑 API key setup instructions for major tools were added.

⚠️ Git LFS is used for handling large files automatically.

💀 Hacker Vibe Activated
“Hacking isn’t just code, it’s a mindset.”

Fork it. Break it. Improve it.
This repo isn't just a toolkit — it's a digital blade forged for your recon missions.

📬 Connect
GitHub: @aryan-mrrobot

Issues & Contributions: Always welcome

<p align="center"> <b>Stay Curious. Think Different. Hack Everything.</b> </p> ```
