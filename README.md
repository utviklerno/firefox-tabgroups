# Firefox Tab Groups CSS Customization

Custom CSS styling for Firefox tabs and tab groups with a dark theme.

## Features

- Square tab corners (no rounded edges)
- Dark theme with custom colors
- Enhanced tab group styling
- Custom folder icon for tab groups
- Hover effects for better UX

## Installation

### Automatic Installation (Linux)

1. Clone or download this repository
2. Open a terminal in the project directory
3. Make the install script executable:
   ```bash
   chmod +x install.sh
   ```
4. Run the installer:
   ```bash
   ./install.sh
   ```
5. Restart Firefox

The installer will:
- Automatically detect your Firefox profile(s)
- Back up any existing userChrome.css files
- Install the custom CSS
- Enable userChrome.css support in Firefox

### Manual Installation

1. Open Firefox and type `about:config` in the address bar
2. Search for `toolkit.legacyUserProfileCustomizations.stylesheets`
3. Set it to `true`
4. Open `about:support` and find your Profile Folder
5. Click "Open Folder"
6. Create a `chrome` folder if it doesn't exist
7. Copy `userChrome.css` into the `chrome` folder
8. Restart Firefox

## Uninstallation

### Automatic Uninstallation

1. Run the uninstall script:
   ```bash
   chmod +x uninstall.sh
   ./uninstall.sh
   ```
2. Restart Firefox

### Manual Uninstallation

1. Navigate to your Firefox profile's `chrome` folder
2. Remove or rename `userChrome.css`
3. Restart Firefox

## Compatibility

- Tested on Ubuntu and other Linux distributions
- Works with:
  - Regular Firefox installations
  - Snap Firefox
  - Flatpak Firefox
- Requires Firefox 90+ with tab groups feature enabled

## Customization

Edit `userChrome.css` to modify:
- Colors: Change hex color values in the CSS
- Font sizes: Adjust `font-size` values
- Spacing: Modify `padding` and `margin` values

## Troubleshooting

If the styles don't apply:
1. Verify `toolkit.legacyUserProfileCustomizations.stylesheets` is `true` in `about:config`
2. Check that the file is named exactly `userChrome.css` (case-sensitive)
3. Ensure the file is in the `chrome` folder within your Firefox profile
4. Restart Firefox completely (close all windows)

## Backup

The installer automatically creates backups of existing CSS files. Look for `backup_YYYYMMDD_HHMMSS` folders in your chrome directory.