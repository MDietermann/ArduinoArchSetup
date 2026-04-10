#!/bin/bash
# Step 3: Starship prompt

step "3/9 — Installing Starship"

if $IS_ARCH; then
  $PKG_INSTALL starship
else
  curl -ksS https://starship.rs/install.sh | sh -s -- -y
fi
info "Starship installed/updated"

mkdir -p ~/.config
backup_config ~/.config/starship.toml
write_starship_config ~/.config/starship.toml
info "Starship configured with $THEME_DISPLAY_NAME"
