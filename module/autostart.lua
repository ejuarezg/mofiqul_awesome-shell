local awful = require("awful")
local filesystem = require("gears.filesystem")
local beautiful = require("beautiful")
local naughty = require("naughty")
local config_dir = filesystem.get_configuration_dir()
local default_apps = require("configurations.default-apps")
local startup_apps = {
    -- Add your startup programs here
    "picom -b --experimental-backends --config " .. config_dir .. "configurations/picom.conf",
    "redshift -t 6500:3500 -l " .. os.getenv("GEOLOCATION"),
    "udiskie",
    -- 3600 seconds is 1 hour
    "xidlehook --not-when-fullscreen --not-when-audio --timer 900 'xset dpms force off' '' --timer 15 'xset dpms force on; " .. default_apps.lock_screen .. "' '' --timer 900 'xset dpms force off' '' --timer 10800 'systemctl suspend' ''",
    "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1",
    "xrandr --output HDMI-A-3 --off",
    -- From ArchWiki: https://wiki.archlinux.org/title/Display_Power_Management_Signaling
    -- Set the blanking timer longer than the suspend timer used in xidlehook
    "xset dpms 0 0 0 && xset s 28800 28800",
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

