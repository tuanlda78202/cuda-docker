#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log() {
    local level=$1
    shift
    local message=$@
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    case $level in
    "INFO")
        echo -e "${GREEN}[INFO]${NC} ${timestamp} - $message"
        ;;
    "WARN")
        echo -e "${YELLOW}[WARN]${NC} ${timestamp} - $message"
        ;;
    "ERROR")
        echo -e "${RED}[ERROR]${NC} ${timestamp} - $message"
        ;;
    esac
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install required packages
install_dependencies() {
    log "INFO" "Installing dependencies..."
    if command_exists apt-get; then
        sudo apt-get update
        sudo apt-get install -y zsh git curl wget tmux
    elif command_exists yum; then
        sudo yum update
        sudo yum install -y zsh git curl wget tmux
    elif command_exists pacman; then
        sudo pacman -Syu
        sudo pacman -S --noconfirm zsh git curl wget tmux
    else
        log "ERROR" "No supported package manager found. Please install dependencies manually."
        exit 1
    fi
}

# Install Oh My Zsh
install_oh_my_zsh() {
    log "INFO" "Installing Oh My Zsh..."
    if [ -d "$HOME/.oh-my-zsh" ]; then
        log "WARN" "Oh My Zsh is already installed. Skipping..."
    else
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
}

# Install Powerlevel10k
install_p10k() {
    log "INFO" "Installing Powerlevel10k..."
    local p10k_path="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    if [ -d "$p10k_path" ]; then
        log "WARN" "Powerlevel10k is already installed. Skipping..."
    else
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_path"
    fi
}

# Install ZSH plugins
install_plugins() {
    log "INFO" "Installing ZSH plugins..."
    local plugins_path="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"

    # zsh-autosuggestions
    if [ ! -d "$plugins_path/zsh-autosuggestions" ]; then
        git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions "$plugins_path/zsh-autosuggestions"
    fi

    # fast-syntax-highlighting
    if [ ! -d "$plugins_path/F-Sy-H" ]; then
        git clone --depth 1 https://github.com/z-shell/F-Sy-H.git "$plugins_path/F-Sy-H"
    fi

    # zsh-completions
    if [ ! -d "$plugins_path/zsh-completions" ]; then
        git clone --depth 1 https://github.com/zsh-users/zsh-completions "$plugins_path/zsh-completions"
    fi

    # zsh-history-substring-search
    if [ ! -d "$plugins_path/zsh-history-substring-search" ]; then
        git clone --depth 1 https://github.com/zsh-users/zsh-history-substring-search "$plugins_path/zsh-history-substring-search"
    fi
}

# Install UV
install_uv() {
    log "INFO" "Installing UV..."
    if curl -LsSf https://astral.sh/uv/install.sh | sh; then
        log "INFO" "UV installed successfully."
    else
        log "ERROR" "Failed to install UV."
        exit 1
    fi
}

# Create or update .zshrc
setup_zshrc() {
    log "INFO" "Setting up .zshrc..."
    local zshrc="$HOME/.zshrc"

    # Backup existing .zshrc if it exists
    if [ -f "$zshrc" ]; then
        cp "$zshrc" "$zshrc.backup.$(date +%Y%m%d_%H%M%S)"
        log "INFO" "Existing .zshrc backed up to $zshrc.backup.$(date +%Y%m%d_%H%M%S)"
    fi

    # Create new .zshrc
    cat >"$zshrc" <<'EOF'
# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Set theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Configure plugins
plugins=(
    git
    zsh-autosuggestions
    F-Sy-H
    zsh-completions
    zsh-history-substring-search
)

# Source oh-my-zsh
source $ZSH/oh-my-zsh.sh

# Load completions
autoload -U compinit && compinit

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Custom aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'

# Configure history
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

# UV
if command -v uv &> /dev/null; then
    eval "$(uv generate-shell-completion zsh)"
fi
EOF
}

# Set ZSH as default shell
set_zsh_default() {
    log "INFO" "Setting ZSH as default shell..."
    if [ "$SHELL" != "$(which zsh)" ]; then
        chsh -s $(which zsh)
        log "INFO" "Default shell changed to ZSH. Please log out and log back in for changes to take effect."
    else
        log "WARN" "ZSH is already the default shell."
    fi
}

# Main function
main() {
    log "INFO" "Starting ZSH setup..."

    install_dependencies
    install_oh_my_zsh
    install_p10k
    install_plugins
    install_uv
    setup_zshrc
    set_zsh_default

    log "INFO" "Setup completed successfully!"
    log "INFO" "Please log out and log back in to start using ZSH."
    log "INFO" "After logging back in, run 'p10k configure' to set up your Powerlevel10k theme."
}

# Run main function
main
