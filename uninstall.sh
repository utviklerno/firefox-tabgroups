#!/bin/bash

# Firefox CSS Theme Uninstaller

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Firefox CSS Theme Uninstaller${NC}"
echo "================================"

# Function to find Firefox profiles (same as install script)
find_firefox_profiles() {
    local firefox_dirs=()
    
    if [ -d "$HOME/.mozilla/firefox" ]; then
        firefox_dirs+=("$HOME/.mozilla/firefox")
    fi
    
    if [ -d "$HOME/snap/firefox/common/.mozilla/firefox" ]; then
        firefox_dirs+=("$HOME/snap/firefox/common/.mozilla/firefox")
    fi
    
    if [ -d "$HOME/.var/app/org.mozilla.firefox/.mozilla/firefox" ]; then
        firefox_dirs+=("$HOME/.var/app/org.mozilla.firefox/.mozilla/firefox")
    fi
    
    if [ ${#firefox_dirs[@]} -eq 0 ]; then
        echo -e "${RED}No Firefox installation found!${NC}"
        exit 1
    fi
    
    local profiles=()
    for dir in "${firefox_dirs[@]}"; do
        if [ -f "$dir/profiles.ini" ]; then
            while IFS= read -r profile_path; do
                if [ -d "$dir/$profile_path" ]; then
                    profiles+=("$dir/$profile_path")
                fi
            done < <(grep '^Path=' "$dir/profiles.ini" | cut -d'=' -f2)
        fi
    done
    
    echo "${profiles[@]}"
}

# Function to uninstall CSS from profile
uninstall_from_profile() {
    local profile_dir="$1"
    local chrome_dir="$profile_dir/chrome"
    
    if [ -f "$chrome_dir/userChrome.css" ]; then
        # Create backup before removing
        local backup_name="userChrome.css.removed_$(date +%Y%m%d_%H%M%S)"
        mv "$chrome_dir/userChrome.css" "$chrome_dir/$backup_name"
        echo -e "${GREEN}✓ Removed userChrome.css (backed up as $backup_name)${NC}"
    else
        echo -e "${YELLOW}No userChrome.css found in this profile${NC}"
    fi
    
    # Remove the preference from user.js if it exists
    if [ -f "$profile_dir/user.js" ]; then
        sed -i '/toolkit.legacyUserProfileCustomizations.stylesheets/d' "$profile_dir/user.js"
        echo -e "${GREEN}✓ Disabled userChrome.css support${NC}"
    fi
}

# Main uninstallation process
main() {
    echo "Searching for Firefox profiles..."
    IFS=' ' read -r -a profiles <<< "$(find_firefox_profiles)"
    
    if [ ${#profiles[@]} -eq 0 ]; then
        echo -e "${RED}No Firefox profiles found!${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}This will remove the custom CSS theme from Firefox.${NC}"
    read -p "Are you sure you want to continue? (y/N): " confirm
    
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Uninstallation cancelled."
        exit 0
    fi
    
    for profile in "${profiles[@]}"; do
        echo -e "\n${YELLOW}Processing profile: $(basename "$profile")${NC}"
        uninstall_from_profile "$profile"
    done
    
    echo -e "\n${GREEN}================================${NC}"
    echo -e "${GREEN}Uninstallation complete!${NC}"
    echo -e "${YELLOW}Please restart Firefox for changes to take effect.${NC}"
}

# Run main function
main