#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NEWSBOAT_DIR="$HOME/.newsboat"
NEWSBOAT_CONFIG_DIR="$HOME/.config/newsboat"
NEWSBOAT_CONFIG="$NEWSBOAT_CONFIG_DIR/config"
SCRIPT_NAME="newsboat-summarize"
CONFIG_NAME="summarize.conf"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

error_exit() {
    log "ERROR: $1"
    exit 1
}

check_dependencies() {
    log "Checking dependencies..."

    # Check for Python 3
    if ! command -v python3 >/dev/null 2>&1; then
        error_exit "python3 is required but not installed"
    fi

    # Check for pip
    if ! command -v pip3 >/dev/null 2>&1 && ! python3 -m pip --version >/dev/null 2>&1; then
        error_exit "pip3 is required but not installed"
    fi

    # Check for curl or lynx for article extraction
    if ! command -v curl >/dev/null 2>&1 && ! command -v lynx >/dev/null 2>&1; then
        log "WARNING: Neither curl nor lynx found. Install one for article content extraction."
        log "  macOS: brew install lynx"
        log "  Ubuntu/Debian: sudo apt install lynx"
        log "  Fedora: sudo dnf install lynx"
    fi

    log "Dependencies check completed"
}

install_youtube_transcript_api() {
    log "Checking youtube-transcript-api..."

    if python3 -c "import youtube_transcript_api" 2>/dev/null; then
        log "youtube-transcript-api already installed"
        return
    fi

    log "Installing youtube-transcript-api..."
    if python3 -m pip install youtube-transcript-api --user; then
        log "youtube-transcript-api installed successfully"
    else
        error_exit "Failed to install youtube-transcript-api"
    fi
}

create_newsboat_directories() {
    if [[ ! -d "$NEWSBOAT_DIR" ]]; then
        log "Creating newsboat directory: $NEWSBOAT_DIR"
        mkdir -p "$NEWSBOAT_DIR"
    fi
    if [[ ! -d "$NEWSBOAT_CONFIG_DIR" ]]; then
        log "Creating newsboat config directory: $NEWSBOAT_CONFIG_DIR"
        mkdir -p "$NEWSBOAT_CONFIG_DIR"
    fi
}

backup_config() {
    if [[ -f "$NEWSBOAT_CONFIG" ]]; then
        local backup_file="${NEWSBOAT_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"
        log "Backing up existing config to: $backup_file"
        cp "$NEWSBOAT_CONFIG" "$backup_file"
    fi
}

install_files() {
    log "Installing script and config files..."

    # Copy main script
    if [[ -f "$SCRIPT_DIR/$SCRIPT_NAME" ]]; then
        cp "$SCRIPT_DIR/$SCRIPT_NAME" "$NEWSBOAT_DIR/"
        chmod +x "$NEWSBOAT_DIR/$SCRIPT_NAME"
        log "Installed: $NEWSBOAT_DIR/$SCRIPT_NAME"
    else
        error_exit "Script file not found: $SCRIPT_DIR/$SCRIPT_NAME"
    fi

    # Copy config file
    if [[ -f "$SCRIPT_DIR/$CONFIG_NAME" ]]; then
        if [[ -f "$NEWSBOAT_DIR/$CONFIG_NAME" ]]; then
            log "Config file already exists, skipping: $NEWSBOAT_DIR/$CONFIG_NAME"
        else
            cp "$SCRIPT_DIR/$CONFIG_NAME" "$NEWSBOAT_DIR/"
            log "Installed: $NEWSBOAT_DIR/$CONFIG_NAME"
        fi
    else
        error_exit "Config file not found: $SCRIPT_DIR/$CONFIG_NAME"
    fi
}

add_macro_to_config() {
    # Detect current browser setting
    local current_browser
    if [[ -f "$NEWSBOAT_CONFIG" ]] && grep -q "^browser" "$NEWSBOAT_CONFIG"; then
        current_browser=$(grep "^browser" "$NEWSBOAT_CONFIG" | head -1 | sed 's/^browser[[:space:]]*//')
        log "Found existing browser setting: $current_browser"
    else
        # Default newsboat behavior (system default browser)
        case "$(uname -s)" in
            Darwin*)
                current_browser="open"
                ;;
            Linux*)
                current_browser="xdg-open"
                ;;
            *)
                current_browser="xdg-open"
                ;;
        esac
        log "Using default browser setting: $current_browser"
        # Add the browser setting to config
        echo "browser $current_browser" >> "$NEWSBOAT_CONFIG"
    fi

    local macro_line="macro m set browser \"$NEWSBOAT_DIR/$SCRIPT_NAME\" ; open-in-browser ; set browser $current_browser"

    # Remove any existing summarization macro
    if [[ -f "$NEWSBOAT_CONFIG" ]] && grep -q "newsboat-summarize" "$NEWSBOAT_CONFIG"; then
        log "Removing existing summarization macro"
        grep -v "newsboat-summarize" "$NEWSBOAT_CONFIG" > "${NEWSBOAT_CONFIG}.tmp" && mv "${NEWSBOAT_CONFIG}.tmp" "$NEWSBOAT_CONFIG"
    fi

    log "Adding macro to newsboat config..."
    echo "$macro_line" >> "$NEWSBOAT_CONFIG"
    log "Added macro: $macro_line"
}

detect_platform() {
    case "$(uname -s)" in
        Darwin*)
            log "Detected macOS"
            ;;
        Linux*)
            log "Detected Linux"
            # Update summarize.conf for Linux
            if [[ -f "$NEWSBOAT_DIR/$CONFIG_NAME" ]]; then
                sed -i 's/BROWSER_CMD="open"/BROWSER_CMD="xdg-open"/' "$NEWSBOAT_DIR/$CONFIG_NAME"
                log "Updated browser command for Linux"
            fi
            ;;
        *)
            log "Unknown platform, using defaults"
            ;;
    esac
}

print_success() {
    log ""
    log "✓ Installation completed successfully!"
    log ""
    log "Usage:"
    log "  1. Start newsboat"
    log "  2. Navigate to an article or YouTube video"
    log "  3. Press ',m' to summarize"
    log "  4. Browser opens with chat interface"
    log "  5. Content is copied to clipboard - paste with Cmd+V (macOS) or Ctrl+V (Linux)"
    log ""
    log "Configuration:"
    log "  Edit $NEWSBOAT_DIR/$CONFIG_NAME to:"
    log "  - Change AI provider (claude/chatgpt/grok)"
    log "  - Customize prompts"
    log "  - Adjust browser command"
    log ""
    log "Files installed:"
    log "  - $NEWSBOAT_DIR/$SCRIPT_NAME"
    log "  - $NEWSBOAT_DIR/$CONFIG_NAME"
    log "  - Added ',m' macro to $NEWSBOAT_CONFIG"
    log ""
    log "Note: Content is copied to clipboard for pasting into chat interface"
}

main() {
    log "Starting newsboat-summarize installation..."

    check_dependencies
    install_youtube_transcript_api
    create_newsboat_directories
    backup_config
    install_files
    add_macro_to_config
    detect_platform
    print_success
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
