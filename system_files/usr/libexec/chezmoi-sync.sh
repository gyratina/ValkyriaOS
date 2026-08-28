#!/usr/bin/env bash
set -e

DOTFILES_REPO="https://github.com/gyratina/dotfiles.git"

if ! command -v chezmoi >/dev/null 2>&1; then
  exit 0
fi

# Primo avvio: inizializza e applica dal repository
if [ ! -d "$HOME/.local/share/chezmoi" ]; then
  chezmoi init --apply "$DOTFILES_REPO" || true
else
  # Avvii successivi: sincronizza da GitHub
  chezmoi update --apply || true
fi
