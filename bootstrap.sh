#!/bin/bash
#
# Archduino Bootstrap — TUI Arduino Development Environment
# Works on both native Arch Linux and Arch/Ubuntu WSL2
#
# Usage: curl -kL <url> | bash
#    or: chmod +x bootstrap.sh && ./bootstrap.sh
#
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[✓]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; exit 1; }
step()  { echo -e "\n${GREEN}━━━ $1 ━━━${NC}"; }

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

echo ""
echo "  ╔═══════════════════════════════════════╗"
echo "  ║     ⚡ Archduino Bootstrap ⚡          ║"
echo "  ║  TUI Arduino Dev Environment Setup    ║"
echo "  ╚═══════════════════════════════════════╝"
echo ""
$IS_WSL && info "Detected WSL2" || info "Detected native Linux"
$IS_ARCH && info "Package manager: pacman (Arch)" || info "Package manager: apt (Ubuntu)"
echo ""

# ── 1. Base packages ────────────────────────────────────────────
step "1/9 — Installing base packages"

if $IS_ARCH; then
  sudo pacman -Syu --noconfirm
  $PKG_INSTALL base-devel git curl unzip wget ripgrep fd bat eza tree jq zsh clang tio
else
  sudo apt update && sudo apt upgrade -y
  $PKG_INSTALL build-essential git curl unzip wget ripgrep bat eza tree jq zsh clang-format tio
  # fd is named differently on Ubuntu
  sudo apt install -y fd-find 2>/dev/null || true
fi
info "Base packages installed"

# ── 2. Zsh + Oh My Zsh + plugins ───────────────────────────────
step "2/9 — Setting up Zsh"

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || \
  RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -kfsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  info "Oh My Zsh installed"
else
  info "Oh My Zsh already present"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

[[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]] && \
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

[[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]] && \
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

info "Zsh plugins installed"

# ── 3. Starship prompt ──────────────────────────────────────────
step "3/9 — Installing Starship"

if ! command -v starship &>/dev/null; then
  if $IS_ARCH; then
    $PKG_INSTALL starship
  else
    curl -ksS https://starship.rs/install.sh | sh -s -- -y
  fi
fi
info "Starship installed"

mkdir -p ~/.config
cat > ~/.config/starship.toml << 'STARSHIP'
palette = "gruvbox_dark"
format = """$directory$git_branch$git_status$character"""

[directory]
style = "bold fg:bright-yellow"
truncation_length = 3

[git_branch]
style = "bold fg:bright-green"
format = " [$branch]($style) "

[git_status]
style = "bold fg:bright-red"

[character]
success_symbol = "[❯](bold fg:bright-green)"
error_symbol = "[❯](bold fg:bright-red)"

[palettes.gruvbox_dark]
bright-yellow = "#fabd2f"
bright-green = "#b8bb26"
bright-red = "#fb4934"
bright-blue = "#83a598"
bright-purple = "#d3869b"
bright-aqua = "#8ec07c"
bright-orange = "#fe8019"
STARSHIP
info "Starship configured with Gruvbox"

# ── 4. Zellij ───────────────────────────────────────────────────
step "4/9 — Installing Zellij"

if ! command -v zellij &>/dev/null; then
  if $IS_ARCH; then
    $PKG_INSTALL zellij
  else
    curl -kL https://github.com/zellij-org/zellij/releases/latest/download/zellij-x86_64-unknown-linux-musl.tar.gz | tar xz -C /tmp
    sudo mv /tmp/zellij /usr/local/bin/
  fi
fi
info "Zellij installed"

mkdir -p ~/.config/zellij/layouts

cat > ~/.config/zellij/config.kdl << 'ZELLIJ_CFG'
theme "gruvbox-dark"
default_layout "default"
default_mode "normal"
pane_frames false
simplified_ui true
mouse_mode false

keybinds {
    shared {
        bind "Alt h" { MoveFocusOrTab "Left"; }
        bind "Alt l" { MoveFocusOrTab "Right"; }
        bind "Alt j" { MoveFocus "Down"; }
        bind "Alt k" { MoveFocus "Up"; }
        bind "Alt n" { NewPane "Down"; }
        bind "Alt v" { NewPane "Right"; }
        bind "Alt f" { ToggleFloatingPanes; }
        bind "Alt t" { NewTab; }
    }
}

themes {
    gruvbox-dark {
        fg "#ebdbb2"
        bg "#282828"
        black "#1d2021"
        red "#cc241d"
        green "#98971a"
        yellow "#d79921"
        blue "#458588"
        magenta "#b16286"
        cyan "#689d6a"
        white "#a89984"
        orange "#d65d0e"
    }
}
ZELLIJ_CFG

cat > ~/.config/zellij/layouts/arduino.kdl << 'LAYOUT'
layout {
    tab name="code" focus=true {
        pane split_direction="vertical" {
            pane size="65%" {
                command "nvim"
                args "."
            }
            pane split_direction="horizontal" {
                pane size="60%" name="terminal"
                pane size="40%" name="serial" {
                    command "bash"
                    args "-c" "echo '⚡ Serial — run: tio /dev/ttyUSB0 -b 115200'"
                }
            }
        }
    }
    tab name="git" {
        pane {
            command "lazygit"
        }
    }
}
LAYOUT
info "Zellij configured with Gruvbox + Arduino layout"

# ── 5. Neovim ───────────────────────────────────────────────────
step "5/9 — Installing Neovim (latest)"

NVIM_NEEDED=true
if command -v nvim &>/dev/null; then
  NVIM_VER=$(nvim --version | head -1 | grep -oP '\d+\.\d+\.\d+')
  if [[ "$(printf '%s\n' "0.11.2" "$NVIM_VER" | sort -V | head -1)" == "0.11.2" ]]; then
    NVIM_NEEDED=false
    info "Neovim $NVIM_VER already meets requirements"
  fi
fi

if $NVIM_NEEDED; then
  curl -kLO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
  sudo rm -rf /opt/nvim-linux-x86_64
  sudo tar -xzf nvim-linux-x86_64.tar.gz -C /opt
  sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
  rm nvim-linux-x86_64.tar.gz
  info "Neovim installed: $(nvim --version | head -1)"
fi

# ── 6. LazyVim + plugins ────────────────────────────────────────
step "6/9 — Setting up LazyVim"

if [[ ! -d "$HOME/.config/nvim/lua" ]]; then
  for d in ~/.config/nvim ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim; do
    [[ -d "$d" ]] && mv "$d" "${d}.bak.$(date +%s)"
  done
  git clone https://github.com/LazyVim/starter ~/.config/nvim
  rm -rf ~/.config/nvim/.git
  info "LazyVim starter cloned"
else
  info "Neovim config already exists, skipping LazyVim clone"
fi

mkdir -p ~/.config/nvim/lua/plugins

cat > ~/.config/nvim/lua/plugins/gruvbox.lua << 'LUA'
return {
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    config = function()
      require("gruvbox").setup({ contrast = "hard" })
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "gruvbox" },
  },
}
LUA

cat > ~/.config/nvim/lua/plugins/arduino.lua << 'LUA'
return {
  {
    "stevearc/vim-arduino",
    ft = { "arduino", "cpp", "c" },
    config = function()
      vim.g.arduino_use_cli = 1
      vim.g.arduino_cli_path = "arduino-cli"
    end,
    keys = {
      { "<leader>ac", "<cmd>ArduinoChooseBoard<cr>", desc = "Choose Board" },
      { "<leader>ap", "<cmd>ArduinoChoosePort<cr>", desc = "Choose Port" },
      { "<leader>av", "<cmd>ArduinoVerify<cr>", desc = "Verify (compile)" },
      { "<leader>au", "<cmd>ArduinoUpload<cr>", desc = "Upload" },
      { "<leader>as", "<cmd>ArduinoSerial<cr>", desc = "Serial Monitor" },
      { "<leader>ai", "<cmd>ArduinoInfo<cr>", desc = "Board Info" },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "c", "cpp" })
    end,
  },
}
LUA

cat > ~/.config/nvim/lua/plugins/lsp.lua << 'LUA'
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
          },
        },
      },
    },
  },
}
LUA
info "LazyVim plugins configured (Gruvbox + Arduino + LSP)"

# ── 7. Arduino CLI ──────────────────────────────────────────────
step "7/9 — Installing Arduino CLI + board cores"

if ! command -v arduino-cli &>/dev/null; then
  curl -kfsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | BINDIR=/usr/local/bin sh
fi
info "Arduino CLI installed: $(arduino-cli version 2>/dev/null | head -1)"

arduino-cli config init 2>/dev/null || true

# Add ESP board manager URLs
arduino-cli config add board_manager.additional_urls \
  https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json 2>/dev/null || true
arduino-cli config add board_manager.additional_urls \
  https://arduino.esp8266.com/stable/package_esp8266com_index.json 2>/dev/null || true

arduino-cli core update-index

info "Installing AVR core..."
arduino-cli core install arduino:avr

info "Installing ESP32 core..."
arduino-cli core install esp32:esp32

info "Installing ESP8266 core..."
arduino-cli core install esp8266:esp8266

# Common libs
arduino-cli lib install "Servo" "ArduinoJson" "Adafruit Unified Sensor" "DHT sensor library" 2>/dev/null || true
info "Board cores & libraries installed"

# ── 8. Git + Lazygit ────────────────────────────────────────────
step "8/9 — Setting up Git + Lazygit"

if ! command -v lazygit &>/dev/null; then
  if $IS_ARCH; then
    $PKG_INSTALL lazygit
  else
    LAZYGIT_VERSION=$(curl -ks "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | jq -r '.tag_name' | sed 's/v//')
    curl -kLo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
    sudo mv /tmp/lazygit /usr/local/bin/
  fi
fi
info "Lazygit installed"

mkdir -p ~/.config/lazygit
cat > ~/.config/lazygit/config.yml << 'LAZYGIT'
gui:
  theme:
    activeBorderColor:
      - "#fabd2f"
      - bold
    inactiveBorderColor:
      - "#665c54"
    selectedLineBgColor:
      - "#3c3836"
    cherryPickedCommitFgColor:
      - "#b8bb26"
    defaultFgColor:
      - "#ebdbb2"
LAZYGIT
info "Lazygit configured with Gruvbox"

# ── 9. Scaffolding tool + templates ─────────────────────────────
step "9/9 — Creating project scaffolding tool"

mkdir -p ~/.local/bin ~/.config/archduino/templates

cat > ~/.local/bin/arduino-new << 'SCAFFOLD'
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
cat > ~/.config/archduino/templates/default.ino << 'INO'
void setup() {
  Serial.begin(115200);
  while (!Serial) { ; }
  Serial.println("Hello from Arduino!");
}

void loop() {
  // Your code here
}
INO

cat > ~/.config/archduino/templates/esp32.ino << 'INO'
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

cat > ~/.config/archduino/templates/esp8266.ino << 'INO'
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

# ── Write .zshrc ────────────────────────────────────────────────
step "Finalizing shell config"

# Append archduino block to .zshrc if not already present
if ! grep -q "ARCHDUINO" ~/.zshrc 2>/dev/null; then
  cat >> ~/.zshrc << 'ZSHRC'

# ── ARCHDUINO CONFIG ────────────────────────────────────────────
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

export PATH="$HOME/.local/bin:$PATH"
export EDITOR="nvim"
export VISUAL="nvim"

eval "$(starship init zsh)"

# Auto-start Zellij
if [[ -z "$ZELLIJ" ]]; then
  zellij attach --create archduino
fi

# Arduino aliases
alias adev="zellij --layout arduino"
alias ac="arduino-cli"
alias acc="arduino-cli compile"
alias acu="arduino-cli upload"
alias acm="arduino-cli monitor"
alias acb="arduino-cli board list"
alias lg="lazygit"
alias v="nvim"
# ── END ARCHDUINO ───────────────────────────────────────────────
ZSHRC
  info "Shell config updated"
else
  info "Shell config already contains Archduino block"
fi

# ── WSL2 extras ─────────────────────────────────────────────────
if $IS_WSL; then
  step "WSL2 extras"
  warn "USB passthrough requires usbipd-win on Windows."
  warn "Install it with:  winget install usbipd"
  warn "Then attach your Arduino:  usbipd attach --wsl --busid <BUSID>"

  # Add user to dialout for serial access
  sudo usermod -aG dialout "$USER" 2>/dev/null || true
  sudo usermod -aG uucp "$USER" 2>/dev/null || true
fi

# ── Done ────────────────────────────────────────────────────────
echo ""
echo "  ╔═══════════════════════════════════════╗"
echo "  ║     ⚡ Archduino Setup Complete ⚡     ║"
echo "  ╚═══════════════════════════════════════╝"
echo ""
info "Start a new shell or run: source ~/.zshrc"
info "Quick start:"
echo "    arduino-new my-project uno    # scaffold a project"
echo "    adev                          # launch Arduino workspace"
echo "    <leader>av                    # compile in Neovim"
echo "    <leader>au                    # upload in Neovim"
echo ""
