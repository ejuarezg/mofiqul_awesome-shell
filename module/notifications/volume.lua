-- Code adapted from https://github.com/elenapan/dotfiles/blob/master/config/awesome/notifications/volume.lua

local naughty = require("naughty")
local beautiful = require("beautiful")
local notifications = require("module.notifications")

local notif
local timeout = 1.5
local first_time = true
awesome.connect_signal("evil::volume", function (percentage, muted)
    if first_time then
        first_time = false
    else
        -- Send notification
        local message, icon
        if muted then
            message = "muted"
            -- icon = beautiful.volume_muted_icon:match("(.+)%..+$") .. ".png"
            icon = beautiful.volume_muted_icon:gsub("[^%.]*$", "png")
        else
            message = tostring(percentage)
            -- icon = beautiful.volume_normal_icon:match("(.+)%..+$") .. ".png"
            icon = beautiful.volume_normal_icon:gsub("[^%.]*$", "png")
        end

        notif = notifications.notify_dwim({ title = "Volume", message = message, icon = icon, timeout = timeout, app_name = "Volume Notification" }, notif)
    end
end)

