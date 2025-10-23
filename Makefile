SHELL := /bin/bash
UNAME_S := $(shell uname -s)
BREW_PREFIX := $(shell test -x /home/linuxbrew/.linuxbrew/bin/brew && echo "/home/linuxbrew/.linuxbrew" || echo "$$HOME/.linuxbrew")

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


all: os-info


.PHONY: brew-install
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
	  elif [ "$(DISTRO)" = "ubuntu" ] || [ "$(DISTRO)" = "debian" ] || [ "$(DISTRO)" = "linuxmint" ]; then \
	    sudo apt update && sudo apt install -y build-essential curl file git; \
	  elif [ "$(DISTRO)" = "fedora" ]; then \
	    sudo dnf install -y @development-tools curl file git; \
	  elif [ "$(DISTRO)" = "rhel" ] || [ "$(DISTRO)" = "centos" ]; then \
	    sudo yum groupinstall -y "Development Tools"; \
	    sudo yum install -y curl file git; \
	  else \
	    echo "Distro no reconocida, instala manualmente las dependencias (curl, git, gcc, make)."; \
	  fi; \
	  echo "Instalando Homebrew en Linux..."; \
	  /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
	else \
	  echo "Homebrew ya instalado."; \
	fi
endif
	@echo "Configurando shell..."
	@if ! command -v brew >/dev/null 2>&1; then \
	  BREW_PATH=$$(brew --prefix); \
	  LINE='eval "$$($$BREW_PATH/bin/brew shellenv)"'; \
	  grep -qxF "$$LINE" $$HOME/.bashrc 2>/dev/null || echo "$$LINE" >> $$HOME/.bashrc; \
	  grep -qxF "$$LINE" $$HOME/.zshrc 2>/dev/null || echo "$$LINE" >> $$HOME/.zshrc; \
	  eval "$$($$BREW_PATH/bin/brew shellenv)"; \
	fi
	@echo "Homebrew instalado correctamente."

.PHONY: os-info
os-info:
	@echo "Detectado OS: $(OS)  DISTRO: $(DISTRO)"
	@if command -v brew >/dev/null 2>&1; then \
	  brew --version | head -n 1; brew --prefix; \
	else \
	  echo "Homebrew no está instalado. Ejecuta: make brew-install"; \
	fi

# ------------------------
# Actualizar Homebrew
# ------------------------
.PHONY: brew-update
brew-update:
	@if command -v brew >/dev/null 2>&1; then \
	  brew update && brew upgrade && brew cleanup; \
	else \
	  echo "Homebrew no está instalado. Ejecuta: make brew-install"; \
	fi
