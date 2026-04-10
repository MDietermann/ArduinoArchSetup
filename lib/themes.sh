#!/bin/bash
# Theme selection — sources the chosen theme file

THEMES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/themes"

THEME_FILES=(gruvbox catppuccin tokyonight nord dracula)

select_theme() {
  echo "  Select colorscheme:"
  echo ""

  local i=1
  for t in "${THEME_FILES[@]}"; do
    source "$THEMES_DIR/$t.sh"
    printf "    %d) %s\n" "$i" "$THEME_DISPLAY_NAME"
    i=$((i + 1))
  done

  echo ""
  read -rp "  Choice [1-${#THEME_FILES[@]}]: " theme_choice

  # Default to 1 (Gruvbox) for invalid input
  if [[ ! "$theme_choice" =~ ^[0-9]+$ ]] || ((theme_choice < 1 || theme_choice > ${#THEME_FILES[@]})); then
    theme_choice=1
  fi

  local selected="${THEME_FILES[$((theme_choice - 1))]}"
  source "$THEMES_DIR/$selected.sh"
  info "Selected theme: $THEME_DISPLAY_NAME"
}
