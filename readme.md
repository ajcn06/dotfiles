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