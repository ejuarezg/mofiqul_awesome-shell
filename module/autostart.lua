local awful = require("awful")
local filesystem = require("gears.filesystem")
local beautiful = require("beautiful")
local naughty = require("naughty")
local config_dir = filesystem.get_configuration_dir()
local default_apps = require("configurations.default-apps")
local startup_apps = {
	"picom -b --experimental-backends --config " .. config_dir .. "configurations/picom.conf",
	"redshift -t 6500:3500 -l " .. os.getenv("GEOLOCATION"),
	"udiskie",
        -- Note: 3600 seconds is 1 hour
	"xidlehook --not-when-fullscreen --not-when-audio --timer 900 'xbacklight -set 1' 'xbacklight -set 50' --timer 15 'xbacklight -set 50; " .. default_apps.lock_screen .. "' '' --timer 14400 'systemctl suspend' ''",
	-- "$HOME/.local/bin/xinput-tab",
	-- "xbacklight -set 45",
    -- Add your startup programs here
    "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1",
    "xrandr --output HDMI-A-3 --off",
    "xset s off -dpms",
}


local spawn_once = function (cmd)
    local findme = cmd

    local firstspace = cmd:find(" ")
    if firstspace then
        findme = cmd:sub(0, firstspace - 1)
    end

    -- Find the command when given an absolute path
    local lastslash = findme:find("/[^/]*$")
    if lastslash then
        -- pgrep only cares about the first 15 characters of a command
        findme = findme:sub(lastslash + 1, lastslash + 15)
    end

    awful.spawn.easy_async_with_shell(
        string.format('pgrep -u $USER -x %s > /dev/null || (%s)', findme, cmd),
        function(_, stderr)
            if not stderr or stderr == '' then
                return
            end
            naughty.notification({
                app_name = 'Startup Applications',
				image = beautiful.icon_noti_error,
                title = "Error starting application",
                message = "Error while starting " .. cmd,
                timeout = 10,
                icon = beautiful.icon_noti_error,
            })
        end
    )
end

for _, app in ipairs(startup_apps) do
	spawn_once(app)
end

