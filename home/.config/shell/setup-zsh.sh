#!/usr/bin/env bash

# Make sure dirs exhist




# If .zshrc already exists, remove it.
[[ -f "$HOME/.zshrc" ]] && rm -rf "$HOME/.zshrc"

cat "./setup/.zshrc" >> "$HOME/.zshrc"

