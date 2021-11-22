--    ___      _____ ___  ___  __  __ _____      ____  __
--   /_\ \    / / __/ __|/ _ \|  \/  | __\ \    / /  \/  |
--  / _ \ \/\/ /| _|\__ \ (_) | |\/| | _| \ \/\/ /| |\/| |
-- /_/ \_\_/\_/ |___|___/\___/|_|  |_|___| \_/\_/ |_|  |_|
--

-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

local gears   = require("gears")
local awful   = require("awful")
local helpers = require("helpers")

local config_dir = gears.filesystem.get_configuration_dir()

-- ========================================
-- User Config
-- ========================================

-- network interfaces
Network_Interfaces = {
  wlan = "wlan0",
  lan = "enp0s21f0u1",
}

-- layouts
awful.layout.layouts = {
  awful.layout.suit.tile,
  awful.layout.suit.floating,
  awful.layout.suit.max,
}


-- tag configs
Tags = {
  { name = "main" , layout = awful.layout.layouts[1] },
  { name = "web"  , layout = awful.layout.layouts[1] },
  { name = "code" , layout = awful.layout.layouts[1] },
  { name = "chat" , layout = awful.layout.layouts[1] },
  { name = "media", layout = awful.layout.layouts[1] },
}

-- run these commands on start up
local startup_scripts = {
  -- Remap modifier keys when pressed alone
  "xcape -e 'Control_L=Escape;Super_L=Hangul_Hanja;Super_R=Hangul'",
  -- keyboard layouts
  "setxkbmap -layout us,ru -option 'grp:alt_shift_toggle,grp_led:scroll'",
  -- Faster key repeat response
  "xset r rate 260 47",
  -- Compositor
  "picom",
  -- Set wallpaper
  "feh --bg-scale " .. config_dir .. "/wallpapers/aenami.jpg",
  -- polkit
  "/usr/lib/xfce-polkit/xfce-polkit",
  -- power manager
  "xfce4-power-manager",
}

-- ========================================
-- Visualizations
-- ========================================

-- Load theme vars
local beautiful = require("beautiful")
beautiful.init(config_dir .. "theme.lua")


-- ========================================
-- Initialization
-- ========================================

-- Run all apps listed on start up
--for _, app in ipairs(startup_scripts) do
--  -- Don't spawn startup command if already exists
--  awful.spawn.with_shell(string.format(
--    [[ pgrep -u $USER -x %s > /dev/null || (%s) ]],
--    helpers.get_main_process_name(app),
--    app
--  ))
--end

for app = 1, #startup_scripts do
	awful.util.spawn(startup_scripts[app])
end

-- Start daemons
require("daemons")

-- Load notifications
require("notifications")

-- Load components
require("components")


-- ========================================
-- Tags
-- ========================================

local tag_names = {}
local tag_layouts = {}

for i, tag in ipairs(Tags) do
  tag_names[i] = tag.name
  tag_layouts[i] = tag.layout
end

-- Each screen has its own tag table.
awful.screen.connect_for_each_screen(function(s)
  awful.tag(tag_names, s, tag_layouts)
end)

-- Remove gaps if layout is set to max
tag.connect_signal("property::layout", function(t)
  helpers.set_gaps(t.screen, t)
end)
-- Layout might change in different tag
-- so update again when switched to another tag
tag.connect_signal("property::selected", function(t)
  helpers.set_gaps(t.screen, t)
end)


-- ========================================
-- Keybindings
-- ========================================

local keys = require("keys")
root.keys(keys.globalkeys)
root.buttons(keys.desktopbuttons)


-- ========================================
-- Rules
-- ========================================

local rules = require("rules")
awful.rules.rules = rules


-- ========================================
-- Clients
-- ========================================

-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
  -- Set the windows at the slave,
  -- i.e. put it at the end of others instead of setting it master.
  if not awesome.startup then
    awful.client.setslave(c)
  end

  if awesome.startup
    and not c.size_hints.user_position
    and not c.size_hints.program_position then
    -- Prevent clients from being unreachable after screen count changes.
    awful.placement.no_offscreen(c)
  end

  -- Set rounded corners for windows
  c.shape = helpers.rrect
end)

-- Set border color of focused client
client.connect_signal("focus", function (c)
  c.border_color = beautiful.border_focus
end)
client.connect_signal("unfocus", function (c)
  c.border_color = beautiful.border_normal
end)

-- Focus clients under mouse
require("awful.autofocus")
client.connect_signal("mouse::enter", function(c)
  c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)


-- ========================================
-- Misc.
-- ========================================

-- Reload config when screen geometry change
screen.connect_signal("property::geometry", awesome.restart)


-- Garbage collcetion for lower memory consumption
collectgarbage("setpause", 110)
collectgarbage("setstepmul", 1000)
