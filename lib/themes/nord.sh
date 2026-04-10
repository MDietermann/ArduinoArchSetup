#!/bin/bash
THEME_DISPLAY_NAME="Nord"
NVCHAD_THEME="nord"

write_starship_config() {
  cat >"$1" <<'TOML'
palette = "nord"
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

[palettes.nord]
bright-yellow = "#ebcb8b"
bright-green = "#a3be8c"
bright-red = "#bf616a"
bright-blue = "#81a1c1"
bright-purple = "#b48ead"
bright-aqua = "#88c0d0"
bright-orange = "#d08770"
TOML
}

write_zellij_config() {
  cat >"$1" <<'KDL'
theme "nord"
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
    nord {
        fg "#d8dee9"
        bg "#2e3440"
        black "#3b4252"
        red "#bf616a"
        green "#a3be8c"
        yellow "#ebcb8b"
        blue "#81a1c1"
        magenta "#b48ead"
        cyan "#88c0d0"
        white "#e5e9f0"
        orange "#d08770"
    }
}
KDL
}

write_lazygit_config() {
  cat >"$1" <<'YAML'
gui:
  theme:
    activeBorderColor:
      - "#ebcb8b"
      - bold
    inactiveBorderColor:
      - "#4c566a"
    selectedLineBgColor:
      - "#3b4252"
    cherryPickedCommitFgColor:
      - "#a3be8c"
    defaultFgColor:
      - "#d8dee9"
YAML
}

write_yazi_config() {
  cat >"$1" <<'TOML'
[manager]
cwd = { fg = "#ebcb8b" }
tab_active = { fg = "#2e3440", bg = "#ebcb8b" }
tab_inactive = { fg = "#e5e9f0", bg = "#3b4252" }
border_symbol = "│"
border_style = { fg = "#4c566a" }
count_copied = { fg = "#2e3440", bg = "#a3be8c" }
count_cut = { fg = "#2e3440", bg = "#bf616a" }
count_selected = { fg = "#2e3440", bg = "#ebcb8b" }

[status]
separator_open = ""
separator_close = ""
mode_normal = { fg = "#2e3440", bg = "#a3be8c", bold = true }
mode_select = { fg = "#2e3440", bg = "#ebcb8b", bold = true }
mode_unset = { fg = "#2e3440", bg = "#bf616a", bold = true }
progress_label = { fg = "#d8dee9", bold = true }
progress_normal = { fg = "#81a1c1", bg = "#3b4252" }
progress_error = { fg = "#bf616a", bg = "#3b4252" }

[input]
border = { fg = "#ebcb8b" }
title = {}
value = {}
selected = { reversed = true }

[select]
border = { fg = "#ebcb8b" }
active = { fg = "#a3be8c", bold = true }
inactive = {}
TOML
}
