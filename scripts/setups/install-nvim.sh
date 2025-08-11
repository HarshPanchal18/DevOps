#!/bin/bash

wget https://github.com/neovim/neovim/releases/download/v0.11.3/nvim-linux-x86_64.appimage
chmod u+x nvim-linux-x86_64.appimage
cp nvim-linux-x86_64.appimage /bin/nvim

rm nvim-linux-x86_64.appimage

echo "Neovim installed successfully. You can run it using the command 'nvim'."

# rm -rfv ~/.local/share/nvim/ ~/.local/state/nvim/ ~/.cache/nvim/ # Uncomment if you want to clear Neovim's local data