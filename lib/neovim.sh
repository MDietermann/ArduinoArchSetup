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

if [[ ! -d "$HOME/.config/nvim/lua" ]]; then
  for d in ~/.config/nvim ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim; do
    [[ -d "$d" ]] && mv "$d" "${d}.bak.$(date +%s)"
  done
  git clone https://github.com/NvChad/starter ~/.config/nvim
  rm -rf ~/.config/nvim/.git
  info "NvChad starter cloned"
else
  info "Neovim config already exists, skipping NvChad clone"
fi

# ── Theme ───────────────────────────────────────────────────────
mkdir -p ~/.config/nvim/lua

cat >~/.config/nvim/lua/chadrc.lua <<EOF
---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "$NVCHAD_THEME",
}

return M
EOF

# ── Arduino plugin ──────────────────────────────────────────────
mkdir -p ~/.config/nvim/lua/plugins

cat >~/.config/nvim/lua/plugins/arduino.lua <<'LUA'
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
mkdir -p ~/.config/nvim/lua/configs

cat >~/.config/nvim/lua/configs/lspconfig.lua <<'LUA'
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
cat >~/.config/nvim/lua/mappings.lua <<'LUA'
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
