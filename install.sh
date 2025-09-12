#!/bin/bash

DOTFILES_DIR="$HOME/dotfiles"

link() {
    src="$DOTFILES_DIR/$1"
    dest="$HOME/$1"
    mkdir -p "$(dirname "$dest")"
    ln -sf "$src" "$dest"
    echo "Linked $src → $dest"
}

link ".config/nvim"
