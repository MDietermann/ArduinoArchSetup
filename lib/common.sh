#!/bin/bash
# Common helpers and environment detection

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

VERBOSE=true
LOG_FILE="/tmp/archduino-install.log"
CURRENT_STEP=0
TOTAL_STEPS=12

info() { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() {
  echo -e "${RED}[✗]${NC} $1"
  exit 1
}
step() { echo -e "\n${GREEN}━━━ $1 ━━━${NC}"; }

# ── Quiet-mode progress bar ────────────────────────────────────
draw_progress() {
  local current=$1
  local total=$2
  local label=$3
  local pct=$((current * 100 / total))
  local bar_width=40
  local filled=$((pct * bar_width / 100))
  local empty=$((bar_width - filled))
  local bar="" space=""
  for ((i = 0; i < filled; i++)); do bar+="█"; done
  for ((i = 0; i < empty; i++)); do space+="░"; done
  printf "\033[2K\r  ${GREEN}${bar}${NC}${space} %3d%%  ${BOLD}%s${NC}" "$pct" "$label" >&3
}

begin_quiet_mode() {
  $IS_WSL && TOTAL_STEPS=13
  : >"$LOG_FILE"

  # Save real terminal to fd 3/4, redirect everything else to log
  exec 3>&1 4>&2
  exec 1>>"$LOG_FILE" 2>&1

  # Override output helpers to talk to the terminal via fd 3
  step() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    draw_progress "$CURRENT_STEP" "$TOTAL_STEPS" "$1"
  }
  info() { :; }
  warn() { printf "\033[2K\r  ${YELLOW}[!]${NC} %s\n" "$1" >&3; }
  error() {
    printf "\033[2K\r  ${RED}[✗]${NC} %s\n" "$1" >&3
    echo "    See log: $LOG_FILE" >&3
    exit 1
  }
}

end_quiet_mode() {
  # Restore stdout/stderr
  exec 1>&3 2>&4
  exec 3>&- 4>&-
  echo ""
}

# ── Config backup helper ─────────────────────────────────────────
BACKUP_DIR="$HOME/.config/archduino/backups/$(date +%Y%m%d_%H%M%S)"

backup_config() {
  local src="$1"
  [[ ! -e "$src" ]] && return 0
  mkdir -p "$BACKUP_DIR"
  cp -a "$src" "$BACKUP_DIR/"
  info "Backed up $(basename "$src") → $BACKUP_DIR/"
}

# ── TLS workaround ───────────────────────────────────────────────
# Many corporate/WSL environments have broken CA chains. Export this so
# all git operations (clone, pull) skip certificate verification,
# matching the -k flag used on all curl calls throughout the installer.
export GIT_SSL_NO_VERIFY=1

# ── Detect environment ──────────────────────────────────────────
IS_WSL=false
[[ -f /proc/version ]] && grep -qi microsoft /proc/version && IS_WSL=true

IS_ARCH=false
IS_UBUNTU=false
if command -v pacman &>/dev/null; then
  IS_ARCH=true
  PKG_INSTALL="sudo pacman -S --needed --noconfirm"
elif command -v apt &>/dev/null; then
  IS_UBUNTU=true
  PKG_INSTALL="sudo apt install -y"
else
  error "Unsupported distro. Need Arch (pacman) or Ubuntu (apt)."
fi
