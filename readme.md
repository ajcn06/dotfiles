## Dotfiles config
- Lazygit
- Lazydocker
- zsh
- nvim
- git



## Install stow to manage the file deploy

### Mac OS
```bash
brew install stow
```

### Linux (debian base)
```bash
sudo apt install stow
```

## Apply dotfiles installation
```bash
cd dotfiles
stow .
```

## Install dependencies

### zsh

#### Linux

Installation
```bash
sudo apt install zsh -y
```

Set as default terminal
```bash
chsh -s $(which zsh)
```