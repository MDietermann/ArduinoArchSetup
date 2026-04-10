<p align="center">
  <br>
  <strong>⚡ Archduino</strong>
  <br>
  <em>A full TUI-based Arduino development environment — one script, zero friction.</em>
  <br><br>
  <a href="#-quickstart"><img src="https://img.shields.io/badge/-Get%20Started-b8bb26?style=for-the-badge&logo=gnubash&logoColor=282828" alt="Get Started"></a>
  <img src="https://img.shields.io/badge/Arch%20Linux-1793D1?style=for-the-badge&logo=archlinux&logoColor=white" alt="Arch Linux">
  <img src="https://img.shields.io/badge/Ubuntu%20WSL2-E95420?style=for-the-badge&logo=ubuntu&logoColor=white" alt="Ubuntu WSL2">
  <img src="https://img.shields.io/badge/shell-bash-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white" alt="Bash">
</p>

---

Archduino bootstraps a **complete terminal-based Arduino IDE** on Arch Linux or Ubuntu (including WSL2). It installs, configures, and wires together a curated set of modern CLI tools — with a **unified colorscheme of your choice** — so you can go from a bare system to compiling and uploading sketches in minutes.

The Idea was a Development Environment runnable by almost everything. No GUI needed! This is tested on a minimal Arch install without a Desktop Environment!

```
  ╔═══════════════════════════════════════╗
  ║       ⚡ Archduino Bootstrap ⚡      ║
  ║  TUI Arduino Dev Environment Setup    ║
  ╚═══════════════════════════════════════╝
```

## ✨ What You Get

| Layer | Tool | Purpose |
|---|---|---|
| **Editor** | [Neovim](https://neovim.io) + [NvChad](https://nvchad.com) | Fully configured IDE with LSP, Treesitter, and fuzzy finding |
| **Arduino** | [arduino-cli](https://arduino.github.io/arduino-cli) + [vim-arduino](https://github.com/stevearc/vim-arduino) | Compile, upload, and monitor directly from Neovim |
| **Multiplexer** | [Zellij](https://zellij.dev) | Tiled workspace with a custom Arduino layout |
| **Shell** | [Zsh](https://www.zsh.org) + [Oh My Zsh](https://ohmyz.sh) | Autosuggestions, syntax highlighting, smart completions |
| **Prompt** | [Starship](https://starship.rs) | Fast, minimal, git-aware prompt |
| **Git** | [Lazygit](https://github.com/jesseduffield/lazygit) | Beautiful terminal UI for git |
| **File Manager** | [Yazi](https://yazi-rs.github.io) | Blazing fast terminal file manager with image preview |
| **Serial** | [tio](https://github.com/tio/tio) | Simple serial device I/O |
| **Font** | [JetBrainsMono Nerd Font](https://www.nerdfonts.com) | Icons and ligatures for all TUI tools |
| **Theme** | 5 colorschemes | Consistent look across every tool (see below) |

### Colorschemes

The installer lets you pick a theme that is applied **consistently** across Neovim, Starship, Zellij, Lazygit, and Yazi:

| # | Theme | Style |
|---|---|---|
| 1 | **Gruvbox Dark** | Warm retro browns and yellows |
| 2 | **Catppuccin Mocha** | Soft pastel on dark base |
| 3 | **Tokyo Night** | Cool blues and purples |
| 4 | **Nord** | Arctic, muted blue-grey |
| 5 | **Dracula** | High-contrast purple and green |

You can **switch themes at any time** after installation:

```bash
archduino-theme    # or just: theme
```

This updates Starship, Zellij, Lazygit, Yazi, and NvChad in one step.

### Supported Boards (out of the box)

| Board | FQBN |
|---|---|
| Arduino Uno | `arduino:avr:uno` |
| Arduino Mega | `arduino:avr:mega` |
| Arduino Nano | `arduino:avr:nano` |
| ESP32 | `esp32:esp32:esp32` |
| ESP32-S3 | `esp32:esp32:esp32s3` |
| ESP8266 (NodeMCU) | `esp8266:esp8266:nodemcuv2` |

---

## 🚀 Quickstart

```bash
git clone --depth=1 https://github.com/<your-username>/ArduinoArch.git
cd ArduinoArch
chmod +x install.sh
./install.sh
```

The installer will:

1. Show a banner with detected OS and package manager
2. Let you pick your **colorscheme** (applied to all tools)
3. Let you choose between **progress bar** or **verbose** output
4. Ask for your sudo password **once** (cached for the entire install)
5. Run through all 11 setup steps automatically

After it finishes, start a new shell or run `source ~/.zshrc`.

---

## 📁 Project Structure

```
ArduinoArch/
├── install.sh              # Main entry point
└── lib/
    ├── common.sh           # Colors, helpers, environment detection, progress bar
    ├── themes.sh           # Colorscheme selection menu
    ├── themes/
    │   ├── gruvbox.sh      # Gruvbox Dark configs
    │   ├── catppuccin.sh   # Catppuccin Mocha configs
    │   ├── tokyonight.sh   # Tokyo Night configs
    │   ├── nord.sh         # Nord configs
    │   └── dracula.sh      # Dracula configs
    ├── packages.sh         # Base packages (build tools, ripgrep, fd, bat, etc.)
    ├── fonts.sh            # JetBrainsMono Nerd Font installation
    ├── zsh.sh              # Oh My Zsh + plugins
    ├── starship.sh         # Starship prompt config
    ├── zellij.sh           # Zellij + config + Arduino workspace layout
    ├── neovim.sh           # Neovim + NvChad + plugin configs (Arduino, LSP)
    ├── yazi.sh             # Yazi file manager + themed config
    ├── arduino.sh          # Arduino CLI + AVR/ESP32/ESP8266 cores + common libraries
    ├── git.sh              # Lazygit config
    ├── scaffold.sh         # `arduino-new` scaffolding tool + board templates
    └── shell-config.sh     # .zshrc aliases/config + WSL2 extras
```

---

## 🔧 Usage

### Creating a New Project

```bash
arduino-new my-project uno
cd my-project
nvim my-project.ino
```

This scaffolds a ready-to-go project with:
- Board-specific `.ino` template (WiFi-enabled for ESP boards)
- `sketch.yaml` with your board's FQBN
- `.clangd` config for C++17 intellisense
- `.gitignore` for build artifacts
- Initialized git repo

### Launching the Arduino Workspace

```bash
adev
```

Opens Zellij with the custom Arduino layout:

```
┌──────────────────────┬─────────────────┐
│                      │                 │
│    Neovim (65%)      │   Terminal      │
│                      │                 │
│                      ├─────────────────┤
│                      │   Serial Mon    │
│                      │                 │
├──────────────────────┴─────────────────┤
│  Tab: code (focused) │   Tab: git      │
└────────────────────────────────────────┘
```

### Neovim Keybindings (Arduino)

All keybindings are under `<leader>a`:

| Key | Action |
|---|---|
| `<leader>ac` | Choose board |
| `<leader>ap` | Choose port |
| `<leader>av` | Verify (compile) |
| `<leader>au` | Upload |
| `<leader>as` | Serial monitor |
| `<leader>ai` | Board info |

### Zellij Keybindings

| Key | Action |
|---|---|
| `Alt h/l` | Move focus left/right (or switch tabs) |
| `Alt j/k` | Move focus down/up |
| `Alt n` | New pane below |
| `Alt v` | New pane to the right |
| `Alt f` | Toggle floating panes |
| `Alt t` | New tab |

### Shell Aliases

| Alias | Command |
|---|---|
| `adev` | `zellij --layout arduino` |
| `ac` | `arduino-cli` |
| `acc` | `arduino-cli compile` |
| `acu` | `arduino-cli upload` |
| `acm` | `arduino-cli monitor` |
| `acb` | `arduino-cli board list` |
| `lg` | `lazygit` |
| `v` | `nvim` |
| `y` | `yazi` (file manager) |
| `theme` | `archduino-theme` (switch colorscheme) |

---

## 🖥️ WSL2 Notes

Archduino fully supports WSL2 (both Arch and Ubuntu). The installer automatically:

- Detects the WSL2 environment
- Adds your user to the `dialout` and `uucp` groups for serial access

To connect your Arduino over USB you need [usbipd-win](https://github.com/dorssel/usbipd-win) on the Windows side:

```powershell
# On Windows (PowerShell as Admin)
winget install usbipd

# List USB devices
usbipd list

# Attach your Arduino to WSL
usbipd attach --wsl --busid <BUSID>
```

---

## 🤝 Contributing

Contributions are welcome! Each installer step lives in its own file under `lib/`, making it straightforward to modify or extend individual components without touching the rest.

---

## 📄 License

This project is open source. Feel free to use, modify, and distribute.
