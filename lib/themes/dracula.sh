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

write_yazi_config() {
  cat >"$1" <<'TOML'
[manager]
cwd = { fg = "#f1fa8c" }
tab_active = { fg = "#282a36", bg = "#f1fa8c" }
tab_inactive = { fg = "#bfbfbf", bg = "#44475a" }
border_symbol = "│"
border_style = { fg = "#6272a4" }
count_copied = { fg = "#282a36", bg = "#50fa7b" }
count_cut = { fg = "#282a36", bg = "#ff5555" }
count_selected = { fg = "#282a36", bg = "#f1fa8c" }

[status]
separator_open = ""
separator_close = ""
mode_normal = { fg = "#282a36", bg = "#50fa7b", bold = true }
mode_select = { fg = "#282a36", bg = "#f1fa8c", bold = true }
mode_unset = { fg = "#282a36", bg = "#ff5555", bold = true }
progress_label = { fg = "#f8f8f2", bold = true }
progress_normal = { fg = "#bd93f9", bg = "#44475a" }
progress_error = { fg = "#ff5555", bg = "#44475a" }

[input]
border = { fg = "#f1fa8c" }
title = {}
value = {}
selected = { reversed = true }

[select]
border = { fg = "#f1fa8c" }
active = { fg = "#50fa7b", bold = true }
inactive = {}
TOML
}
