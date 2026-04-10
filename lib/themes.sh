#!/bin/bash
# Theme selection — sources the chosen theme file

THEMES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/themes"
THEME_SAVE_FILE="$HOME/.config/archduino/theme"

THEME_FILES=(gruvbox catppuccin tokyonight nord dracula)

select_theme() {
  # Load previously saved theme as default
  local saved_theme="" default_idx=1
  if [[ -f "$THEME_SAVE_FILE" ]]; then
    saved_theme=$(cat "$THEME_SAVE_FILE")
    for idx in "${!THEME_FILES[@]}"; do
      if [[ "${THEME_FILES[$idx]}" == "$saved_theme" ]]; then
        default_idx=$((idx + 1))
        break
      fi
    done
  fi

  echo "  Select colorscheme:"
  echo ""

  local i=1
  for t in "${THEME_FILES[@]}"; do
    source "$THEMES_DIR/$t.sh"
    if [[ $i -eq $default_idx && -n "$saved_theme" ]]; then
      printf "    %d) %s (current)\n" "$i" "$THEME_DISPLAY_NAME"
    else
      printf "    %d) %s\n" "$i" "$THEME_DISPLAY_NAME"
    fi
    i=$((i + 1))
  done

  echo ""
  read -rp "  Choice [1-${#THEME_FILES[@]}] (default: $default_idx): " theme_choice

  # Default to saved theme (or Gruvbox) for empty/invalid input
  if [[ -z "$theme_choice" ]]; then
    theme_choice=$default_idx
  elif [[ ! "$theme_choice" =~ ^[0-9]+$ ]] || ((theme_choice < 1 || theme_choice > ${#THEME_FILES[@]})); then
    theme_choice=$default_idx
  fi

  local selected="${THEME_FILES[$((theme_choice - 1))]}"
  source "$THEMES_DIR/$selected.sh"

  # Persist choice for next run
  mkdir -p "$(dirname "$THEME_SAVE_FILE")"
  echo "$selected" > "$THEME_SAVE_FILE"

  info "Selected theme: $THEME_DISPLAY_NAME"
}
