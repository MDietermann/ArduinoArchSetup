#!/bin/bash
# Step 3: Starship prompt

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
write_starship_config ~/.config/starship.toml
info "Starship configured with $THEME_DISPLAY_NAME"
