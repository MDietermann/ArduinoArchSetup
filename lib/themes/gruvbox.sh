#!/bin/bash
THEME_DISPLAY_NAME="Gruvbox Dark"
NVCHAD_THEME="gruvbox"

write_starship_config() {
  cat >"$1" <<'TOML'
palette = "gruvbox_dark"
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

[palettes.gruvbox_dark]
bright-yellow = "#fabd2f"
bright-green = "#b8bb26"
bright-red = "#fb4934"
bright-blue = "#83a598"
bright-purple = "#d3869b"
bright-aqua = "#8ec07c"
bright-orange = "#fe8019"
TOML
}

write_zellij_config() {
  cat >"$1" <<'KDL'
theme "gruvbox-dark"
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
    gruvbox-dark {
        fg "#ebdbb2"
        bg "#282828"
        black "#1d2021"
        red "#cc241d"
        green "#98971a"
        yellow "#d79921"
        blue "#458588"
        magenta "#b16286"
        cyan "#689d6a"
        white "#a89984"
        orange "#d65d0e"
    }
}
KDL
}

write_lazygit_config() {
  cat >"$1" <<'YAML'
gui:
  theme:
    activeBorderColor:
      - "#fabd2f"
      - bold
    inactiveBorderColor:
      - "#665c54"
    selectedLineBgColor:
      - "#3c3836"
    cherryPickedCommitFgColor:
      - "#b8bb26"
    defaultFgColor:
      - "#ebdbb2"
YAML
}
