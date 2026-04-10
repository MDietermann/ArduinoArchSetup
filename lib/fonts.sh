#!/bin/bash
# Step 2: Nerd Font installation

step "2/11 — Installing Nerd Font"

FONT_DIR="$HOME/.local/share/fonts/NerdFonts"
FONT_NAME="JetBrainsMono"

if fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd"; then
  info "JetBrainsMono Nerd Font already installed"
else
  mkdir -p "$FONT_DIR"
  curl -ksSLo /tmp/JetBrainsMono.tar.xz \
    "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz"
  tar xf /tmp/JetBrainsMono.tar.xz -C "$FONT_DIR"
  rm -f /tmp/JetBrainsMono.tar.xz
  fc-cache -f 2>/dev/null || true
  info "JetBrainsMono Nerd Font installed to $FONT_DIR"
fi

if $IS_WSL; then
  warn "WSL detected: You must also install a Nerd Font on the Windows side."
  warn "Download from: https://www.nerdfonts.com/font-downloads"
  warn "Then set 'JetBrainsMono Nerd Font' in your terminal settings (Windows Terminal, etc.)."
fi
