#!/bin/bash
THEME_DISPLAY_NAME="Dracula"
NVCHAD_THEME="dracula"

write_starship_config() {
  cat >"$1" <<'TOML'
palette = "dracula"
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

[palettes.dracula]
bright-yellow = "#f1fa8c"
bright-green = "#50fa7b"
bright-red = "#ff5555"
bright-blue = "#bd93f9"
bright-purple = "#ff79c6"
bright-aqua = "#8be9fd"
bright-orange = "#ffb86c"
TOML
}

write_zellij_config() {
  cat >"$1" <<'KDL'
theme "dracula"
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
    dracula {
        fg "#f8f8f2"
        bg "#282a36"
        black "#21222c"
        red "#ff5555"
        green "#50fa7b"
        yellow "#f1fa8c"
        blue "#bd93f9"
        magenta "#ff79c6"
        cyan "#8be9fd"
        white "#bfbfbf"
        orange "#ffb86c"
    }
}
KDL
}

write_lazygit_config() {
  cat >"$1" <<'YAML'
gui:
  theme:
    activeBorderColor:
      - "#f1fa8c"
      - bold
    inactiveBorderColor:
      - "#6272a4"
    selectedLineBgColor:
      - "#44475a"
    cherryPickedCommitFgColor:
      - "#50fa7b"
    defaultFgColor:
      - "#f8f8f2"
YAML
}
