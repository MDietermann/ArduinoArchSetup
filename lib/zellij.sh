#!/bin/bash
# Step 4: Zellij terminal multiplexer

step "4/9 — Installing Zellij"

if $IS_ARCH; then
  $PKG_INSTALL zellij
else
  curl -kL https://github.com/zellij-org/zellij/releases/latest/download/zellij-x86_64-unknown-linux-musl.tar.gz | tar xz -C /tmp
  sudo mv /tmp/zellij /usr/local/bin/
fi
info "Zellij installed/updated"

mkdir -p ~/.config/zellij/layouts
backup_config ~/.config/zellij/config.kdl
write_zellij_config ~/.config/zellij/config.kdl

cat >~/.config/zellij/layouts/arduino.kdl <<'LAYOUT'
layout {
    tab name="code" focus=true {
        pane split_direction="vertical" {
            pane size="65%" {
                command "nvim"
                args "."
            }
            pane split_direction="horizontal" {
                pane size="60%" name="terminal"
                pane size="40%" name="serial" {
                    command "bash"
                    args "-c" "echo '⚡ Serial — run: tio /dev/ttyUSB0 -b 115200'"
                }
            }
        }
    }
    tab name="git" {
        pane {
            command "lazygit"
        }
    }
}
LAYOUT
info "Zellij configured with $THEME_DISPLAY_NAME + Arduino layout"
