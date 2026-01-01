#!/usr/bin/env bash

VERSION="1.1.0"
INSTALL_PATH="/usr/local/bin/minifetch"
REPO_RAW_BASE="https://raw.githubusercontent.com/USERNAME/minifetch/main"

RESET="\e[0m"
BOLD="\e[1m"
CYAN="\e[36m"

cmd() { command -v "$1" >/dev/null 2>&1; }

# ===== subcommands =====
case "$1" in
  update)
    echo "Updating minifetch..."
    if [ "$EUID" -ne 0 ]; then
      echo "Run with sudo."
      exit 1
    fi
    curl -fsSL "$REPO_RAW_BASE/minifetch.sh" -o "$INSTALL_PATH"
    chmod +x "$INSTALL_PATH"
    echo "minifetch updated."
    exit 0
    ;;
  remove|uninstall)
    echo "Removing minifetch..."
    if [ "$EUID" -ne 0 ]; then
      echo "Run with sudo."
      exit 1
    fi
    rm -f "$INSTALL_PATH"
    echo "minifetch removed."
    exit 0
    ;;
  --version|-v)
    echo "minifetch $VERSION"
    exit 0
    ;;
esac

# ===== system info =====

OS="$(grep '^PRETTY_NAME=' /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"')"
[ -z "$OS" ] && OS="$(uname -s)"

HOST="$(hostname)"
KERNEL="$(uname -r)"
UPTIME="$(uptime -p 2>/dev/null | sed 's/up //')"

PACKAGES="N/A"
if cmd pacman; then
  PACKAGES="$(pacman -Qq | wc -l) (pacman)"
elif cmd dpkg; then
  PACKAGES="$(dpkg -l | grep '^ii' | wc -l) (dpkg)"
elif cmd rpm; then
  PACKAGES="$(rpm -qa | wc -l) (rpm)"
fi

SHELL_NAME="$(basename "$SHELL")"

DISPLAYS="N/A"
cmd xrandr && DISPLAYS="$(xrandr --listmonitors 2>/dev/null | awk 'NR>1 {print $4}' | tr '\n' ' ')"

DE="${XDG_CURRENT_DESKTOP:-N/A}"

WM="N/A"
cmd wmctrl && WM="$(wmctrl -m 2>/dev/null | awk -F: '/Name/ {print $2}' | sed 's/^ //')"

WM_THEME="N/A"
THEME="${GTK_THEME:-N/A}"
ICONS="${ICON_THEME:-N/A}"
FONT="${GTK_FONT_NAME:-N/A}"
CURSOR="${XCURSOR_THEME:-N/A}"
TERMINAL="${TERM_PROGRAM:-$TERM}"

CPU="$(grep -m1 'model name' /proc/cpuinfo 2>/dev/null | cut -d: -f2 | sed 's/^ //')"

GPU="N/A"
cmd lspci && GPU="$(lspci | grep -Ei 'vga|3d|display' | head -n1 | cut -d: -f3 | sed 's/^ //')"

MEMORY="$(free -m | awk '/Mem:/ {print $3 "MB / " $2 "MB"}')"
SWAP="$(free -m | awk '/Swap:/ {print $3 "MB / " $2 "MB"}')"

DISKS="$(df -h --total | awk '/total/ {print $3 " / " $2}')"

LOCAL_IP="$(ip route get 1.1.1.1 2>/dev/null | awk '{print $7}')"
[ -z "$LOCAL_IP" ] && LOCAL_IP="N/A"

LOCALE="${LANG:-N/A}"

# ===== ASCII logo =====
read -r -d '' LOGO << "EOF"
   __  ___      _ ____      __
  /  |/  /___ _(_) __/__ __/ /_
 / /|_/ / __ `/ / /_/ / // / __/
/_/  /_/\_,_/_/_/___/\_,_/\__/
EOF

# ===== output =====
echo -e "${CYAN}${LOGO}${RESET}"
printf "${BOLD}%-12s${RESET} %s\n" OS "$OS"
printf "${BOLD}%-12s${RESET} %s\n" Host "$HOST"
printf "${BOLD}%-12s${RESET} %s\n" Kernel "$KERNEL"
printf "${BOLD}%-12s${RESET} %s\n" Uptime "$UPTIME"
printf "${BOLD}%-12s${RESET} %s\n" Packages "$PACKAGES"
printf "${BOLD}%-12s${RESET} %s\n" Shell "$SHELL_NAME"
printf "${BOLD}%-12s${RESET} %s\n" Displays "$DISPLAYS"
printf "${BOLD}%-12s${RESET} %s\n" DE "$DE"
printf "${BOLD}%-12s${RESET} %s\n" WM "$WM"
printf "${BOLD}%-12s${RESET} %s\n" "WM Theme" "$WM_THEME"
printf "${BOLD}%-12s${RESET} %s\n" Theme "$THEME"
printf "${BOLD}%-12s${RESET} %s\n" Icons "$ICONS"
printf "${BOLD}%-12s${RESET} %s\n" Font "$FONT"
printf "${BOLD}%-12s${RESET} %s\n" Cursor "$CURSOR"
printf "${BOLD}%-12s${RESET} %s\n" Terminal "$TERMINAL"
printf "${BOLD}%-12s${RESET} %s\n" CPU "$CPU"
printf "${BOLD}%-12s${RESET} %s\n" GPU "$GPU"
printf "${BOLD}%-12s${RESET} %s\n" Memory "$MEMORY"
printf "${BOLD}%-12s${RESET} %s\n" Swap "$SWAP"
printf "${BOLD}%-12s${RESET} %s\n" Disks "$DISKS"
printf "${BOLD}%-12s${RESET} %s\n" "Local IP" "$LOCAL_IP"
printf "${BOLD}%-12s${RESET} %s\n" Locale "$LOCALE"
