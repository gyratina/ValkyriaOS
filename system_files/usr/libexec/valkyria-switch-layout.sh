#!/usr/bin/env bash
direction="${1:-next}"
niri msg action switch-layout "$direction"

# Ottiene il nome del layout attivo
active_layout=$(niri msg -j keyboard-layouts 2>/dev/null | jq -r '.names[.current_idx]' 2>/dev/null || true)
if [ -z "$active_layout" ] || [ "$active_layout" = "null" ]; then
  active_layout=$(niri msg keyboard-layouts 2>/dev/null | grep -E "^\*" | sed 's/^\* //' || true)
fi

notify-send -t 1200 -a "ValkyriaOS" -h string:x-canonical-private-synchronous:keyboard-layout -i input-keyboard "Layout Tastiera" "${active_layout:-Tastiera commutata}" 2>/dev/null || true
