#!/bin/bash
# Step 7: Arduino CLI + board cores

step "7/9 — Installing Arduino CLI + board cores"

if $IS_ARCH; then
  $PKG_INSTALL arduino-cli
else
  curl -kfsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | BINDIR=/usr/local/bin sudo sh
fi
info "Arduino CLI installed: $(arduino-cli version 2>/dev/null | head -1)"

arduino-cli config init 2>/dev/null || true

# Add ESP board manager URLs
arduino-cli config add board_manager.additional_urls \
  https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json 2>/dev/null || true
arduino-cli config add board_manager.additional_urls \
  https://arduino.esp8266.com/stable/package_esp8266com_index.json 2>/dev/null || true

arduino-cli core update-index

info "Installing/updating AVR core..."
arduino-cli core install arduino:avr

info "Installing/updating ESP32 core..."
arduino-cli core install esp32:esp32

info "Installing/updating ESP8266 core..."
arduino-cli core install esp8266:esp8266

# Upgrade all installed cores to latest
arduino-cli core upgrade

# Common libs (install is idempotent, upgrade updates them)
arduino-cli lib install "Servo" "ArduinoJson" "Adafruit Unified Sensor" "DHT sensor library" 2>/dev/null || true
arduino-cli lib upgrade 2>/dev/null || true
info "Board cores & libraries installed/updated"
