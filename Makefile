SHELL := /bin/bash
DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
UNAME_S := $(shell uname -s)

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

all: os-info check-brew common-packages-install link add-aliases

update: brew-update common-packages-install link add-aliases

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
	stow --verbose --no-folding --target=$$HOME --dir=$(DIR) --restow home

add-aliases:
	@if [ -f "$(DIR)/aliases.txt" ]; then \
	  echo "Agregando aliases desde aliases.txt..."; \
	  for rc_file in $$HOME/.bashrc $$HOME/.zshrc; do \
	    [ ! -f "$$rc_file" ] && touch "$$rc_file"; \
	    added=0; \
	    while IFS= read -r line || [ -n "$$line" ]; do \
	      [ -z "$$line" ] && continue; \
	      if ! grep -qxF "$$line" "$$rc_file" 2>/dev/null; then \
	        echo "$$line" >> "$$rc_file"; \
	        added=$$((added + 1)); \
	      fi; \
	    done < "$(DIR)/aliases.txt"; \
	    if [ $$added -gt 0 ]; then \
	      echo "✓ Agregadas $$added líneas a $$rc_file"; \
	    else \
	      echo "✓ Todos los aliases ya existen en $$rc_file"; \
	    fi; \
	  done; \
	else \
	  echo "Archivo aliases.txt no encontrado en $(DIR)"; \
	fi
