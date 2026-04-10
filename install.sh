#!/bin/bash
#
# Archduino Install — TUI Arduino Development Environment
# Works on both native Arch Linux and Arch/Ubuntu WSL2
#
# Usage: chmod +x install.sh && ./install.sh
#    or: bash install.sh
#

# Re-exec with bash if invoked via sh/dash
if [ -z "$BASH_VERSION" ]; then
  exec bash "$0" "$@"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Load helpers and detect environment ─────────────────────────
source "$SCRIPT_DIR/lib/common.sh"

echo ""
echo "  ╔═══════════════════════════════════════╗"
echo "  ║       ⚡ Archduino Bootstrap ⚡       ║"
echo "  ║  TUI Arduino Dev Environment Setup    ║"
echo "  ╚═══════════════════════════════════════╝"
echo ""
$IS_WSL && info "Detected WSL2" || info "Detected native Linux"
$IS_ARCH && info "Package manager: pacman (Arch)" || info "Package manager: apt (Ubuntu)"
echo ""

# ── Select colorscheme ────────────────────────────────────────────
source "$SCRIPT_DIR/lib/themes.sh"
select_theme
echo ""

# ── Select output mode ──────────────────────────────────────────
echo "  Select installation output:"
echo ""
echo "    1) Progress bar (clean)"
echo "    2) Full details  (verbose)"
echo ""
read -rp "  Choice [1/2]: " output_choice
case "$output_choice" in
  1) VERBOSE=false ;;
  *) VERBOSE=true ;;
esac
echo ""

# ── Acquire sudo upfront and keep it alive ──────────────────────
info "Requesting sudo access (you will only be asked once)..."
sudo -v || error "Failed to obtain sudo. Aborting."

# Refresh sudo timestamp in the background until this script exits
( while kill -0 $$ 2>/dev/null; do sudo -n true; sleep 50; done ) &
SUDO_KEEPALIVE_PID=$!

INSTALL_SUCCESS=false

cleanup() {
  local exit_code=$?
  kill $SUDO_KEEPALIVE_PID 2>/dev/null
  if ! $VERBOSE && [[ -e /proc/self/fd/3 ]]; then
    exec 1>&3 2>&4 3>&- 4>&-
    if ! $INSTALL_SUCCESS; then
      echo ""
      echo -e "  ${RED}[✗]${NC} Installation failed (exit $exit_code). See log: $LOG_FILE"
    fi
  fi
}
trap cleanup EXIT

# ── Enter quiet mode if selected ────────────────────────────────
if ! $VERBOSE; then
  begin_quiet_mode
fi

# ── Run install steps ───────────────────────────────────────────
source "$SCRIPT_DIR/lib/packages.sh"
source "$SCRIPT_DIR/lib/fonts.sh"
source "$SCRIPT_DIR/lib/zsh.sh"
source "$SCRIPT_DIR/lib/starship.sh"
source "$SCRIPT_DIR/lib/zellij.sh"
source "$SCRIPT_DIR/lib/neovim.sh"
source "$SCRIPT_DIR/lib/yazi.sh"
source "$SCRIPT_DIR/lib/arduino.sh"
source "$SCRIPT_DIR/lib/renode.sh"
source "$SCRIPT_DIR/lib/git.sh"
source "$SCRIPT_DIR/lib/scaffold.sh"
source "$SCRIPT_DIR/lib/shell-config.sh"

# ── Restore output if in quiet mode ────────────────────────────
if ! $VERBOSE; then
  end_quiet_mode
fi

INSTALL_SUCCESS=true

# ── Done ────────────────────────────────────────────────────────
echo ""
echo "  ╔═══════════════════════════════════════╗"
echo "  ║      ⚡ Archduino Setup Complete ⚡     ║"
echo "  ╚═══════════════════════════════════════╝"
echo ""
info "Quick start (after reboot):"
echo "    arduino-new my-project uno    # scaffold a project"
echo "    adev                          # launch Arduino workspace"
echo "    <leader>av                    # compile in Neovim"
echo "    <leader>au                    # upload in Neovim"
echo "    arduino-sim build/fw.elf      # simulate with Renode"
echo "    <leader>ds                    # attach debugger to Renode"
echo "    theme                         # switch colorscheme"
echo ""
warn "A reboot is recommended to apply all changes (shell, groups, PATH)."
echo ""
read -rp "  Reboot now? [y/N]: " reboot_choice
if [[ "$reboot_choice" =~ ^[Yy]$ ]]; then
  info "Rebooting..."
  sudo reboot
else
  info "Reboot skipped. Remember to reboot before starting."
fi
