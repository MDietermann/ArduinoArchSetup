#!/bin/bash
# Step 9: Project scaffolding tool + templates

step "9/9 — Creating project scaffolding tool"

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

git init -q
echo "✓ Created '$PROJECT' for $BOARD ($FQBN)"
echo "  cd $PROJECT && nvim $PROJECT.ino"
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
info "Scaffolding tool + templates created"
