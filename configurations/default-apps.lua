local filesystem = require("gears.filesystem")
local beautiful = require("beautiful")
local config_dir = filesystem.get_configuration_dir()
local default_apps = {}

default_apps.screeh_shot = "spectacle"
default_apps.lock_screen = config_dir .. "scripts/i3lock-blur "
default_apps.software_updater = terminal .. " --title 'System upgrade' -e sudo pacman -Syu"
default_apps.bluetooth_manager = terminal .. " -e bluetoothctl"
default_apps.network_manager = terminal .. " -e nmtui"
default_apps.app_menu = "rofi -dpi " .. screen.primary.dpi ..
						" -show drun -theme " .. config_dir ..
						"configurations/rofi-".. beautiful.mode ..".rasi -icon-theme " ..
						beautiful.icon_theme

return default_apps
