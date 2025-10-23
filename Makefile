SHELL := /bin/bash
DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
UNAME_S := $(shell uname -s)

COMMON_PACKAGES := stow lazygit lazydocker lsd bat btop neovim fastfetch

ifeq ($(UNAME_S),Darwin)
  OS := macos
else
  OS := linux
  ifneq ("$(wildcard /etc/os-release)","")
    DISTRO := $(shell . /etc/os-release && echo $$ID)
  else
    DISTRO := unknown
  endif
endif

all: os-info check-brew common-packages-install add-aliases link

update: brew-update common-packages-install add-aliases link

check-brew:
	@if ! command -v brew >/dev/null 2>&1; then \
	  echo "Error: Homebrew is not installed."; \
	  echo "Please run ./install.sh first to install Homebrew."; \
	  exit 1; \
	fi

os-info:
	@echo "Detectado OS: $(OS)  DISTRO: $(DISTRO)"
	@if command -v brew >/dev/null 2>&1; then \
	  brew --version | head -n 1; brew --prefix; \
	fi

brew-update:
	@if command -v brew >/dev/null 2>&1; then \
	  brew update && brew upgrade && brew cleanup; \
	else \
	  echo "Homebrew no está instalado. Ejecuta: ./install.sh"; \
	  exit 1; \
	fi

common-packages-install:
	brew install $(COMMON_PACKAGES)

link:
	stow --no-folding --target=$$HOME --dir=$(DIR) --restow home

add-aliases:
	@for rc_file in $$HOME/.bashrc $$HOME/.zshrc; do \
	  [ ! -f "$$rc_file" ] && touch "$$rc_file"; \
	  include_block="if [ -f \$${HOME}/.bash_aliases ]; then  . \$${HOME}/.bash_aliases; fi"; \
	  if grep -q '.bash_aliases' "$$rc_file" 2>/dev/null; then \
	    echo "✓ $$rc_file already sources .bash_aliases"; \
	  else \
	    printf "\n%s\n" "$$include_block" >> "$$rc_file"; \
	    echo "→ Added .bash_aliases include block to $$rc_file"; \
	  fi; \
	done
