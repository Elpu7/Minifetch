#!/usr/bin/env bash

VERSION="1.2.0"
INSTALL_PATH="/usr/local/bin/minifetch"
REPO_RAW_BASE="https://raw.githubusercontent.com/Elpu7/minifetch/main"

# ===== colors =====
RESET="\e[0m"
BOLD="\e[1m"
DIM="\e[2m"
CYAN="\e[36m"
BLUE="\e[34m"
GREEN="\e[32m"
MAGENTA="\e[35m"

cmd() { command -v "$1" >/dev/null 2>&1; }

# ===== help =====
if [[ "$1" == "help" || "$1" == "--help" || "$1" == "-h" ]]; then
  echo -e "${BOLD}minifetch${RESET} ${DIM}v$VERSION${RESET}"
  echo
  echo -e "${BOLD}Usage:${RESET}"
  echo "  minifetch            Show system info"
  echo "  minifetch update     Update minifetch"
  echo "  minifetch remove     Uninstall minifetch"
  echo "  minifetch help       Show this help"
  exit 0
fi

# ===== update / remove =====
case "$1" in
  update)
    [ "$EUID" -ne 0 ] && { echo "Run with sudo."; exit 1; }
    curl -fsSL "$REPO_RAW_BASE/minifetch.sh" -o "$INSTALL_PATH"
    chmod +x "$INSTALL_PATH"
    echo "minifetch updated."
    exit 0
    ;;
  remove|uninstall)
    [ "$EUID" -ne 0 ] && { echo "Run with sudo."; exit 1; }
    rm -f "$INSTALL_PATH"
    echo "minifetch removed."
    exit 0
    ;;
esac

# ===== system info =====
OS_NAME="$(. /etc/os-release 2>/dev/null && echo "$NAME")"
OS_PRETTY="$(. /etc/os-release 2>/dev/null && echo "$PRETTY_NAME")"
HOST="$(hostname)"
KERNEL="$(uname -r)"
UPTIME="$(uptime -p | sed 's/up //')"
SHELL_NAME="$(basename "$SHELL")"
LOCALE="${LANG:-N/A}"

PACKAGES="N/A"
cmd pacman && PACKAGES="$(pacman -Qq | wc -l) (pacman)"
cmd dpkg && PACKAGES="$(dpkg -l | grep '^ii' | wc -l) (dpkg)"

CPU="$(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | sed 's/^ //')"

GPU="N/A"
cmd lspci && GPU="$(lspci | grep -Ei 'vga|3d|display' | head -n1 | cut -d: -f3)"

MEM="$(free -m | awk '/Mem:/ {print $3 "MB / " $2 "MB"}')"
SWAP="$(free -m | awk '/Swap:/ {print $3 "MB / " $2 "MB"}')"
DISK="$(df -h --total | awk '/total/ {print $3 " / " $2}')"
LOCAL_IP="$(ip route get 1.1.1.1 2>/dev/null | awk '{print $7}')"

DE="${XDG_CURRENT_DESKTOP:-N/A}"
WM="N/A"; cmd wmctrl && WM="$(wmctrl -m | awk -F: '/Name/ {print $2}')"
THEME="${GTK_THEME:-N/A}"
ICONS="${ICON_THEME:-N/A}"
FONT="${GTK_FONT_NAME:-N/A}"
CURSOR="${XCURSOR_THEME:-N/A}"
TERM_NAME="${TERM_PROGRAM:-$TERM}"

# ===== distro logos =====
case "$OS_NAME" in
  Arch*)
read -r -d '' LOGO << "EOF"
      /\ 
     /  \ 
    /\   \ 
   /      \ 
EOF
;;
  Ubuntu*)
read -r -d '' LOGO << "EOF"
   _______
  /  ___  \
 |  |   | |
  \_______/
EOF
;;
  Fedora*)
read -r -d '' LOGO << "EOF"
   _____
  |  ___|
  | |_  
  |  _| 
EOF
;;
  Debian*)
read -r -d '' LOGO << "EOF"
    ____ 
   / __ \
  | |  | |
   \____/
EOF
;;
  *)
read -r -d '' LOGO << "EOF"
   _____
  |  ___|
  | |___
  |_____|
EOF
;;
esac

# ===== output helper =====
print_line() {
  printf "${GREEN}%-13s${RESET} %s\n" "$1" "$2"
}

# ===== render =====
IFS=$'\n' read -d '' -r -a LOGO_LINES <<< "$LOGO"
INFO_LINES=(
  "OS|$OS_PRETTY"
  "Host|$HOST"
  "Kernel|$KERNEL"
  "Uptime|$UPTIME"
  "Packages|$PACKAGES"
  "Shell|$SHELL_NAME"
  "DE|$DE"
  "WM|$WM"
  "Theme|$THEME"
  "Icons|$ICONS"
  "Font|$FONT"
  "Cursor|$CURSOR"
  "Terminal|$TERM_NAME"
  "CPU|$CPU"
  "GPU|$GPU"
  "Memory|$MEM"
  "Swap|$SWAP"
  "Disk|$DISK"
  "Local IP|$LOCAL_IP"
  "Locale|$LOCALE"
)

LINES=${#INFO_LINES[@]}
for ((i=0; i<LINES; i++)); do
  LOGO_LINE="${LOGO_LINES[i]:- }"
  KEY="${INFO_LINES[i]%%|*}"
  VAL="${INFO_LINES[i]#*|}"
  printf "${CYAN}%-12s${RESET}  ${GREEN}%-12s${RESET} %s\n" "$LOGO_LINE" "$KEY" "$VAL"
done
