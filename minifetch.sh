#!/usr/bin/env bash

# =====================
# minifetch (fastfetch style)
# =====================

RED="\e[31m"
BOLD="\e[1m"
RESET="\e[0m"
GRAY="\e[90m"

# ---------- helpers ----------
cmd() { command -v "$1" >/dev/null 2>&1; }

# ---------- system info ----------
OS_PRETTY="$(. /etc/os-release 2>/dev/null && echo "$PRETTY_NAME")"
OS_NAME="$(. /etc/os-release 2>/dev/null && echo "$NAME")"
HOST="$(hostname)"
KERNEL="$(uname -r)"
UPTIME="$(uptime -p | sed 's/up //')"
SHELL_NAME="$(basename "$SHELL")"
LOCALE="${LANG:-N/A}"

PACKAGES="N/A"
cmd dpkg && PACKAGES="$(dpkg -l | grep '^ii' | wc -l) (dpkg)"
cmd pacman && PACKAGES="$(pacman -Qq | wc -l) (pacman)"
cmd rpm && PACKAGES="$(rpm -qa | wc -l) (rpm)"

CPU="$(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | sed 's/^ //')"
GPU="N/A"
cmd lspci && GPU="$(lspci | grep -Ei 'vga|3d|display' | head -n1 | cut -d: -f3 | sed 's/^ //')"

MEM="$(free -h | awk '/Mem:/ {print $3 " / " $2}')"
SWAP="$(free -h | awk '/Swap:/ {print $3 " / " $2}')"
DISK="$(df -h / | awk 'NR==2 {print $3 " / " $2 " (" $5 ")"}')"
LOCAL_IP="$(ip route get 1.1.1.1 2>/dev/null | awk '{print $7}')"

DE="${XDG_CURRENT_DESKTOP:-N/A}"
WM="N/A"; cmd wmctrl && WM="$(wmctrl -m | awk -F: '/Name/ {print $2}')"
THEME="${GTK_THEME:-N/A}"
ICONS="${ICON_THEME:-N/A}"
FONT="${GTK_FONT_NAME:-N/A}"
CURSOR="${XCURSOR_THEME:-N/A}"
TERM_NAME="${TERM_PROGRAM:-$TERM}"

# ---------- logos (OWN STYLE) ----------
# sama tyyli kaikille, eri muoto
case "$OS_NAME" in
  Ubuntu*)
LOGO=(
"      ██████      "
"   ████      ███  "
"  ██   ██  ██   ██"
"   ████      ███  "
"      ██████      "
)
;;
  Arch*)
LOGO=(
"        ██        "
"       ████       "
"      ██  ██      "
"     ██    ██     "
"    ██      ██    "
)
;;
  Fedora*)
LOGO=(
"     ███████      "
"    ██      ██    "
"    ██      ██    "
"    ██      ██    "
"     ████████     "
)
;;
  Debian*)
LOGO=(
"      █████       "
"    ██     ██     "
"    ██     ██     "
"     ██   ██      "
"       ███        "
)
;;
  *)
LOGO=(
"    ████████      "
"    ██            "
"    ███████       "
"          ██      "
"    ████████      "
)
;;
esac

# ---------- info lines ----------
INFO=(
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

# ---------- render ----------
LINES=${#INFO[@]}
for ((i=0; i<LINES; i++)); do
  LOGO_LINE="${LOGO[i]:- }"
  KEY="${INFO[i]%%|*}"
  VAL="${INFO[i]#*|}"

  printf "${RED}%s${RESET}  ${BOLD}%-10s${RESET} %s\n" \
    "$LOGO_LINE" "$KEY:" "$VAL"
done

# ---------- color blocks ----------
echo
printf "  "
for c in 30 31 32 33 34 35 36 37; do
  printf "\e[${c}m██${RESET}"
done
echo
