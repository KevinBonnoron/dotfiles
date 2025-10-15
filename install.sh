#!/usr/bin/env bash

DOTFILES_DIR="${1:-$HOME/dotfiles}"

# Colors for messages
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

check_dotfiles_directory() {
    if [ ! -d "$DOTFILES_DIR" ]; then
        print_error "The dotfiles directory does not exist: $DOTFILES_DIR"
        exit 1
    fi
}

check_git_installed() {
    if ! command -v git &> /dev/null; then
        print_error "Git is not installed."
        exit 1
    fi
}

install_git_config() {
    print_info "Installing Git configuration..."

    local git_config_dest="$HOME/.gitconfig"
    local git_config_source="$DOTFILES_DIR/.gitconfig"

    if [ -f "$git_config_dest" ]; then
        if grep -q "path = $git_config_source" "$git_config_dest"; then
            print_info "Include already present in $git_config_dest"
        else
            print_info "Git configuration detected. Adding include..."

            {
                echo ""
                echo "[include]"
                echo "    path = $git_config_source"
                echo ""
                cat "$git_config_dest"
            } > "$git_config_dest.tmp"

            mv "$git_config_dest.tmp" "$git_config_dest"
            print_success "Include added to $git_config_dest"
        fi
    else
        print_info "No Git configuration found. Creating a new .gitconfig..."

        cat > "$git_config_dest" << EOF
[include]
    path = $git_config_source
EOF

        print_success "New .gitconfig created at $git_config_dest"
    fi
}

main() {
    echo "🚀 Installing dotfiles..."
    echo "📁 Dotfiles directory: $DOTFILES_DIR"
    echo ""

    check_dotfiles_directory
    check_git_installed
    install_git_config

    echo ""
    print_success "Installation completed!"
}

main "$@"
