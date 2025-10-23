#!/bin/bash

set -e  # Exit on error

REPO_URL="https://github.com/ajcn06/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"

echo "Starting dotfiles installation..."

install_package() {
    local package_name=$1

    echo "$package_name is not installed. Installing..."

    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        xcode-select --install 2>/dev/null || echo "Command Line Tools already installed"
    elif [[ -f /etc/os-release ]]; then
        . /etc/os-release
        if [[ "$ID" == "arch" ]]; then
            sudo pacman -Sy --noconfirm --needed "$package_name"
        elif [[ "$ID" == "ubuntu" ]] || [[ "$ID" == "debian" ]]; then
            sudo apt update && sudo apt install -y "$package_name"
        elif [[ "$ID" == "fedora" ]]; then
            sudo dnf install -y "$package_name"
        else
            echo "Please install '$package_name' manually for your distribution"
            exit 1
        fi
    fi
}

if ! command -v git >/dev/null 2>&1; then
    install_package "git"
fi

if ! command -v make >/dev/null 2>&1; then
    install_package "make"
fi

# Clone or update the dotfiles repository
if [ -d "$DOTFILES_DIR" ]; then
    echo "Dotfiles directory already exists at $DOTFILES_DIR"
    echo "Pulling latest changes..."
    cd "$DOTFILES_DIR"
    git pull
else
    echo "Cloning dotfiles repository to $DOTFILES_DIR..."
    git clone "$REPO_URL" "$DOTFILES_DIR"
    cd "$DOTFILES_DIR"
fi

# Run the Makefile
echo "Running Makefile..."
make all

echo ""
echo "Installation complete!"
echo "Please restart your shell or run: source ~/.bashrc (or ~/.zshrc)"