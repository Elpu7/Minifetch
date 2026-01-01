#!/usr/bin/env bash

# ===== minifetch =====
# kevyt neofetch-kopio bashilla

# Värit
RESET="\e[0m"
BOLD="\e[1m"
CYAN="\e[36m"
GREEN="\e[32m"
YELLOW="\e[33m"

# OS
OS="$(grep '^PRETTY_NAME=' /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"')"
[ -z "$OS" ] && OS="$(uname -s)"

# Kernel
KERNEL="$(uname -r)"

# Uptime
UPTIME="$(uptime -p | sed 's/up //')"

# Shell
SHELL_NAME="$(basename "$SHELL")"

# User@Host
USER_HOST="$(whoami)@$(hostname)"

# CPU
CPU="$(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | sed 's/^ //')"

# RAM
MEM_USED=$(free -m | awk '/Mem:/ {print $3}')
MEM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
MEM="${MEM_USED}MB / ${MEM_TOTAL}MB"

# ASCII-logo (Linux)
read -r -d '' LOGO << "EOF"
      _______
     |  _____|
     | |_____
     |_____  |
      _____| |
     |_______|
EOF

# Tulostus
echo -e "${CYAN}${LOGO}${RESET}  ${BOLD}${USER_HOST}${RESET}"
echo -e "${CYAN}OS:${RESET}      $OS"
echo -e "${CYAN}Kernel:${RESET}  $KERNEL"
echo -e "${CYAN}Uptime:${RESET}  $UPTIME"
echo -e "${CYAN}Shell:${RESET}   $SHELL_NAME"
echo -e "${CYAN}CPU:${RESET}     $CPU"
echo -e "${CYAN}Memory:${RESET}  $MEM"
