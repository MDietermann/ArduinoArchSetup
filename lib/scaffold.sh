#!/bin/bash
# Step 9: Project scaffolding tool + templates

step "12/12 — Creating project scaffolding tool"

mkdir -p ~/.local/bin ~/.config/archduino/templates

cat >~/.local/bin/arduino-new <<'SCAFFOLD'
#!/bin/bash
set -e

TEMPLATE_DIR="$HOME/.config/archduino/templates"

declare -A FQBN_MAP=(
  ["uno"]="arduino:avr:uno"
  ["mega"]="arduino:avr:mega"
  ["nano"]="arduino:avr:nano"
  ["esp32"]="esp32:esp32:esp32"
  ["esp32s3"]="esp32:esp32:esp32s3"
  ["esp8266"]="esp8266:esp8266:nodemcuv2"
)

usage() {
  echo "Usage: arduino-new <project-name> <board>"
  echo ""
  echo "Available boards:"
  for board in "${!FQBN_MAP[@]}"; do
    printf "  %-12s %s\n" "$board" "${FQBN_MAP[$board]}"
  done
  exit 1
}

[[ $# -lt 2 ]] && usage

PROJECT="$1"
BOARD="$2"
FQBN="${FQBN_MAP[$BOARD]}"

[[ -z "$FQBN" ]] && echo "Unknown board: $BOARD" && usage

mkdir -p "$PROJECT"
cd "$PROJECT"

if [[ -f "$TEMPLATE_DIR/$BOARD.ino" ]]; then
  cp "$TEMPLATE_DIR/$BOARD.ino" "$PROJECT.ino"
else
  cp "$TEMPLATE_DIR/default.ino" "$PROJECT.ino"
fi

cat > sketch.yaml <<EOF
default_fqbn: $FQBN
default_port: auto
EOF

cat > .clangd <<EOF
CompileFlags:
  Add:
    - -xc++
    - -std=c++17
EOF

cat > .gitignore <<EOF
build/
.cache/
*.elf
*.hex
*.bin
EOF

# ── Wokwi simulation config ─────────────────────────────────────
# Determine firmware path format based on board family
case "$BOARD" in
  esp32|esp32s3|esp8266)
    WOKWI_FW="build/$PROJECT.ino.merged.bin"
    ;;
  *)
    WOKWI_FW="build/$PROJECT.ino.hex"
    ;;
esac

cat > wokwi.toml <<EOF
[wokwi]
version = 1
firmware = "$WOKWI_FW"
elf = "build/$PROJECT.ino.elf"
EOF

# Board-specific diagram with button + LED on breadboard
DIAGRAM_TEMPLATE="$TEMPLATE_DIR/diagram-$BOARD.json"
if [[ -f "$DIAGRAM_TEMPLATE" ]]; then
  cp "$DIAGRAM_TEMPLATE" diagram.json
else
  cp "$TEMPLATE_DIR/diagram-default.json" diagram.json
fi

git init -q
echo "✓ Created '$PROJECT' for $BOARD ($FQBN)"
echo "  cd $PROJECT && nvim $PROJECT.ino"
echo ""
echo "  Simulate:  arduino-cli compile --fqbn $FQBN --output-dir build ."
echo "             wokwi-cli ."
SCAFFOLD
chmod +x ~/.local/bin/arduino-new

# Templates
cat >~/.config/archduino/templates/default.ino <<'INO'
void setup() {
  Serial.begin(115200);
  while (!Serial) { ; }
  Serial.println("Hello from Arduino!");
}

void loop() {
  // Your code here
}
INO

cat >~/.config/archduino/templates/esp32.ino <<'INO'
#include <WiFi.h>

const char* ssid = "YOUR_SSID";
const char* password = "YOUR_PASS";

void setup() {
  Serial.begin(115200);
  delay(1000);
  WiFi.begin(ssid, password);
  Serial.print("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println();
  Serial.print("Connected! IP: ");
  Serial.println(WiFi.localIP());
}

void loop() {
  delay(1000);
}
INO

cat >~/.config/archduino/templates/esp8266.ino <<'INO'
#include <ESP8266WiFi.h>

const char* ssid = "YOUR_SSID";
const char* password = "YOUR_PASS";

void setup() {
  Serial.begin(115200);
  delay(1000);
  WiFi.begin(ssid, password);
  Serial.print("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println();
  Serial.print("Connected! IP: ");
  Serial.println(WiFi.localIP());
}

void loop() {
  delay(1000);
}
INO
# ── Wokwi diagram templates ──────────────────────────────────────
cat >~/.config/archduino/templates/diagram-default.json <<'JSON'
{
  "version": 1,
  "author": "Archduino",
  "editor": "wokwi",
  "parts": [
    { "type": "wokwi-arduino-uno", "id": "mcu", "top": 0, "left": 0 },
    { "type": "wokwi-led", "id": "led1", "top": 110, "left": 50, "attrs": { "color": "green" } },
    { "type": "wokwi-resistor", "id": "r1", "top": 150, "left": 30, "attrs": { "value": "220" } },
    { "type": "wokwi-pushbutton", "id": "btn1", "top": 110, "left": 150, "attrs": { "color": "blue" } }
  ],
  "connections": [
    ["mcu:2", "led1:A", "green", []],
    ["led1:C", "r1:1", "black", []],
    ["r1:2", "mcu:GND.1", "black", []],
    ["mcu:4", "btn1:1.l", "blue", []],
    ["btn1:2.l", "mcu:GND.2", "black", []]
  ],
  "serialMonitor": { "display": "auto" }
}
JSON

cat >~/.config/archduino/templates/diagram-esp32.json <<'JSON'
{
  "version": 1,
  "author": "Archduino",
  "editor": "wokwi",
  "parts": [
    { "type": "board-esp32-devkit-c-v4", "id": "esp", "top": 0, "left": 0 },
    { "type": "wokwi-led", "id": "led1", "top": 110, "left": 50, "attrs": { "color": "green" } },
    { "type": "wokwi-resistor", "id": "r1", "top": 150, "left": 30, "attrs": { "value": "220" } },
    { "type": "wokwi-pushbutton", "id": "btn1", "top": 110, "left": 150, "attrs": { "color": "blue" } }
  ],
  "connections": [
    ["esp:TX", "$serialMonitor:RX", "", []],
    ["esp:RX", "$serialMonitor:TX", "", []],
    ["esp:2", "led1:A", "green", []],
    ["led1:C", "r1:1", "black", []],
    ["r1:2", "esp:GND.1", "black", []],
    ["esp:4", "btn1:1.l", "blue", []],
    ["btn1:2.l", "esp:GND.2", "black", []]
  ],
  "serialMonitor": { "display": "auto" }
}
JSON

cat >~/.config/archduino/templates/diagram-esp32s3.json <<'JSON'
{
  "version": 1,
  "author": "Archduino",
  "editor": "wokwi",
  "parts": [
    { "type": "board-esp32-s3-devkitc-1", "id": "esp", "top": 0, "left": 0, "attrs": { "serialInterface": "USB_SERIAL_JTAG" } },
    { "type": "wokwi-led", "id": "led1", "top": 110, "left": 50, "attrs": { "color": "green" } },
    { "type": "wokwi-resistor", "id": "r1", "top": 150, "left": 30, "attrs": { "value": "220" } },
    { "type": "wokwi-pushbutton", "id": "btn1", "top": 110, "left": 150, "attrs": { "color": "blue" } }
  ],
  "connections": [
    ["esp:2", "led1:A", "green", []],
    ["led1:C", "r1:1", "black", []],
    ["r1:2", "esp:GND.1", "black", []],
    ["esp:4", "btn1:1.l", "blue", []],
    ["btn1:2.l", "esp:GND.2", "black", []]
  ],
  "serialMonitor": { "display": "auto" }
}
JSON

cat >~/.config/archduino/templates/diagram-uno.json <<'JSON'
{
  "version": 1,
  "author": "Archduino",
  "editor": "wokwi",
  "parts": [
    { "type": "wokwi-arduino-uno", "id": "mcu", "top": 0, "left": 0 },
    { "type": "wokwi-led", "id": "led1", "top": 110, "left": 50, "attrs": { "color": "green" } },
    { "type": "wokwi-resistor", "id": "r1", "top": 150, "left": 30, "attrs": { "value": "220" } },
    { "type": "wokwi-pushbutton", "id": "btn1", "top": 110, "left": 150, "attrs": { "color": "blue" } }
  ],
  "connections": [
    ["mcu:2", "led1:A", "green", []],
    ["led1:C", "r1:1", "black", []],
    ["r1:2", "mcu:GND.1", "black", []],
    ["mcu:4", "btn1:1.l", "blue", []],
    ["btn1:2.l", "mcu:GND.2", "black", []]
  ],
  "serialMonitor": { "display": "auto" }
}
JSON

cat >~/.config/archduino/templates/diagram-mega.json <<'JSON'
{
  "version": 1,
  "author": "Archduino",
  "editor": "wokwi",
  "parts": [
    { "type": "wokwi-arduino-mega", "id": "mcu", "top": 0, "left": 0 },
    { "type": "wokwi-led", "id": "led1", "top": 110, "left": 50, "attrs": { "color": "green" } },
    { "type": "wokwi-resistor", "id": "r1", "top": 150, "left": 30, "attrs": { "value": "220" } },
    { "type": "wokwi-pushbutton", "id": "btn1", "top": 110, "left": 150, "attrs": { "color": "blue" } }
  ],
  "connections": [
    ["mcu:2", "led1:A", "green", []],
    ["led1:C", "r1:1", "black", []],
    ["r1:2", "mcu:GND.1", "black", []],
    ["mcu:4", "btn1:1.l", "blue", []],
    ["btn1:2.l", "mcu:GND.2", "black", []]
  ],
  "serialMonitor": { "display": "auto" }
}
JSON

cat >~/.config/archduino/templates/diagram-nano.json <<'JSON'
{
  "version": 1,
  "author": "Archduino",
  "editor": "wokwi",
  "parts": [
    { "type": "wokwi-arduino-nano", "id": "mcu", "top": 0, "left": 0 },
    { "type": "wokwi-led", "id": "led1", "top": 110, "left": 50, "attrs": { "color": "green" } },
    { "type": "wokwi-resistor", "id": "r1", "top": 150, "left": 30, "attrs": { "value": "220" } },
    { "type": "wokwi-pushbutton", "id": "btn1", "top": 110, "left": 150, "attrs": { "color": "blue" } }
  ],
  "connections": [
    ["mcu:D2", "led1:A", "green", []],
    ["led1:C", "r1:1", "black", []],
    ["r1:2", "mcu:GND.1", "black", []],
    ["mcu:D4", "btn1:1.l", "blue", []],
    ["btn1:2.l", "mcu:GND.2", "black", []]
  ],
  "serialMonitor": { "display": "auto" }
}
JSON

# ── Install theme files + theme switcher ─────────────────────────
mkdir -p ~/.config/archduino/themes
cp "$SCRIPT_DIR/lib/themes/"*.sh ~/.config/archduino/themes/

cat >~/.local/bin/archduino-theme <<'SWITCHER'
#!/bin/bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

info() { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; exit 1; }

THEMES_DIR="$HOME/.config/archduino/themes"
THEME_SAVE="$HOME/.config/archduino/theme"

[[ ! -d "$THEMES_DIR" ]] && error "Theme files not found. Re-run the Archduino installer."

THEME_FILES=(gruvbox catppuccin tokyonight nord dracula)

# Load saved theme
saved_theme="" current_idx=0
if [[ -f "$THEME_SAVE" ]]; then
  saved_theme=$(cat "$THEME_SAVE")
  for idx in "${!THEME_FILES[@]}"; do
    [[ "${THEME_FILES[$idx]}" == "$saved_theme" ]] && current_idx=$((idx + 1)) && break
  done
fi

echo ""
echo -e "  ${BOLD}Archduino Theme Switcher${NC}"
echo ""

i=1
for t in "${THEME_FILES[@]}"; do
  source "$THEMES_DIR/$t.sh"
  if [[ $i -eq $current_idx ]]; then
    printf "    %d) %s ${GREEN}(current)${NC}\n" "$i" "$THEME_DISPLAY_NAME"
  else
    printf "    %d) %s\n" "$i" "$THEME_DISPLAY_NAME"
  fi
  i=$((i + 1))
done

echo ""
read -rp "  Choice [1-${#THEME_FILES[@]}]: " choice

if [[ -z "$choice" || ! "$choice" =~ ^[0-9]+$ ]] || ((choice < 1 || choice > ${#THEME_FILES[@]})); then
  echo "  No change."
  exit 0
fi

if [[ $choice -eq $current_idx ]]; then
  echo "  Already using that theme."
  exit 0
fi

selected="${THEME_FILES[$((choice - 1))]}"
source "$THEMES_DIR/$selected.sh"

echo ""
info "Applying $THEME_DISPLAY_NAME..."

# Starship
write_starship_config ~/.config/starship.toml
info "Starship updated"

# Zellij
write_zellij_config ~/.config/zellij/config.kdl
info "Zellij updated"

# Lazygit
write_lazygit_config ~/.config/lazygit/config.yml
info "Lazygit updated"

# Yazi
mkdir -p ~/.config/yazi
write_yazi_config ~/.config/yazi/theme.toml
info "Yazi updated"

# NvChad
NVIM_CFG="$HOME/.config/nvim"
if [[ -f "$NVIM_CFG/lua/chadrc.lua" ]]; then
  cat >"$NVIM_CFG/lua/chadrc.lua" <<EOF
---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "$NVCHAD_THEME",
}

return M
EOF
  # Clear theme cache
  rm -rf ~/.local/share/nvim/lazy/base46/lua/base46/themes 2>/dev/null || true
  rm -rf ~/.cache/nvim/base46 2>/dev/null || true
  info "NvChad updated (restart nvim to see changes)"
fi

# Save choice
echo "$selected" > "$THEME_SAVE"

echo ""
info "Theme switched to $THEME_DISPLAY_NAME"
warn "Restart Zellij and Neovim for full effect."
echo ""
SWITCHER
chmod +x ~/.local/bin/archduino-theme

info "Scaffolding tool, templates, and theme switcher created"
