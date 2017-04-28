#!/bin/sh

# Error if variable is unassigned
set -u

# Turn off automatic updates
function turn_off_automatic_updates() {
	automaticUpdates=$(gsettings get org.gnome.software download-updates)
	if [[ "$automaticUpdates" =~ false ]]; then
		echo "Automatic updates: Currently off"
		return 0
	fi

	echo "Automatic updates: Turning on"

	gsettings set org.gnome.software download-updates false
	echo "Automatic updates: Restart required..."
	exit 0
}

turn_off_automatic_updates


