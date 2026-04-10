#!/bin/bash
# Step 10: Renode emulator for Arduino simulation with USB HID support

step "10/12 — Installing Renode emulator"

# gdb-multiarch is needed for nvim-dap to connect to Renode's GDB server
if $IS_ARCH; then
  if ! command -v renode &>/dev/null; then
    info "Installing Renode from AUR..."
    yay -S --needed --noconfirm renode-bin
  else
    info "Renode already installed"
  fi
  $PKG_INSTALL arm-none-eabi-gdb
else
  if ! command -v renode &>/dev/null; then
    info "Installing Renode..."
    RENODE_VERSION=$(curl -ks "https://api.github.com/repos/renode/renode/releases/latest" | jq -r '.tag_name' | sed 's/^v//')
    curl -ksSLo /tmp/renode.deb "https://github.com/renode/renode/releases/download/v${RENODE_VERSION}/renode_${RENODE_VERSION}_amd64.deb"
    sudo apt install -y /tmp/renode.deb
    rm -f /tmp/renode.deb
  else
    info "Renode already installed"
  fi
  $PKG_INSTALL gdb-multiarch
fi
info "Renode installed: $(renode --version 2>/dev/null | head -1 || echo 'OK')"

# ── Renode helper script ─────────────────────────────────────────
# Provides a quick way to launch Renode with a GDB server for a firmware ELF
cat >~/.local/bin/arduino-sim <<'SIMSCRIPT'
#!/bin/bash
set -euo pipefail

usage() {
  echo "Usage: arduino-sim <firmware.elf> [platform]"
  echo ""
  echo "Launch Renode with a GDB server for debugging firmware."
  echo "Connect nvim-dap or gdb to localhost:3333"
  echo ""
  echo "Platforms:"
  echo "  stm32f4    STM32F4 Discovery  (default)"
  echo "  rp2040     Raspberry Pi Pico"
  echo "  nrf52840   nRF52840 (USB HID capable)"
  echo ""
  echo "Example:"
  echo "  arduino-sim build/firmware.elf nrf52840"
  exit 1
}

[[ $# -lt 1 ]] && usage

ELF="$1"
PLATFORM="${2:-stm32f4}"

[[ ! -f "$ELF" ]] && echo "Error: $ELF not found" && exit 1

# Map platform to Renode machine definition
case "$PLATFORM" in
  stm32f4)
    RENODE_PLATFORM="platforms/boards/stm32f4_discovery.repl"
    MACHINE="STM32F4_Discovery"
    ;;
  rp2040)
    RENODE_PLATFORM="platforms/cpus/rp2040.repl"
    MACHINE="RP2040"
    ;;
  nrf52840)
    RENODE_PLATFORM="platforms/cpus/nrf52840.repl"
    MACHINE="nRF52840"
    ;;
  *)
    echo "Unknown platform: $PLATFORM"
    usage
    ;;
esac

# Generate a temporary Renode script
RESC=$(mktemp /tmp/renode-XXXXXX.resc)
cat >"$RESC" <<EOF
using sysbus

mach create "$MACHINE"
machine LoadPlatformDescription @$RENODE_PLATFORM

sysbus LoadELF @$(realpath "$ELF")

machine StartGdbServer 3333

showAnalyzer sysbus.uart0 Antmicro.Renode.Analyzers.LoggingUartAnalyzer

start
EOF

echo "Starting Renode ($MACHINE) with GDB server on :3333"
echo "Connect debugger:  nvim → <leader>ds  or  gdb → target remote :3333"
echo ""

renode --disable-xwt "$RESC"
rm -f "$RESC"
SIMSCRIPT
chmod +x ~/.local/bin/arduino-sim

info "Renode simulation helper created (arduino-sim)"

# ── Wokwi CLI (visual breadboard simulation) ────────────────────
if ! command -v wokwi-cli &>/dev/null; then
  info "Installing Wokwi CLI..."
  WOKWI_VERSION=$(curl -ks "https://api.github.com/repos/wokwi/wokwi-cli/releases/latest" | jq -r '.tag_name' | sed 's/^v//')
  curl -ksSLo /tmp/wokwi-cli "https://github.com/wokwi/wokwi-cli/releases/download/v${WOKWI_VERSION}/wokwi-cli-linuxstatic-x64"
  sudo install -m 755 /tmp/wokwi-cli /usr/local/bin/wokwi-cli
  rm -f /tmp/wokwi-cli
else
  info "Wokwi CLI already installed"
fi
info "Wokwi CLI installed (set WOKWI_CLI_TOKEN to enable — get one at https://wokwi.com/dashboard/ci)"
