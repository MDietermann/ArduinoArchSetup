#!/bin/bash
# Step 8: Git + Lazygit

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
write_lazygit_config ~/.config/lazygit/config.yml
info "Lazygit configured with $THEME_DISPLAY_NAME"
