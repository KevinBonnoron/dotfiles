#!/usr/bin/env bash

set -e

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

install_tern_config() {
    print_info "Installing Tern configuration..."

    local tern_config_dir
    if [ -n "${TERN_CONFIG_DIR:-}" ]; then
        tern_config_dir="$TERN_CONFIG_DIR"
    elif [ "$(uname -s)" = Darwin ]; then
        tern_config_dir="$HOME/Library/Application Support/Tern"
    else
        tern_config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/tern"
    fi
    local tern_config_dest="$tern_config_dir/settings.json"
    local tern_config_source="$DOTFILES_DIR/tern/settings.json"

    mkdir -p "$tern_config_dir"

    if [ -L "$tern_config_dest" ]; then
        print_info "Symlink already exists at $tern_config_dest"
    elif [ -e "$tern_config_dest" ]; then
        if [ -e "$tern_config_dest.bak" ] || [ -L "$tern_config_dest.bak" ]; then
            print_error "Backup already exists at $tern_config_dest.bak; leaving Tern configuration unchanged"
            return 1
        fi
        print_info "Existing config found. Backing up to $tern_config_dest.bak"
        mv "$tern_config_dest" "$tern_config_dest.bak"
        ln -s "$tern_config_source" "$tern_config_dest"
        print_success "Tern config symlinked (original backed up)"
    else
        ln -s "$tern_config_source" "$tern_config_dest"
        print_success "Tern config symlinked to $tern_config_dest"
    fi
}

install_zed_config() {
    print_info "Installing Zed configuration..."

    # Whole directory, so files Zed rewrites or creates stay in the repository.
    local zed_config_dest
    if [ "$(uname -s)" = Darwin ]; then
        zed_config_dest="$HOME/.config/zed"
    else
        zed_config_dest="${XDG_CONFIG_HOME:-$HOME/.config}/zed"
    fi
    local zed_config_source="$DOTFILES_DIR/zed"

    mkdir -p "$(dirname "$zed_config_dest")"

    if [ -L "$zed_config_dest" ]; then
        print_info "Symlink already exists at $zed_config_dest"
    elif [ -e "$zed_config_dest" ]; then
        if [ -e "$zed_config_dest.bak" ] || [ -L "$zed_config_dest.bak" ]; then
            print_error "Backup already exists at $zed_config_dest.bak; leaving Zed configuration unchanged"
            return 1
        fi
        print_info "Existing config found. Backing up to $zed_config_dest.bak"
        mv "$zed_config_dest" "$zed_config_dest.bak"
        ln -s "$zed_config_source" "$zed_config_dest"
        print_success "Zed config symlinked (original backed up)"
    else
        ln -s "$zed_config_source" "$zed_config_dest"
        print_success "Zed config symlinked to $zed_config_dest"
    fi
}

# Prints the directory of the default Zen profile, or nothing if Zen never ran.
find_zen_profile() {
    local zen_dirs zen_dir profile
    if [ "$(uname -s)" = Darwin ]; then
        zen_dirs=("$HOME/Library/Application Support/zen")
    else
        zen_dirs=("${XDG_CONFIG_HOME:-$HOME/.config}/zen" "$HOME/.zen")
    fi

    for zen_dir in "${zen_dirs[@]}"; do
        [ -f "$zen_dir/profiles.ini" ] || continue
        # The profile bound to the install ([Install*] Default=) wins over Default=1.
        profile=$(awk '
            /^\[/ { section = $0; path = ""; is_default = 0; next }
            { key = substr($0, 1, index($0, "=") - 1); value = substr($0, index($0, "=") + 1) }
            section ~ /^\[Install/ && key == "Default" && install_default == "" { install_default = value }
            section ~ /^\[Profile/ && key == "Path" { path = value }
            section ~ /^\[Profile/ && key == "Default" && value == "1" { is_default = 1 }
            section ~ /^\[Profile/ && path != "" && is_default && default_profile == "" { default_profile = path }
            END { print (install_default != "" ? install_default : default_profile) }
        ' "$zen_dir/profiles.ini")
        [ -n "$profile" ] || continue
        case "$profile" in
            /*) echo "$profile" ;;
            *) echo "$zen_dir/$profile" ;;
        esac
        return
    done
}

install_zen_config() {
    print_info "Installing Zen configuration..."

    local profile_dir
    profile_dir=$(find_zen_profile)
    if [ -z "$profile_dir" ] || [ ! -d "$profile_dir" ]; then
        print_info "No Zen profile found (start Zen once first), skipping."
        return
    fi

    local file src dest
    for file in user.js zen-keyboard-shortcuts.json; do
        src="$DOTFILES_DIR/zen/$file"
        dest="$profile_dir/$file"

        if [ -L "$dest" ]; then
            print_info "Symlink already exists at $dest"
        elif [ -e "$dest" ]; then
            if [ -e "$dest.bak" ] || [ -L "$dest.bak" ]; then
                print_error "Backup already exists at $dest.bak; leaving Zen $file unchanged"
                return 1
            fi
            print_info "Existing $file found. Backing up to $dest.bak"
            mv "$dest" "$dest.bak"
            ln -s "$src" "$dest"
            print_success "Zen $file symlinked (original backed up)"
        else
            ln -s "$src" "$dest"
            print_success "Zen $file symlinked to $dest"
        fi
    done
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

install_home_manager() {
    print_info "NixOS detected: applying the Home Manager configuration..."

    # Activation package pinned by flake.lock, no global home-manager CLI needed.
    local generation
    generation=$(nix build --no-link --print-out-paths \
        "$(cd "$DOTFILES_DIR" && pwd)#homeConfigurations.$USER.activationPackage")
    HOME_MANAGER_BACKUP_EXT=hm-bak "$generation/activate"

    if [ -f "$HOME/.gitconfig" ]; then
        print_info "$HOME/.gitconfig overrides the Git config managed by Home Manager; consider removing it"
    fi

    print_success "Home Manager configuration applied"
}

main() {
    echo "🚀 Installing dotfiles..."
    echo "📁 Dotfiles directory: $DOTFILES_DIR"
    echo ""

    check_dotfiles_directory
    check_git_installed

    if [ -e /etc/NIXOS ]; then
        install_home_manager
    else
        install_git_config
        install_tern_config
        install_zed_config
    fi
    # The Zen profile directory is only known at runtime, so Home Manager cannot link it.
    install_zen_config

    echo ""
    print_success "Installation completed!"
}

main "$@"
