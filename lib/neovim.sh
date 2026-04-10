#!/bin/bash
# Steps 5+6: Neovim + NvChad

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

step "6/9 — Setting up NvChad"

NVIM_CFG="$HOME/.config/nvim"
NVCHAD_FRESH=false

# ── Detect existing config ──────────────────────────────────────
if [[ -d "$NVIM_CFG/lua" ]]; then
  if [[ -f "$NVIM_CFG/lua/chadrc.lua" ]]; then
    # NvChad detected — update in place
    info "Existing NvChad config detected, updating..."
  elif grep -rq "LazyVim" "$NVIM_CFG/lua/" 2>/dev/null || [[ -f "$NVIM_CFG/lazyvim.json" ]]; then
    # LazyVim detected — migrate to NvChad
    warn "LazyVim config detected, migrating to NvChad..."
    for d in "$NVIM_CFG" ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim; do
      if [[ -d "$d" ]]; then
        backup_config "$d"
        rm -rf "$d"
      fi
    done
    NVCHAD_FRESH=true
  else
    # Unknown config — back up and install fresh
    warn "Unknown Neovim config detected, backing up..."
    for d in "$NVIM_CFG" ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim; do
      if [[ -d "$d" ]]; then
        backup_config "$d"
        rm -rf "$d"
      fi
    done
    NVCHAD_FRESH=true
  fi
else
  # No config at all — fresh install
  NVCHAD_FRESH=true
fi

if $NVCHAD_FRESH; then
  git clone https://github.com/NvChad/starter "$NVIM_CFG"
  rm -rf "$NVIM_CFG/.git"
  info "NvChad starter cloned"
fi

# ── Clear NvChad theme cache so the new theme takes effect ──────
rm -rf ~/.local/share/nvim/lazy/base46/lua/base46/themes 2>/dev/null || true
rm -rf ~/.cache/nvim/base46 2>/dev/null || true

# ── Theme ───────────────────────────────────────────────────────
mkdir -p "$NVIM_CFG/lua"

cat >"$NVIM_CFG/lua/chadrc.lua" <<EOF
---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "$NVCHAD_THEME",
}

return M
EOF

# ── Arduino plugin ──────────────────────────────────────────────
mkdir -p "$NVIM_CFG/lua/plugins"

cat >"$NVIM_CFG/lua/plugins/arduino.lua" <<'LUA'
return {
  {
    "stevearc/vim-arduino",
    ft = { "arduino", "cpp", "c" },
    config = function()
      vim.g.arduino_use_cli = 1
      vim.g.arduino_cli_path = "arduino-cli"
    end,
  },
}
LUA

# ── LSP (clangd) ───────────────────────────────────────────────
mkdir -p "$NVIM_CFG/lua/configs"

cat >"$NVIM_CFG/lua/configs/lspconfig.lua" <<'LUA'
local configs = require "nvchad.configs.lspconfig"

local on_attach = configs.on_attach
local on_init = configs.on_init
local capabilities = configs.capabilities

local lspconfig = require "lspconfig"

lspconfig.clangd.setup {
  on_init = on_init,
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
  },
}
LUA

# ── Keymaps ─────────────────────────────────────────────────────
cat >"$NVIM_CFG/lua/mappings.lua" <<'LUA'
require "nvchad.mappings"

local map = vim.keymap.set

map("n", "<leader>ac", "<cmd>ArduinoChooseBoard<cr>", { desc = "Arduino Choose Board" })
map("n", "<leader>ap", "<cmd>ArduinoChoosePort<cr>", { desc = "Arduino Choose Port" })
map("n", "<leader>av", "<cmd>ArduinoVerify<cr>", { desc = "Arduino Verify (compile)" })
map("n", "<leader>au", "<cmd>ArduinoUpload<cr>", { desc = "Arduino Upload" })
map("n", "<leader>as", "<cmd>ArduinoSerial<cr>", { desc = "Arduino Serial Monitor" })
map("n", "<leader>ai", "<cmd>ArduinoInfo<cr>", { desc = "Arduino Board Info" })
LUA

info "NvChad configured ($THEME_DISPLAY_NAME + Arduino + LSP)"
