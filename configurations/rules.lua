local awful = require("awful")
local beautiful = require("beautiful")
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    {
		rule = { },
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = awful.client.focus.filter,
			raise = true,
			keys = clientkeys,
			buttons = clientbuttons,
			screen = awful.screen.preferred,
			--placement = awful.placement.no_overlap+awful.placement.no_offscreen
		}
    },

    -- Floating clients.
    {
		rule_any = {
			instance = {
			  "DTA",  -- Firefox addon DownThemAll.
			  "copyq",  -- Includes session name in class.
			  "pinentry",
			},
			class = {
			  "Arandr",
			  "Blueman-manager",
			  "Gpick",
			  "Kruler",
			  "MessageWin",  -- kalarm.
			  "Sxiv",
			  "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
			  "Wpa_gui",
			  "veromix",
			  "xtightvncviewer"},

			-- Note that the name property shown in xprop might be set slightly after creation of the client
			-- and the name shown there might not match defined rules here.
			name = {
			  "Event Tester",  -- xev.
			},
			role = {
			  "AlarmWindow",  -- Thunderbird's calendar.
			  "ConfigManager",  -- Thunderbird's about:config.
			  "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
			}
      	},
		properties = { floating = true }
	},

    -- Add titlebars to normal clients and dialogs
    {
		rule_any = {
			type = { "normal", "dialog" }
      	},
		properties = { titlebars_enabled = true }
    },

    -- Set Firefox to always map to the web tag on screen 1.
    {
		rule = { class = "firefox" },
    	properties = { screen = 1, tag = "爵" }
	},
	{
		rule = { instance = "plugin-container" },
	 	properties = { floating = true }
  	},
	{
		rule = { role = "_NET_WM_STATE_FULLSCREEN" },
  		properties = { floating = true }
  	},
	{
		rule = { class= "Simple-scan" },
		properties = { titlebars_enabled = false}
	},
	{
		rule = { class= "feh" },
		properties = { width = 800, height = 600}
	},
    {
		rule = { class = "Alacritty", instance = "tagged" },
    	properties = { screen = 1, tag = "" }
	},
    {
		rule = { class = "Alacritty", instance = "spotify" },
    	properties = { screen = 1, tag = "" }
	},
}
