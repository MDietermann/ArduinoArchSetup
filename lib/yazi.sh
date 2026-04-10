#!/bin/bash
# Step 8: Yazi file manager

step "8/12 — Installing Yazi"

if $IS_ARCH; then
  $PKG_INSTALL yazi ffmpegthumbnailer p7zip poppler
else
  YAZI_VERSION=$(curl -ks "https://api.github.com/repos/sxyazi/yazi/releases/latest" | jq -r '.tag_name')
  curl -ksSLo /tmp/yazi.zip "https://github.com/sxyazi/yazi/releases/download/${YAZI_VERSION}/yazi-x86_64-unknown-linux-musl.zip"
  unzip -qo /tmp/yazi.zip -d /tmp/yazi-extract
  sudo install -m 755 /tmp/yazi-extract/yazi-x86_64-unknown-linux-musl/yazi /usr/local/bin/yazi
  rm -rf /tmp/yazi.zip /tmp/yazi-extract
  # Optional thumbnailer/preview deps
  sudo apt install -y ffmpegthumbnailer p7zip-full poppler-utils 2>/dev/null || true
fi
info "Yazi installed/updated"

mkdir -p ~/.config/yazi
backup_config ~/.config/yazi/theme.toml
write_yazi_config ~/.config/yazi/theme.toml
info "Yazi configured with $THEME_DISPLAY_NAME"
