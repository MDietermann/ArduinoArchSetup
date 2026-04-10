#!/bin/bash
THEME_DISPLAY_NAME="Tokyo Night"
NVCHAD_THEME="tokyonight"

write_starship_config() {
  cat >"$1" <<'TOML'
palette = "tokyonight"
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

[palettes.tokyonight]
bright-yellow = "#e0af68"
bright-green = "#9ece6a"
bright-red = "#f7768e"
bright-blue = "#7aa2f7"
bright-purple = "#bb9af7"
bright-aqua = "#7dcfff"
bright-orange = "#ff9e64"
TOML
}

write_zellij_config() {
  cat >"$1" <<'KDL'
theme "tokyonight"
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
    tokyonight {
        fg "#c0caf5"
        bg "#1a1b26"
        black "#15161e"
        red "#f7768e"
        green "#9ece6a"
        yellow "#e0af68"
        blue "#7aa2f7"
        magenta "#bb9af7"
        cyan "#7dcfff"
        white "#a9b1d6"
        orange "#ff9e64"
    }
}
KDL
}

write_lazygit_config() {
  cat >"$1" <<'YAML'
gui:
  theme:
    activeBorderColor:
      - "#e0af68"
      - bold
    inactiveBorderColor:
      - "#3b4261"
    selectedLineBgColor:
      - "#283457"
    cherryPickedCommitFgColor:
      - "#9ece6a"
    defaultFgColor:
      - "#c0caf5"
YAML
}
