local wibox = require("wibox")
local naughty = require("naughty")
local beautiful = require("beautiful")
local awful = require("awful")
local dpi = beautiful.xresources.apply_dpi
local gears =  require("gears")
local menubar = require("menubar")
local clickable_container = require("widgets.clickable-container")

local notifications = {}


naughty.connect_signal(
	'request::icon',
	function(n, context, hints)
		if context ~= 'app_icon' then return end

		local path = menubar.utils.lookup_icon(hints.app_icon) or
		menubar.utils.lookup_icon(hints.app_icon:lower())

		if path then
			n.icon = path
		end
	end
)

naughty.connect_signal("request::display", function (n)
	-- Main container of the notification
	local container = wibox.widget{
		spacing = beautiful.notification_margin,
		layout = wibox.layout.fixed.vertical
	}

	local icon = wibox.widget{
		resize_strategy = "scale",
		widget = naughty.widget.icon
	}

	local app_icon = function ()
		local widget = {}

		if not n.app_icon == nil  or not n.app_icon == '' then
			widget = wibox.widget{
				image = n.app_icon,
				resize = true,
				forced_height = dpi(16),
				forced_width = dpi(16),
				widget = wibox.widget.imagebox
			}
		elseif not n.image == nil or not n.image == '' then
			widget = wibox.widget{
				image = n.image,
				resize = true,
				forced_height = dpi(16),
				forced_width = dpi(16),
				widget = wibox.widget.imagebox
			}

		else
			widget = nil
		end

		return widget
	end


	local dismiss_button = wibox.widget{
		{
			{
				{
					image = beautiful.icon_times,
					resize = true,
					forced_height = dpi(16),
					forced_width = dpi(16),
					widget = wibox.widget.imagebox
				},
				margins = dpi(1),
				widget = wibox.container.margin
			},
			bg = beautiful.bg_button,
			border_width = beautiful.btn_border_width,
			border_color = beautiful.border_button,
			shape =  gears.shape.circle,
			widget = wibox.container.background
		},
		widget = clickable_container
	}

	dismiss_button:connect_signal("button::press", function (_,_,_,button)
		if button == 1 then
			n:destroy(nil, 1)
		end
	end)

	local app_name = wibox.widget{
		markup = n.app_name or "System Notification",
		font = "Sans Bold 10",
		align = 'center',
		valign = 'center',
		widget = wibox.widget.textbox
	}

	local app_icon_with_name_and_dismiss_btn = wibox.widget{
		{
			app_icon(),
			app_name,
			spacing = beautiful.notification_margin,
			layout = wibox.layout.fixed.horizontal
		},
		nil,
		dismiss_button,
		expand = "inside",
		spacing = beautiful.notification_margin,
		layout = wibox.layout.align.horizontal
	}

	local action_list = wibox.widget {
		notification = n,
		base_layout = wibox.widget {
			spacing = beautiful.notification_margin,
			layout = wibox.layout.fixed.horizontal
		},
		widget_template = {
			{
				{
					{
						id = 'text_role',
						align = "center",
						valign = "center",
						widget = wibox.widget.textbox
					},
					top = dpi(4),
					bottom = dpi(4),
					left = dpi(10),
					right = dpi(10),
					widget = wibox.container.margin
				},
				bg = beautiful.bg_button,
				border_width = beautiful.btn_border_width,
				border_color = beautiful.border_button,
				shape = gears.shape.rounded_bar,
				widget = wibox.container.background,
			},
			widget  = clickable_container,
		},
		style = { underline_normal = false, underline_selected = true },
		widget = naughty.list.actions,
	}

	local title_area_and_message = wibox.widget{
		naughty.widget.title,
		naughty.widget.message,
		spacing = beautiful.notification_margin,
		layout = wibox.layout.fixed.vertical
	}


	local notibox = wibox.widget{
		app_icon_with_name_and_dismiss_btn,
		{
			icon,
			title_area_and_message,
			spacing = beautiful.notification_margin,
			layout = wibox.layout.fixed.horizontal
		},
		spacing = beautiful.notification_margin,
		layout = wibox.layout.fixed.vertical
	}


	naughty.layout.box {
		notification = n,
		bg = "#00000000",
		widget_template = {
			{
				{
					{
						notibox,
						action_list,
						widget = container
					},
					margins = beautiful.notification_margin,
					widget = wibox.container.margin
				},
				bg = beautiful.bg_normal,
				shape = beautiful.widget_shape,
				widget = wibox.container.background
			},
			strategy = "max",
			forced_width = beautiful.notification_max_width or dpi(300),
    		widget = wibox.container.constraint
		}
	}

	local focused = awful.screen.focused()
	if _G.dont_disturb or
		(focused.central_panel and focused.central_panel.visible) then
		naughty.destroy_all_notifications(nil, 1)
	end

end)

-- >> Notify DWIM (Do What I Mean):
-- Create or update notification automagically. Requires storing the
-- notification in a variable.
--
-- Example usage:
--     local my_notif = notifications.notify_dwim({ title = "hello", message = "there" }, my_notif)
--     -- After a while, use this to update or recreate the notification if it is expired / dismissed
--     my_notif = notifications.notify_dwim({ title = "good", message = "bye" }, my_notif)
--
-- This function was nabbed from
-- https://github.com/elenapan/dotfiles/blob/master/config/awesome/notifications/init.lua
function notifications.notify_dwim(args, notif)
    local n = notif
    if n and not n._private.is_destroyed and not n.is_expired then
        notif.title = args.title or notif.title
        notif.message = args.message or notif.message
        -- notif.text = args.text or notif.text
        notif.icon = args.icon or notif.icon
        notif.timeout = args.timeout or notif.timeout
    else
        n = naughty.notification(args)
    end
    return n
end

function notifications.init()
    require("module.notifications.volume")
end

return notifications
