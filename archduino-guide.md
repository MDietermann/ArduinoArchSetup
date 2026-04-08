# Archduino — TUI-Only Arch Linux Arduino Development Environment

A keyboard-driven, mouse-free Arch Linux setup for Arduino development built on **Zellij + Neovim + Arduino CLI**, themed in **Gruvbox**, targeting both WSL2 and native Arch.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────┐
│  Zellij (multiplexer + workspace manager)       │
│ ┌─────────────────────┬───────────────────────┐ │
│ │  Neovim (LazyVim)   │  Serial Monitor       │ │
│ │  - clangd LSP       │  (arduino-cli monitor)│ │
│ │  - Arduino syntax   │                       │ │
│ │  - compile/upload   │                       │ │
│ │    keybinds         │                       │ │
│ ├─────────────────────┼───────────────────────┤ │
│ │  Terminal / Build   │  lazygit              │ │
│ │  output pane        │                       │ │
│ └─────────────────────┴───────────────────────┘ │
│  [zjstatus bar — board | port | project | git]  │
└─────────────────────────────────────────────────┘
```

## Table of Contents

1. [Base System](#1-base-system)
2. [Shell — Zsh + Starship](#2-shell--zsh--starship)
3. [Zellij](#3-zellij)
4. [Neovim + LazyVim](#4-neovim--lazyvim)
5. [Arduino CLI](#5-arduino-cli)
6. [Serial Monitor](#6-serial-monitor)
7. [Git + Lazygit](#7-git--lazygit)
8. [Project Scaffolding](#8-project-scaffolding)
9. [Zellij Arduino Layout](#9-zellij-arduino-layout)
10. [Neovim Arduino Keybinds](#10-neovim-arduino-keybinds)
11. [WSL2-Specific Notes](#11-wsl2-specific-notes)
12. [Quick Reference Card](#12-quick-reference-card)

---

## 1. Base System

### Native Arch

```bash
sudo pacman -Syu
sudo pacman -S base-devel git curl unzip wget ripgrep fd bat eza tree jq
```

### WSL2 Arch

If you hit SSL issues (common behind corporate proxies):

```bash
sed -i 's|https://|http://|g' /etc/pacman.d/mirrorlist
pacman -Syu ca-certificates archlinux-keyring --noconfirm
sed -i 's|http://|https://|g' /etc/pacman.d/mirrorlist
```

### Create your user (if root-only)

```bash
pacman -S sudo
useradd -m -G wheel -s /bin/zsh myuser
passwd myuser
EDITOR=nano visudo   # uncomment: %wheel ALL=(ALL) ALL
```

Add to `/etc/wsl.conf`:

```ini
[user]
default=myuser
```

---

## 2. Shell — Zsh + Starship

### Install Zsh

```bash
sudo pacman -S zsh
chsh -s /bin/zsh
```

### Oh My Zsh

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### Zsh Plugins

```bash
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

Edit `~/.zshrc`:

```bash
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
```

### Starship Prompt

```bash
sudo pacman -S starship
```

Add to `~/.zshrc`:

```bash
eval "$(starship init zsh)"
```

Create `~/.config/starship.toml`:

```toml
palette = "gruvbox_dark"

format = """
$directory$git_branch$git_status$character"""

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
```

---

## 3. Zellij

### Install

```bash
sudo pacman -S zellij
```

Or latest binary:

```bash
curl -kL https://github.com/zellij-org/zellij/releases/latest/download/zellij-x86_64-unknown-linux-musl.tar.gz | tar xz -C /tmp
sudo mv /tmp/zellij /usr/local/bin/
```

### Gruvbox Theme Config

Create `~/.config/zellij/config.kdl`:

```kdl
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
```

### Auto-start Zellij

Add to `~/.zshrc`:

```bash
if [[ -z "$ZELLIJ" ]]; then
    zellij attach --create archduino
fi
```

---

## 4. Neovim + LazyVim

### Install latest Neovim

```bash
curl -kLO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo tar -xzf nvim-linux-x86_64.tar.gz -C /opt
sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
rm nvim-linux-x86_64.tar.gz
```

### Install LazyVim

```bash
mv ~/.config/nvim{,.bak} 2>/dev/null
mv ~/.local/share/nvim{,.bak} 2>/dev/null
mv ~/.local/state/nvim{,.bak} 2>/dev/null
mv ~/.cache/nvim{,.bak} 2>/dev/null

git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git
```

### LSP for Arduino (clangd)

```bash
sudo pacman -S clang
```

### LazyVim Gruvbox + Arduino config

Create `~/.config/nvim/lua/plugins/gruvbox.lua`:

```lua
return {
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    config = function()
      require("gruvbox").setup({
        contrast = "hard",
      })
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox",
    },
  },
}
```

Create `~/.config/nvim/lua/plugins/arduino.lua`:

```lua
return {
  -- Arduino filetype & syntax
  {
    "stevearc/vim-arduino",
    ft = { "arduino", "cpp", "c" },
    config = function()
      vim.g.arduino_use_cli = 1
      vim.g.arduino_cli_path = "arduino-cli"
    end,
  },
  -- Better C/C++ treesitter support
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "c", "cpp", "arduino" })
    end,
  },
}
```

Create `~/.config/nvim/lua/plugins/lsp.lua`:

```lua
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
```

---

## 5. Arduino CLI

### Install

```bash
curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | BINDIR=/usr/local/bin sh
```

If SSL issues:

```bash
curl -kfsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | BINDIR=/usr/local/bin sh
```

### Initialize & install cores

```bash
arduino-cli config init
arduino-cli core update-index

# AVR boards (Uno, Mega, Nano)
arduino-cli core install arduino:avr

# ESP32
arduino-cli config add board_manager.additional_urls \
  https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
arduino-cli core update-index
arduino-cli core install esp32:esp32

# ESP8266
arduino-cli config add board_manager.additional_urls \
  https://arduino.esp8266.com/stable/package_esp8266com_index.json
arduino-cli core update-index
arduino-cli core install esp8266:esp8266
```

### Install common libraries

```bash
arduino-cli lib install "Servo"
arduino-cli lib install "WiFi"
arduino-cli lib install "ArduinoJson"
arduino-cli lib install "Adafruit Unified Sensor"
arduino-cli lib install "DHT sensor library"
```

---

## 6. Serial Monitor

### TUI Serial Monitor — tio

```bash
sudo pacman -S tio
```

Usage:

```bash
tio /dev/ttyUSB0 -b 115200
```

`tio` auto-detects ports, supports timestamps, and is fully keyboard-driven. Quit with `Ctrl+t q`.

### WSL2 serial passthrough

WSL2 doesn't natively see USB devices. You need **usbipd-win** on Windows:

```powershell
# In Windows PowerShell (admin)
winget install usbipd

# List USB devices
usbipd list

# Bind and attach your Arduino
usbipd bind --busid <BUSID>
usbipd attach --wsl --busid <BUSID>
```

Then in WSL:

```bash
ls /dev/ttyUSB*   # or /dev/ttyACM*
```

### Add user to dialout group

```bash
sudo usermod -aG uucp $USER   # Arch
sudo usermod -aG dialout $USER  # if needed
```

---

## 7. Git + Lazygit

```bash
sudo pacman -S git lazygit
```

### Git config

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
git config --global init.defaultBranch main
```

### Lazygit Gruvbox

Create `~/.config/lazygit/config.yml`:

```yaml
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
```

### Neovim lazygit keybind

Already included in LazyVim — press `<leader>gg` to open lazygit in a floating terminal.

---

## 8. Project Scaffolding

Create the scaffolding script at `~/.local/bin/arduino-new`:

```bash
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

# Copy board-specific template or default
if [[ -f "$TEMPLATE_DIR/$BOARD.ino" ]]; then
  cp "$TEMPLATE_DIR/$BOARD.ino" "$PROJECT.ino"
else
  cp "$TEMPLATE_DIR/default.ino" "$PROJECT.ino"
fi

# Project-local config
cat > sketch.yaml <<EOF
default_fqbn: $FQBN
default_port: auto
EOF

# clangd compile flags for LSP
cat > .clangd <<EOF
CompileFlags:
  Add:
    - -xc++
    - -std=c++17
    - -I$HOME/.arduino15/packages/arduino/hardware/avr/*/cores/arduino
    - -I$HOME/.arduino15/packages/arduino/hardware/avr/*/variants/standard
    - -I$HOME/.arduino15/packages/arduino/tools/avr-gcc/*/avr/include
EOF

# .gitignore
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
```

### Templates

```bash
mkdir -p ~/.config/archduino/templates
```

Create `~/.config/archduino/templates/default.ino`:

```cpp
void setup() {
  Serial.begin(115200);
  while (!Serial) { ; }
  Serial.println("Hello from Arduino!");
}

void loop() {
  // Your code here
}
```

Create `~/.config/archduino/templates/esp32.ino`:

```cpp
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
  // Your code here
  delay(1000);
}
```

Create `~/.config/archduino/templates/esp8266.ino`:

```cpp
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
  // Your code here
  delay(1000);
}
```

Make it executable and on PATH:

```bash
chmod +x ~/.local/bin/arduino-new
# Ensure ~/.local/bin is in PATH (add to .zshrc if needed)
export PATH="$HOME/.local/bin:$PATH"
```

### Usage

```bash
arduino-new blink-test uno
arduino-new wifi-scanner esp32
```

---

## 9. Zellij Arduino Layout

Create `~/.config/zellij/layouts/arduino.kdl`:

```kdl
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
                    args "-c" "echo 'Run: tio /dev/ttyUSB0 -b 115200'"
                }
            }
        }
    }
    tab name="git" {
        pane {
            command "lazygit"
        }
    }
    tab name="monitor" {
        pane {
            command "bash"
            args "-c" "echo 'Board monitor — run: arduino-cli monitor -p /dev/ttyUSB0 -c baudrate=115200'"
        }
    }
}
```

Launch with:

```bash
zellij --layout arduino
```

Or add a shell alias in `~/.zshrc`:

```bash
alias adev="zellij --layout arduino"
```

---

## 10. Neovim Arduino Keybinds

Create `~/.config/nvim/lua/plugins/arduino-keys.lua`:

```lua
return {
  {
    "folke/which-key.nvim",
    opts = function(_, opts)
      opts.spec = opts.spec or {}
      table.insert(opts.spec, {
        { "<leader>a", group = "Arduino", icon = "⚡" },
      })
    end,
  },
  {
    "stevearc/vim-arduino",
    keys = {
      { "<leader>ac", "<cmd>ArduinoChooseBoard<cr>", desc = "Choose Board" },
      { "<leader>ap", "<cmd>ArduinoChoosePort<cr>", desc = "Choose Port" },
      { "<leader>av", "<cmd>ArduinoVerify<cr>", desc = "Verify (compile)" },
      { "<leader>au", "<cmd>ArduinoUpload<cr>", desc = "Upload" },
      { "<leader>as", "<cmd>ArduinoSerial<cr>", desc = "Serial Monitor" },
      { "<leader>ai", "<cmd>ArduinoInfo<cr>", desc = "Board Info" },
    },
  },
}
```

Quick reference:
- `<leader>av` — compile/verify sketch
- `<leader>au` — upload to board
- `<leader>ac` — pick board
- `<leader>ap` — pick port
- `<leader>as` — open serial monitor
- `<leader>gg` — lazygit (built into LazyVim)

---

## 11. WSL2-Specific Notes

### USB passthrough (required for uploading)

Install on Windows:

```powershell
winget install usbipd
```

Create a helper script at `~/.local/bin/arduino-usb`:

```bash
#!/bin/bash
# Quick attach Arduino USB in WSL2
# Run the Windows-side command via PowerShell interop
powershell.exe -Command "usbipd list"
echo ""
echo "To attach, run in Windows PowerShell:"
echo "  usbipd attach --wsl --busid <BUSID>"
```

### Git SSL workaround (corporate proxies)

```bash
git config --global http.sslVerify false
echo 'insecure' >> ~/.curlrc
```

### Performance tip

Add to `/etc/wsl.conf`:

```ini
[interop]
appendWindowsPath = false

[network]
generateResolvConf = true
```

Disabling `appendWindowsPath` significantly speeds up shell startup.

---

## 12. Quick Reference Card

| Action               | Keybind / Command              |
|----------------------|-------------------------------|
| New project          | `arduino-new <name> <board>`  |
| Open dev workspace   | `adev`                        |
| Compile              | `<leader>av`                  |
| Upload               | `<leader>au`                  |
| Choose board         | `<leader>ac`                  |
| Choose port          | `<leader>ap`                  |
| Serial monitor       | `<leader>as` or `tio`         |
| Lazygit              | `<leader>gg`                  |
| New Zellij pane ↓    | `Alt+n`                       |
| New Zellij pane →    | `Alt+v`                       |
| Navigate panes       | `Alt+h/j/k/l`                 |
| Floating pane        | `Alt+f`                       |
| New tab              | `Alt+t`                       |
