SHELL := /bin/bash
DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
UNAME_S := $(shell uname -s)
BREW_PREFIX := $(shell test -x /home/linuxbrew/.linuxbrew/bin/brew && echo "/home/linuxbrew/.linuxbrew" || echo "$$HOME/.linuxbrew")

COMMON_PACKAGES := stow lazygit lazydocker lsd bat btop

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


all: os-info brew-install common-packages-install link

update: brew-update common-packages-install link

brew-install:
ifeq ($(OS),macos)
	@if ! command -v brew >/dev/null 2>&1; then \
	  /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
	else \
	  echo "Homebrew ya instalado."; \
	fi
else
	@if ! command -v brew >/dev/null 2>&1; then \
	  echo "Instalando dependencias básicas..."; \
	  if [ "$(DISTRO)" = "arch" ]; then \
	    sudo pacman -Sy --noconfirm --needed base-devel curl git file; \
	  elif [ "$(DISTRO)" = "ubuntu" ] || [ "$(DISTRO)" = "debian" ]; then \
	    sudo apt update && sudo apt install -y build-essential curl git file; \
	  else \
	    echo "Distro no reconocida."; \
	  fi; \
	  echo "Instalando Homebrew en Linux..."; \
	  /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
	  LINE='eval "$$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'; \
	  grep -qxF "$$LINE" $$HOME/.bashrc 2>/dev/null || echo "$$LINE" >> $$HOME/.bashrc; \
	  grep -qxF "$$LINE" $$HOME/.zshrc 2>/dev/null || echo "$$LINE" >> $$HOME/.zshrc; \
	  $LINE; \

	else \
	  echo "Homebrew ya instalado."; \
	fi
endif


os-info:
	@echo "Detectado OS: $(OS)  DISTRO: $(DISTRO)"
	@if command -v brew >/dev/null 2>&1; then \
	  brew --version | head -n 1; brew --prefix; \
	fi

brew-update:
	@if command -v brew >/dev/null 2>&1; then \
	  brew update && brew upgrade && brew cleanup; \
	else \
	  echo "Homebrew no está instalado. Ejecuta: make brew-install"; \
	fi

common-packages-install:
	brew install $(COMMON_PACKAGES)

link:
	stow --verbose --no-folding --target=$$HOME --dir=$(DIR) --restow home
