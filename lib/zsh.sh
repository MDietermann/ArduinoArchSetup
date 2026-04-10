#!/bin/bash
# Step 2: Zsh + Oh My Zsh + plugins

step "2/9 — Setting up Zsh"

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  RUNZSH=no KEEP_ZSHRC=yes CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended ||
    RUNZSH=no KEEP_ZSHRC=yes CHSH=no sh -c "$(curl -kfsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  info "Oh My Zsh installed"
else
  info "Oh My Zsh already present"
fi

# Set zsh as default shell if it isn't already
if [[ "$(basename "$SHELL")" != "zsh" ]]; then
  sudo chsh -s "$(command -v zsh)" "$USER" 2>/dev/null || true
  info "Default shell changed to zsh"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
  if [[ ! -d "$ZSH_CUSTOM/plugins/$plugin" ]]; then
    git clone "https://github.com/zsh-users/$plugin" "$ZSH_CUSTOM/plugins/$plugin"
  else
    git -C "$ZSH_CUSTOM/plugins/$plugin" pull --quiet 2>/dev/null || true
  fi
done

info "Zsh plugins installed/updated"
