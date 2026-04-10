#!/bin/bash
# Shell config (.zshrc) and WSL2 extras

step "Finalizing shell config"

# Append archduino block to .zshrc if not already present
if ! grep -q "ARCHDUINO" ~/.zshrc 2>/dev/null; then
  cat >>~/.zshrc <<'ZSHRC'

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
