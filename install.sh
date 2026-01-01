#!/bin/bash

# --- CONFIGURATION ---
INSTALL_DIR="/usr/local/bin"
BINARY_NAME="minifetch"

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then 
  echo "Error: Please run as root (sudo ./install.sh)"
  exit 1
fi

echo "Generating $BINARY_NAME source code..."

# Create the source code file temporarily
cat << 'EOF' > /tmp/minifetch_source
#!/bin/bash

# --- COLORS ---
c_reset="\033[0m"
c_main="\033[1;34m"    # Blue (Logo)
c_title="\033[1;32m"   # Green (User@Host)
c_label="\033[1;33m"   # Yellow (Labels)
c_text="\033[0m"       # White (Values)

# --- SYSTEM INFORMATION GATHERING ---

# User and Hostname
user="${USER}"
host="${HOSTNAME}"

# Operating System
if [ -f /etc/os-release ]; then
    . /etc/os-release
    os_name="$PRETTY_NAME"
else
    os_name=$(uname -s)
fi

# Kernel Version
kernel=$(uname -r)

# Uptime
uptime_info=$(uptime -p 2>/dev/null | sed 's/up //')
if [ -z "$uptime_info" ]; then
    uptime_info=$(uptime | awk -F'( |,|:)+' '{print $6"h "$7"m"}')
fi

# Shell Name
shell_name=${SHELL##*/}

# Memory (RAM) Usage
if [ -f /proc/meminfo ]; then
    mem_total=$(grep MemTotal /proc/meminfo | awk '{print int($2/1024)}')
    mem_avail=$(grep MemAvailable /proc/meminfo | awk '{print int($2/1024)}')
    mem_used=$((mem_total - mem_avail))
    mem_info="${mem_used}MiB / ${mem_total}MiB"
else
    mem_info="Not available"
fi

# --- LOGO DEFINITIONS ---
# Based on $ID from /etc/os-release
ascii_art=""

case "${ID}" in
    ubuntu|debian|mint|kali)
        ascii_art="
    _____
   /  __ \\
  |  /  | |
  |  \__| |
   \_____/
"
        ;;
    arch|manjaro)
        ascii_art="
      /\\
     /  \\
    /    \\
   /______\\
  /        \\
"
        ;;
    fedora|rhel|centos)
        ascii_art="
    ,____,
   /      \\
  |        |
  |  f     |
   \______/
"
        ;;
    *)
        # Default Penguin-style Logo
        ascii_art="
    .--.
   |o_o |
   |:_/ |
  //   \\ \\
 (|     | )
/'\\_   _/ \`
\___)=(___/
"
        ;;
esac

# --- OUTPUT FORMATTING ---

# Split ASCII art into an array
IFS=$'\n' read -rd '' -a logo_lines <<< "$ascii_art"

# Define the info lines
info_lines=(
    "${c_title}${user}@${host}${c_reset}"
    "-------------------"
    "${c_label}OS    :${c_text} $os_name"
    "${c_label}Kernel:${c_text} $kernel"
    "${c_label}Uptime:${c_text} $uptime_info"
    "${c_label}Shell :${c_text} $shell_name"
    "${c_label}Memory:${c_text} $mem_info"
)

# Calculate line counts
num_logo=${#logo_lines[@]}
num_info=${#info_lines[@]}
max_lines=$(( num_logo > num_info ? num_logo : num_info ))

# Print Logo and Info side-by-side
for ((i=0; i<max_lines; i++)); do
    logo_line="${logo_lines[$i]}"
    info_line="${info_lines[$i]}"
    
    # Format: 16 chars for logo, then info
    printf "${c_main}%-16s${c_reset} %b\n" "$logo_line" "$info_line"
done

echo ""
EOF

# --- INSTALLATION PROCESS ---

echo "Installing to $INSTALL_DIR/$BINARY_NAME..."

# Move the file and set permissions
mv /tmp/minifetch_source "$INSTALL_DIR/$BINARY_NAME"
chmod +x "$INSTALL_DIR/$BINARY_NAME"

if [ $? -eq 0 ]; then
    echo "------------------------------------------------"
    echo "Success! You can now run the command: $BINARY_NAME"
    echo "------------------------------------------------"
else
    echo "Installation failed. Check your permissions."
fi