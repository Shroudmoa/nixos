--- NEXUS v2 — a next-generation WezTerm configuration.
---
--- Everything lives in lua/nexus/*.lua; this file is only the boot sequence.
--- The previous config is preserved as wezterm.classic.lua.
---
--- Quick start: ALT+e then ? (command palette), t (theme), f (zen), g (goto).

local wezterm = require 'wezterm'

-- Be explicit: WezTerm adds the config dir to package.path on recent builds,
-- but this keeps local modules findable everywhere.
local dir = wezterm.config_dir or '.'
package.path = dir .. '/lua/?.lua;' .. dir .. '/lua/?/init.lua;' .. package.path

local nexus = require 'nexus'
local config = wezterm.config_builder()

---@type table<string, any>
local options = {
  -- Shell. Set to your preferred shell; falls back to $SHELL when not found.
  shell = 'fish',

  -- Typography. A Nerd Font is recommended for the tab glyphs.
  font_family = 'JetBrainsMono Nerd Font Mono',
  font_size = 13.0,

  -- Theme engine. With coordinates, day/night follows real sunrise/sunset.
  -- Without coordinates, it follows the OS dark/light appearance.
  latitude = nil,
  longitude = nil,
  day_theme = 'daylight',
  night_theme = 'aura',
  default_theme = 'auto', -- 'auto' | 'aura' | 'daylight' | 'nocturne'
  poll_seconds = 300,
}

nexus.apply(config, options)

return config
