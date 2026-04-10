#!/bin/bash
# Step 7: Arduino CLI + board cores

step "9/11 — Installing Arduino CLI + board cores"

if $IS_ARCH; then
  $PKG_INSTALL arduino-cli
else
  ACLI_VERSION=$(curl -ks "https://api.github.com/repos/arduino/arduino-cli/releases/latest" | jq -r '.tag_name' | sed 's/v//')
  curl -ksSLo /tmp/arduino-cli.tar.gz "https://downloads.arduino.cc/arduino-cli/arduino-cli_${ACLI_VERSION}_Linux_64bit.tar.gz"
  tar xzf /tmp/arduino-cli.tar.gz -C /tmp arduino-cli
  sudo install -m 755 /tmp/arduino-cli /usr/local/bin/arduino-cli
  rm -f /tmp/arduino-cli /tmp/arduino-cli.tar.gz
fi
info "Arduino CLI installed: $(arduino-cli version 2>/dev/null | head -1)"

arduino-cli config init 2>/dev/null || true

# Add ESP board manager URLs
arduino-cli config add board_manager.additional_urls \
  https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json 2>/dev/null || true
arduino-cli config add board_manager.additional_urls \
  https://arduino.esp8266.com/stable/package_esp8266com_index.json 2>/dev/null || true

# Use --insecure for all network operations (corporate/WSL environments often
# have broken CA chains that Go's TLS stack rejects)
ACLI="arduino-cli --insecure"

$ACLI core update-index

info "Installing/updating AVR core..."
$ACLI core install arduino:avr

info "Installing/updating ESP32 core..."
$ACLI core install esp32:esp32

info "Installing/updating ESP8266 core..."
$ACLI core install esp8266:esp8266

# Upgrade all installed cores to latest
$ACLI core upgrade

# Common libs (install is idempotent, upgrade updates them)
$ACLI lib install "Servo" "ArduinoJson" "Adafruit Unified Sensor" "DHT sensor library" 2>/dev/null || true
$ACLI lib upgrade 2>/dev/null || true
info "Board cores & libraries installed/updated"
