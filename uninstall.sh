#!/bin/bash

set -euo pipefail

NEWSBOAT_CONFIG_DIR="$HOME/.config/newsboat"
NEWSBOAT_CONFIG="$NEWSBOAT_CONFIG_DIR/config"
NEWSBOAT_DIR="$HOME/.newsboat"
SCRIPT_NAME="newsboat-summarize"
CONFIG_NAME="summarize.conf"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

error_exit() {
    log "ERROR: $1"
    exit 1
}

backup_config() {
    if [[ -f "$NEWSBOAT_CONFIG" ]]; then
        local backup_file="${NEWSBOAT_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"
        log "Backing up newsboat config to: $backup_file"
        cp "$NEWSBOAT_CONFIG" "$backup_file"
    fi
}

remove_macro_from_config() {
    if [[ ! -f "$NEWSBOAT_CONFIG" ]]; then
        log "Newsboat config file not found: $NEWSBOAT_CONFIG"
        return
    fi
    
    log "Removing summarization macro from newsboat config..."
    
    # Remove any line containing newsboat-summarize
    if grep -q "newsboat-summarize" "$NEWSBOAT_CONFIG"; then
        log "Found summarization macro, removing it"
        grep -v "newsboat-summarize" "$NEWSBOAT_CONFIG" > "${NEWSBOAT_CONFIG}.tmp"
        mv "${NEWSBOAT_CONFIG}.tmp" "$NEWSBOAT_CONFIG"
        log "Summarization macro removed"
    else
        log "No summarization macro found in config"
    fi
}

remove_files() {
    log "Removing installed files..."
    
    local files_removed=0
    
    # Remove main script
    if [[ -f "$NEWSBOAT_DIR/$SCRIPT_NAME" ]]; then
        log "Removing: $NEWSBOAT_DIR/$SCRIPT_NAME"
        rm "$NEWSBOAT_DIR/$SCRIPT_NAME"
        files_removed=$((files_removed + 1))
    fi
    
    # Remove config file
    if [[ -f "$NEWSBOAT_DIR/$CONFIG_NAME" ]]; then
        log "Removing: $NEWSBOAT_DIR/$CONFIG_NAME"
        rm "$NEWSBOAT_DIR/$CONFIG_NAME"
        files_removed=$((files_removed + 1))
    fi
    
    
    if [[ $files_removed -eq 0 ]]; then
        log "No installed files found to remove"
    else
        log "Removed $files_removed file(s)"
    fi
}

remove_temp_files() {
    log "Cleaning up temporary files..."
    
    # Remove debug logs
    if [[ -f "/tmp/newsboat-debug.log" ]]; then
        log "Removing debug log: /tmp/newsboat-debug.log"
        rm "/tmp/newsboat-debug.log"
    fi
    
    # Remove test files
    if [[ -f "/tmp/macro-test-z" ]]; then
        log "Removing test file: /tmp/macro-test-z"
        rm "/tmp/macro-test-z"
    fi
}

restore_browser_setting() {
    if [[ ! -f "$NEWSBOAT_CONFIG" ]]; then
        return
    fi
    
    # Check if there's a browser setting that might have been modified
    if grep -q "^browser open$" "$NEWSBOAT_CONFIG"; then
        log "Found simplified browser setting, you may want to restore your original browser configuration"
        log "Current browser setting: $(grep "^browser" "$NEWSBOAT_CONFIG" | head -1)"
    fi
}

print_completion() {
    log ""
    log "✓ Uninstallation completed successfully!"
    log ""
    log "What was removed:"
    log "  - ',m' macro from newsboat config"
    log "  - Script files from ~/.newsboat/"
    log "  - Configuration files"
    log "  - Temporary/debug files"
    log ""
    log "What remains:"
    log "  - Newsboat config backup files (*.backup.*)"
    log "  - Your original newsboat configuration"
    log "  - youtube-transcript-api (if you want to remove: pip uninstall youtube-transcript-api)"
    log ""
    log "To complete removal:"
    log "  1. Restart newsboat to reload configuration"
    log "  2. Check your browser setting is correct"
    log "  3. Remove this project directory if desired"
}

main() {
    log "Starting newsboat-summarize uninstallation..."
    
    # Confirm with user
    echo -n "This will remove the newsboat summarization integration. Continue? [y/N]: "
    read -r response
    case "$response" in
        [yY]|[yY][eE][sS])
            log "Proceeding with uninstallation..."
            ;;
        *)
            log "Uninstallation cancelled"
            exit 0
            ;;
    esac
    
    backup_config
    remove_macro_from_config
    remove_files
    remove_temp_files
    restore_browser_setting
    print_completion
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi