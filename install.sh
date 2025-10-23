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

install_homebrew() {
    echo "Checking for Homebrew..."

    if command -v brew >/dev/null 2>&1; then
        echo "Homebrew is already installed."
        return 0
    fi

    echo "Installing Homebrew..."

    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add Homebrew to PATH for macOS
        if [[ -x "/opt/homebrew/bin/brew" ]]; then
            BREW_PATH="/opt/homebrew"
        else
            BREW_PATH="/usr/local"
        fi

        LINE='eval "$('$BREW_PATH'/bin/brew shellenv)"'
    else
        # Linux
        echo "Installing build dependencies..."
        if [[ -f /etc/os-release ]]; then
            . /etc/os-release
            if [[ "$ID" == "arch" ]]; then
                sudo pacman -Sy --noconfirm --needed base-devel curl git file
            elif [[ "$ID" == "ubuntu" ]] || [[ "$ID" == "debian" ]]; then
                sudo apt update && sudo apt install -y build-essential curl git file
            else
                echo "Unsupported distribution for automatic dependency installation"
            fi
        fi

        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add Homebrew to PATH for Linux
        LINE='eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'
    fi

    # Add to shell configuration files
    for rc_file in "$HOME/.bashrc" "$HOME/.zshrc"; do
        if [[ -f "$rc_file" ]]; then
            if ! grep -qxF "$LINE" "$rc_file" 2>/dev/null; then
                echo "$LINE" >> "$rc_file"
                echo "Added Homebrew to $rc_file"
            fi
        fi
    done

    # Activate Homebrew in current session
    eval "$LINE"

    echo "Homebrew installed successfully!"
}

# Check and install git
if ! command -v git >/dev/null 2>&1; then
    install_package "git"
fi

# Check and install make
if ! command -v make >/dev/null 2>&1; then
    install_package "make"
fi

# Install Homebrew
install_homebrew

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