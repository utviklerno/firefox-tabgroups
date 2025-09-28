#!/bin/bash

# Firefox CSS Theme Installer for Linux
# Primarily tested on Ubuntu, should work on most Linux distributions

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Firefox CSS Theme Installer${NC}"
echo "================================"

# Function to find Firefox profiles
find_firefox_profiles() {
    local firefox_dirs=()
    
    # Check common Firefox profile locations
    if [ -d "$HOME/.mozilla/firefox" ]; then
        firefox_dirs+=("$HOME/.mozilla/firefox")
    fi
    
    # Check Snap Firefox location
    if [ -d "$HOME/snap/firefox/common/.mozilla/firefox" ]; then
        firefox_dirs+=("$HOME/snap/firefox/common/.mozilla/firefox")
    fi
    
    # Check Flatpak Firefox location
    if [ -d "$HOME/.var/app/org.mozilla.firefox/.mozilla/firefox" ]; then
        firefox_dirs+=("$HOME/.var/app/org.mozilla.firefox/.mozilla/firefox")
    fi
    
    if [ ${#firefox_dirs[@]} -eq 0 ]; then
        echo -e "${RED}No Firefox installation found!${NC}"
        exit 1
    fi
    
    # Find all profiles
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

# Function to backup existing files
backup_existing() {
    local profile_dir="$1"
    local chrome_dir="$profile_dir/chrome"
    local backup_dir="$chrome_dir/backup_$(date +%Y%m%d_%H%M%S)"
    
    if [ -f "$chrome_dir/userChrome.css" ]; then
        echo -e "${YELLOW}Backing up existing userChrome.css...${NC}"
        mkdir -p "$backup_dir"
        cp "$chrome_dir/userChrome.css" "$backup_dir/"
        echo -e "${GREEN}Backup created in: $backup_dir${NC}"
    fi
}

# Function to install the CSS
install_css() {
    local profile_dir="$1"
    local chrome_dir="$profile_dir/chrome"
    
    # Create chrome directory if it doesn't exist
    mkdir -p "$chrome_dir"
    
    # Backup existing files
    backup_existing "$profile_dir"
    
    # Copy the CSS file
    cp userChrome.css "$chrome_dir/"
    
    # Copy README if it exists
    if [ -f "README.md" ]; then
        cp README.md "$chrome_dir/"
    fi
    
    echo -e "${GREEN}✓ CSS installed to: $chrome_dir${NC}"
}

# Function to enable userChrome.css in Firefox
enable_userchrome() {
    local profile_dir="$1"
    local prefs_file="$profile_dir/prefs.js"
    local user_file="$profile_dir/user.js"
    
    echo -e "${YELLOW}Enabling userChrome.css support...${NC}"
    
    # Add preference to user.js (safer than modifying prefs.js)
    echo 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);' >> "$user_file"
    
    echo -e "${GREEN}✓ userChrome.css support enabled${NC}"
}

# Main installation process
main() {
    # Check if userChrome.css exists in current directory
    if [ ! -f "userChrome.css" ]; then
        echo -e "${RED}Error: userChrome.css not found in current directory!${NC}"
        exit 1
    fi
    
    # Find Firefox profiles
    echo "Searching for Firefox profiles..."
    IFS=' ' read -r -a profiles <<< "$(find_firefox_profiles)"
    
    if [ ${#profiles[@]} -eq 0 ]; then
        echo -e "${RED}No Firefox profiles found!${NC}"
        exit 1
    fi
    
    # If multiple profiles, let user choose
    if [ ${#profiles[@]} -gt 1 ]; then
        echo -e "${YELLOW}Multiple Firefox profiles found:${NC}"
        for i in "${!profiles[@]}"; do
            echo "  [$i] ${profiles[$i]}"
        done
        
        read -p "Select profile number (or 'all' for all profiles): " choice
        
        if [ "$choice" = "all" ]; then
            for profile in "${profiles[@]}"; do
                echo -e "\n${YELLOW}Installing to profile: $(basename "$profile")${NC}"
                install_css "$profile"
                enable_userchrome "$profile"
            done
        else
            if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 0 ] && [ "$choice" -lt ${#profiles[@]} ]; then
                install_css "${profiles[$choice]}"
                enable_userchrome "${profiles[$choice]}"
            else
                echo -e "${RED}Invalid selection!${NC}"
                exit 1
            fi
        fi
    else
        # Single profile found
        echo -e "${YELLOW}Installing to profile: $(basename "${profiles[0]}")${NC}"
        install_css "${profiles[0]}"
        enable_userchrome "${profiles[0]}"
    fi
    
    echo -e "\n${GREEN}================================${NC}"
    echo -e "${GREEN}Installation complete!${NC}"
    echo -e "${YELLOW}Please restart Firefox for changes to take effect.${NC}"
    echo -e "${YELLOW}Note: Make sure 'toolkit.legacyUserProfileCustomizations.stylesheets' is set to true in about:config${NC}"
}

# Run main function
main