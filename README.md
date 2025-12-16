# H0RUS System Maintenance PRO v3.0

![Bash](https://img.shields.io/badge/Language-Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-Arch%20%7C%20Debian%20%7C%20RHEL-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)

**H0RUS Maintenance PRO** is an advanced, automated system maintenance and optimization suite for Linux. Think of it as "BleachBit + System Updates + Snapper Snapshots" on steroids, all scriptable and with mobile notifications.

> **v3.0 Update**: Now supporting **Arch Linux, Debian/Ubuntu, and Fedora/RHEL** families automatically!

## 🚀 Key Features

-   **🛡️ Safety First (Snapper Integration)**: Automatically creates filesystem snapshots before any major operation (update/clean). *Never break your system again without a way back.*
-   **🧹 "BleachBit-Style" Deep Cleaning**:
    -   Vacuums Firefox/Chrome/Brave/Edge SQLite databases for speed.
    -   Cleans Systemd Journals, Thumbnails, and Cache.
    -   Intelligent package cache cleaning (keeps only safe fallback versions).
-   **🤖 Multi-Distro Support**: One script to rule them all. Auto-detects `pacman`, `apt`, or `dnf`.
-   **📱 Telegram Notifications**: Get real-time reports on your phone when maintenance completes (success or failure).
-   **⚡ 1-Click Optimization**: Tunes kernel parameters (Swappiness, VFS Cache), enables BBR congestion control, and runs TRIM on SSDs.
-   **⏲️ Set & Forget**: Built-in scheduler (Systemd Timer) to run weekly maintenance silently in the background.

## 📦 Installation

```bash
# Clone the repository
git clone https://github.com/your-username/Update-System-Arch.git
cd Update-System-Arch

# Make executable
chmod +x maintenance.sh

# Run
./maintenance.sh
```

## 🛠️ Configuration & Usage

### Interactive Menu
Simply run `./maintenance.sh` to access the main menu:

1.  **Optimización 1-Click**: Runs a safe subset of optimizations and updates.
2.  **Limpieza Profunda**: The aggressive cleaning mode (databases, logs).
3.  **Actualizar Sistema**: Wrapper for your distro's update manager (with snapshot).
4.  **Auditoría de Seguridad**: Checks firewall status and failed SSH logins.
5.  **Gestionar Snapshots**: wrapper for Snapper operations.
6.  **Programación Auto**: Installs the Systemd Timer.
7.  **Notificaciones**: Setup wizard for Telegram.

### 2. Setting up Telegram Notifications
Select **Option 7** in the menu. You will need:
1.  **Bot Token**: Create a bot with [@BotFather](https://t.me/BotFather).
2.  **Chat ID**: Get your ID from [@userinfobot](https://t.me/userinfobot).

The script will save these securely in `~/.config/h0rus/config.conf`.

### 3. Setting up Snapper (Optional but Recommended)
For the snapshot feature to work, ensure `snapper` is installed and a config exists for root:
```bash
# Arch/Fedora/Debian
sudo apt install snapper # or pacman -S snapper / dnf install snapper

# Create config for root
sudo snapper -c root create-config /
```

## 🤖 Automated Mode (Cron/Timer)
The script is designed to run non-interactively via flags:

```bash
sudo ./maintenance.sh --auto
```
This is what the built-in scheduler (`Option 6`) uses to run weekly.

## ⚠️ Disclaimer
While this script includes safety mechanisms (Safety Mode, Snapper Snapshots), **Deep Cleaning** involves deleting files. Always ensure you have backups. Use at your own risk.

## 📝 License
MIT License. Feel free to modify and distribute.
