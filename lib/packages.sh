#!/bin/bash
# Step 1: Base packages

step "1/9 — Installing base packages"

if $IS_ARCH; then
  sudo pacman -Syu --noconfirm
  $PKG_INSTALL base-devel git curl unzip wget ripgrep fd bat eza tree jq zsh clang
  # tio is in AUR — install yay if needed, then tio
  if ! command -v yay &>/dev/null; then
    info "Installing yay (AUR helper)..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm)
    rm -rf /tmp/yay
  fi
  yay -S --needed --noconfirm tio
else
  sudo apt update && sudo apt upgrade -y
  $PKG_INSTALL build-essential git curl unzip wget ripgrep bat eza tree jq zsh clang-format tio
  # fd is named differently on Ubuntu
  sudo apt install -y fd-find 2>/dev/null || true
fi
info "Base packages installed"
