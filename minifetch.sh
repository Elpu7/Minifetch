#!/usr/bin/env bash

# ===== minifetch =====

RESET="\e[0m"
BOLD="\e[1m"
CYAN="\e[36m"

# Helper
cmd() { command -v "$1" >/dev/null 2>&1; }

# OS
OS="$(grep '^PRETTY_NAME=' /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"')"
[ -z "$OS" ] && OS="$(uname -s)"

# Host
HOST="$(hostname)"

# Kernel
KERNEL="$(uname -r)"

# Uptime
UPTIME="$(uptime -p 2>/dev/null | sed 's/up //')"

# Packages
PACKAGES="N/A"
if cmd pacman; then
  PACKAGES="$(pacman -Qq | wc -l) (pacman)"
elif cmd dpkg; then
  PACKAGES="$(dpkg -l | grep '^ii' | wc -l) (dpkg)"
elif cmd rpm; then
  PACKAGES="$(rpm -qa | wc -l) (rpm)"
fi

# Shell
SHELL_NAME="$(basename "$SHELL")"

# Displays
DISPLAYS="N/A"
if cmd xrandr; then
  DISPLAYS="$(xrandr --listmonitors 2>/dev/null | awk 'NR>1 {print $4}' | tr '\n' ' ')"
fi

# DE / WM
DE="${XDG_CURRENT_DESKTOP:-N/A}"
WM="N/A"
if cmd wmctrl; then
  WM="$(wmctrl -m 2>/dev/null | awk -F: '/Name/ {print $2}' | sed 's/^ //')"
fi

# WM Theme / Theme / Icons / Font / Cursor
THEME="${GTK_THEME:-N/A}"
ICONS="${ICON_THEME:-N/A}"
FONT="${GTK_FONT_NAME:-N/A}"
CURSOR="${XCURSOR_THEME:-N/A}"
WM_THEME="N/A"

# Terminal
TERMINAL="${TERM_PROGRAM:-$TERM}"

# CPU
CPU="$(grep -m1 'model name' /proc/cpuinfo 2>/dev/null | cut -d: -f2 | sed 's/^ //')"

# GPU
GPU="N/A"
if cmd lspci; then
  GPU="$(lspci | grep -Ei 'vga|3d|display' | head -n1 | cut -d: -f3 | sed 's/^ //')"
fi

# Memory
MEM_USED=$(free -m | awk '/Mem:/ {print $3}')
MEM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
MEMORY="${MEM_USED}MB / ${MEM_TOTAL}MB"

# Swap
SWAP_USED=$(free -m | awk '/Swap:/ {print $3}')
SWAP_TOTAL=$(free -m | awk '/Swap:/ {print $2}')
SWAP="${SWAP_USED}MB / ${SWAP_TOTAL}MB"

# Disks
DISKS="$(df -h --total | awk '/total/ {print $3 " / " $2}')"

# Local IP
LOCAL_IP="$(ip route get 1.1.1.1 2>/dev/null | awk '{print $7}')"
[ -z "$LOCAL_IP" ] && LOCAL_IP="N/A"

# Locale
LOCALE="${LANG:-N/A}"

# ASCII logo
read -r -d '' LOGO << "EOF"
   __  ___      _ ____      __
  /  |/  /___ _(_) __/__ __/ /_
 / /|_/ / __ `/ / /_/ / // / __/
/_/  /_/\_,_/_/_/___/\_,_/\__/
EOF

# Output
echo -e "${CYAN}${LOGO}${RESET}"
echo -e "${BOLD}OS:${RESET}          $OS"
echo -e "${BOLD}Host:${RESET}        $HOST"
echo -e "${BOLD}Kernel:${RESET}      $KERNEL"
echo -e "${BOLD}Uptime:${RESET}      $UPTIME"
echo -e "${BOLD}Packages:${RESET}    $PACKAGES"
echo -e "${BOLD}Shell:${RESET}       $SHELL_NAME"
echo -e "${BOLD}Displays:${RESET}    $DISPLAYS"
echo -e "${BOLD}DE:${RESET}          $DE"
echo -e "${BOLD}WM:${RESET}          $WM"
echo -e "${BOLD}WM Theme:${RESET}    $WM_THEME"
echo -e "${BOLD}Theme:${RESET}       $THEME"
echo -e "${BOLD}Icons:${RESET}       $ICONS"
echo -e "${BOLD}Font:${RESET}        $FONT"
echo -e "${BOLD}Cursor:${RESET}      $CURSOR"
echo -e "${BOLD}Terminal:${RESET}    $TERMINAL"
echo -e "${BOLD}CPU:${RESET}         $CPU"
echo -e "${BOLD}GPU:${RESET}         $GPU"
echo -e "${BOLD}Memory:${RESET}      $MEMORY"
echo -e "${BOLD}Swap:${RESET}        $SWAP"
echo -e "${BOLD}Disks:${RESET}       $DISKS"
echo -e "${BOLD}Local IP:${RESET}    $LOCAL_IP"
echo -e "${BOLD}Locale:${RESET}      $LOCALE"
