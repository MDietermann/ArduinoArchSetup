#!/bin/bash
THEME_DISPLAY_NAME="Catppuccin Mocha"
NVCHAD_THEME="catppuccin"

write_starship_config() {
  cat >"$1" <<'TOML'
palette = "catppuccin_mocha"
format = """$directory$git_branch$git_status$character"""

[directory]
style = "bold fg:bright-yellow"
truncation_length = 3

[git_branch]
style = "bold fg:bright-green"
format = " [$branch]($style) "

[git_status]
style = "bold fg:bright-red"

[character]
success_symbol = "[❯](bold fg:bright-green)"
error_symbol = "[❯](bold fg:bright-red)"

[palettes.catppuccin_mocha]
bright-yellow = "#f9e2af"
bright-green = "#a6e3a1"
bright-red = "#f38ba8"
bright-blue = "#89b4fa"
bright-purple = "#cba6f7"
bright-aqua = "#94e2d5"
bright-orange = "#fab387"
TOML
}

write_zellij_config() {
  cat >"$1" <<'KDL'
theme "catppuccin-mocha"
default_layout "default"
default_mode "normal"
pane_frames false
simplified_ui true
mouse_mode false

keybinds {
    shared {
        bind "Alt h" { MoveFocusOrTab "Left"; }
        bind "Alt l" { MoveFocusOrTab "Right"; }
        bind "Alt j" { MoveFocus "Down"; }
        bind "Alt k" { MoveFocus "Up"; }
        bind "Alt n" { NewPane "Down"; }
        bind "Alt v" { NewPane "Right"; }
        bind "Alt f" { ToggleFloatingPanes; }
        bind "Alt t" { NewTab; }
    }
}

themes {
    catppuccin-mocha {
        fg "#cdd6f4"
        bg "#1e1e2e"
        black "#181825"
        red "#f38ba8"
        green "#a6e3a1"
        yellow "#f9e2af"
        blue "#89b4fa"
        magenta "#cba6f7"
        cyan "#94e2d5"
        white "#bac2de"
        orange "#fab387"
    }
}
KDL
}

write_lazygit_config() {
  cat >"$1" <<'YAML'
gui:
  theme:
    activeBorderColor:
      - "#f9e2af"
      - bold
    inactiveBorderColor:
      - "#585b70"
    selectedLineBgColor:
      - "#313244"
    cherryPickedCommitFgColor:
      - "#a6e3a1"
    defaultFgColor:
      - "#cdd6f4"
YAML
}
