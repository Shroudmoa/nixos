--- NEXUS v2 · orchestrator
--- One entry point, small modules, zero network dependencies.

local wezterm = require 'wezterm'

local core = require 'nexus.core'
local themes = require 'nexus.themes'
local commands = require 'nexus.commands'
local keys = require 'nexus.keys'
local ui = require 'nexus.ui'

local M = {}

local defaults = {
  shell = 'fish',
  font_family = 'JetBrainsMono Nerd Font Mono',
  font_size = 13.0,
  latitude = nil,
  longitude = nil,
  day_theme = 'daylight',
  night_theme = 'aura',
  default_theme = 'auto',
  poll_seconds = 300,
}

local function option(user, name)
  if user and user[name] ~= nil then
    return user[name]
  end
  return defaults[name]
end

local function resolve_shell(preferred)
  local candidates = {
    '/usr/bin/' .. preferred,
    '/usr/local/bin/' .. preferred,
    '/bin/' .. preferred,
    '/opt/homebrew/bin/' .. preferred,
    wezterm.home_dir .. '/.local/bin/' .. preferred,
  }
  for _, path in ipairs(candidates) do
    local ok, matches = pcall(wezterm.glob, path)
    if ok and matches and #matches > 0 then
      return path
    end
  end

  -- Last resort: whatever the user's login shell is, then POSIX sh.
  local env_shell = os.getenv and os.getenv('SHELL') or nil
  if env_shell and env_shell ~= '' then
    return env_shell
  end
  return '/bin/sh'
end

function M.apply(config, user)
  user = user or {}

  local options = {
    shell = resolve_shell(option(user, 'shell')),
    font_family = option(user, 'font_family'),
    font_size = option(user, 'font_size'),
    latitude = option(user, 'latitude'),
    longitude = option(user, 'longitude'),
    day_theme = option(user, 'day_theme'),
    night_theme = option(user, 'night_theme'),
    default_theme = option(user, 'default_theme'),
    poll_seconds = option(user, 'poll_seconds'),
  }

  ------------------------------------------------------------------------------
  -- Theme, commands, keys and UI modules own their config sections
  ------------------------------------------------------------------------------
  themes.apply(config, options)
  commands.apply(config, options)
  keys.apply(config)
  ui.apply(config)

  ------------------------------------------------------------------------------
  -- Program & environment
  ------------------------------------------------------------------------------
  config.default_prog = { options.shell }
  config.default_workspace = 'main'
  config.set_environment_variables = {
    NEXUS_CONFIG = 'v2',
    COLORTERM = 'truecolor',
  }

  ------------------------------------------------------------------------------
  -- Typography
  ------------------------------------------------------------------------------
  config.font = wezterm.font_with_fallback({
    { family = options.font_family, weight = 'Regular' },
    { family = 'JetBrains Mono', weight = 'Regular' },
    { family = 'Noto Sans Mono CJK SC' },
    { family = 'Twemoji Mono' },
  })
  config.font_size = options.font_size
  config.line_height = 1.15
  config.cell_width = 1.02
  config.harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1', 'ss01=1', 'zero=1' }
  config.font_rules = {
    {
      italic = true,
      intensity = 'Normal',
      font = wezterm.font_with_fallback({
        { family = options.font_family, italic = true },
      }),
    },
    {
      intensity = 'Bold',
      font = wezterm.font_with_fallback({
        { family = options.font_family, weight = 'Bold' },
      }),
    },
  }
  config.adjust_window_size_when_changing_font_size = false
  config.command_palette_font_size = options.font_size
  config.command_palette_rows = 14

  ------------------------------------------------------------------------------
  -- Terminal behaviour
  ------------------------------------------------------------------------------
  config.term = 'wezterm'
  config.enable_kitty_keyboard = true
  config.scrollback_lines = 25000
  config.scroll_to_bottom_on_input = true
  config.enable_scroll_bar = false
  config.pane_focus_follows_mouse = false
  config.inactive_pane_hsb = { saturation = 0.78, brightness = 0.82 }
  config.default_cursor_style = 'BlinkingBar'
  config.cursor_blink_rate = 900
  config.cursor_thickness = 2
  config.visual_bell = {
    fade_in_duration_ms = 90,
    fade_out_duration_ms = 260,
    target = 'CursorColor',
  }
  config.automatically_reload_config = true
  config.window_close_confirmation = 'AlwaysPrompt'
  config.exit_behavior = 'Close'
  config.max_fps = 60
  config.animation_fps = 60

  ------------------------------------------------------------------------------
  -- Window chrome
  ------------------------------------------------------------------------------
  config.window_decorations = 'RESIZE'
  config.window_padding = {
    left = '1cell',
    right = '1cell',
    top = '0.6cell',
    bottom = '0.3cell',
  }
  config.use_fancy_tab_bar = true
  config.tab_bar_at_bottom = true
  config.tab_max_width = 32
  config.show_new_tab_button_in_tab_bar = true
  config.show_tab_index_in_tab_bar = false
  config.mouse_wheel_scrolls_tabs = false

  -- Glass, per platform. The gradient comes from the active theme.
  if core.is_macos then
    config.macos_window_background_blur = 28
  elseif core.is_windows then
    config.win32_system_backdrop = 'Acrylic'
  else
    config.wayland_window_background_blur = true
  end

  return config
end

return M
