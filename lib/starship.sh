#!/bin/bash
# Step 3: Starship prompt

step "4/12 — Installing Starship"

if $IS_ARCH; then
  $PKG_INSTALL starship
else
  curl -ksSLo /tmp/starship.tar.gz https://github.com/starship/starship/releases/latest/download/starship-x86_64-unknown-linux-musl.tar.gz
  tar xzf /tmp/starship.tar.gz -C /tmp
  sudo install -m 755 /tmp/starship /usr/local/bin/starship
  rm -f /tmp/starship /tmp/starship.tar.gz
fi
info "Starship installed/updated"

mkdir -p ~/.config
backup_config ~/.config/starship.toml
write_starship_config ~/.config/starship.toml
info "Starship configured with $THEME_DISPLAY_NAME"
