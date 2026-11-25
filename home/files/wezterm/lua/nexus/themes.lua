--- NEXUS v2 · theme engine
--- Loads TOML palettes, picks day/night from OS appearance or actual sunrise,
--- and owns every per-window config override (theme, surface, focus mode).

local wezterm = require 'wezterm'
local core = require 'nexus.core'

local M = {}

local config_dir = wezterm.config_dir or '.'
local colors_dir = config_dir .. '/colors'
local order = { 'aura', 'daylight', 'nocturne' }

--------------------------------------------------------------------------------
-- Theme registry. Terminal colors come from colors/*.toml; UI colors live here.
--------------------------------------------------------------------------------

local defs = {
  aura = {
    name = 'Aura Glass',
    file = 'aura.toml',
    mode = 'dark',
    accent = '#67E8F9',
    accent2 = '#C9A7FF',
    muted = '#7487A8',
    bar = '#080D1A',
    surface = '#121B33',
    line = '#243250',
    opacity = 0.94,
    gradient = { '#0B1020', '#101B36', '#0A1226' },
    fallback = {
      ansi = { '#0B1020', '#FF7A93', '#7DE2B8', '#F5CE7A', '#7FB6FF', '#C9A7FF', '#67E8F9', '#E6EEFF' },
      brights = { '#2A3550', '#FF9DB0', '#A6F0CD', '#FFE1A3', '#A9CDFF', '#DFC7FF', '#A5F3FC', '#FFFFFF' },
      background = '#0B1020',
      foreground = '#D8E2F2',
    },
  },
  daylight = {
    name = 'Daylight Porcelain',
    file = 'daylight.toml',
    mode = 'light',
    accent = '#2F5BEA',
    accent2 = '#B4740B',
    muted = '#6B7891',
    bar = '#E9EDF6',
    surface = '#FFFFFF',
    line = '#CFD8E8',
    opacity = 0.97,
    gradient = { '#F4F6FB', '#E7EDF9', '#F8F9FD' },
    fallback = {
      ansi = { '#F4F6FB', '#D1495B', '#1E8F6B', '#B4740B', '#2F5BEA', '#8B4CC4', '#0E8DA6', '#1C2536' },
      brights = { '#D8DEEA', '#E86070', '#2AA37C', '#C98A1A', '#4C77F5', '#A165D8', '#1AA0BB', '#0B1220' },
      background = '#F4F6FB',
      foreground = '#1C2536',
    },
  },
  nocturne = {
    name = 'Nocturne Void',
    file = 'nocturne.toml',
    mode = 'dark',
    accent = '#B8F34A',
    accent2 = '#F15BB5',
    muted = '#7C8B7A',
    bar = '#030506',
    surface = '#0E1412',
    line = '#243226',
    opacity = 0.92,
    gradient = { '#05070A', '#0C1510', '#05070A' },
    fallback = {
      ansi = { '#05070A', '#FF4D6D', '#B8F34A', '#FFD166', '#4CC9F0', '#F15BB5', '#2DE2C5', '#F2F7EF' },
      brights = { '#2E3F31', '#FF8FA3', '#D4FF7A', '#FFE2A1', '#8ADDF8', '#FF9AD7', '#8CF5E4', '#FFFFFF' },
      background = '#05070A',
      foreground = '#E8F0E4',
    },
  },
}

local function build_theme(def)
  local path = colors_dir .. '/' .. def.file
  local colors

  if wezterm.color and wezterm.color.load_scheme then
    local ok, loaded = pcall(wezterm.color.load_scheme, path)
    if ok and type(loaded) == 'table' and loaded.background then
      colors = loaded
    end
  end
  if not colors then
    wezterm.log_warn('NEXUS: ' .. path .. ' could not be loaded; using built-in fallback')
    colors = def.fallback
  end

  -- Terminal palette is the TOML; the rest is derived from the theme definition.
  colors.tab_bar = {
    background = def.bar,
    active_tab = { bg_color = def.surface, fg_color = colors.foreground, intensity = 'Bold' },
    inactive_tab = { bg_color = def.bar, fg_color = def.muted },
    inactive_tab_hover = { bg_color = def.surface, fg_color = colors.foreground, italic = true },
    new_tab = { bg_color = def.bar, fg_color = def.accent },
    new_tab_hover = { bg_color = def.surface, fg_color = def.accent2, italic = true },
    inactive_tab_edge = def.line,
  }
  colors.split = def.line
  colors.scrollbar_thumb = def.line
  colors.compose_cursor = def.accent2
  colors.visual_bell = def.accent2

  def.colors = colors
  def.path = path
  def.window_frame = {
    active_titlebar_bg = def.bar,
    inactive_titlebar_bg = def.bar,
    active_titlebar_fg = colors.foreground,
    inactive_titlebar_fg = def.muted,
    active_titlebar_border_bottom = def.line,
    inactive_titlebar_border_bottom = def.line,
    button_fg = def.muted,
    button_bg = def.bar,
    button_hover_fg = colors.foreground,
    button_hover_bg = def.surface,
  }
  def.gradient = {
    orientation = { Linear = { angle = -35 } },
    colors = def.gradient,
    interpolation = 'Linear',
    blend = 'Oklab',
    noise = 24,
  }
end

--------------------------------------------------------------------------------
-- Day/night detection
--------------------------------------------------------------------------------

M.options = {}

local function os_appearance()
  if wezterm.gui and wezterm.gui.get_appearance then
    local ok, appearance = pcall(wezterm.gui.get_appearance)
    if ok and appearance then
      return appearance
    end
  end
  return 'Dark'
end

local function sun_up()
  local lat, lon = M.options.latitude, M.options.longitude
  if not lat or not lon or not wezterm.time then
    return nil
  end
  local ok, info = pcall(function()
    return wezterm.time.now():sun_times(lat, lon)
  end)
  if ok and type(info) == 'table' and type(info.up) == 'boolean' then
    return info.up
  end
  return nil
end

function M.auto_key()
  local up = sun_up()
  if up == true then
    return M.options.day_theme
  end
  if up == false then
    return M.options.night_theme
  end
  if os_appearance():find('Light') then
    return M.options.day_theme
  end
  return M.options.night_theme
end

--------------------------------------------------------------------------------
-- Per-window override manager
--------------------------------------------------------------------------------

local state = {}
local signatures = {}
local manual_key = nil

local opacity_levels = {
  { label = 'Glass', value = 0.90 },
  { label = 'Frost', value = 0.96 },
  { label = 'Solid', value = 1.00 },
}

local zen_padding = {
  left = '2cell',
  right = '2cell',
  top = '1cell',
  bottom = '0.5cell',
}

local function state_for(window)
  local id = window:window_id()
  if not state[id] then
    state[id] = {
      theme = manual_key or M.auto_key(),
      opacity = 1,
      zen = false,
    }
  end
  return state[id], id
end

local function toast(window, title, message)
  if not window then
    return
  end
  pcall(function()
    window:toast_notification(title, message, nil, 2200)
  end)
end

function M.sync_window(window)
  if not window then
    return
  end

  local s, id = state_for(window)
  local def = defs[s.theme] or defs.aura
  local current = core.safe(function()
    return window:get_config_overrides()
  end) or {}
  local next_overrides = {}

  for key, value in pairs(current) do
    next_overrides[key] = value
  end

  next_overrides.colors = def.colors
  next_overrides.window_frame = def.window_frame
  next_overrides.window_background_gradient = def.gradient

  local level = opacity_levels[s.opacity] or opacity_levels[1]
  next_overrides.window_background_opacity = s.zen and math.min(1, level.value + 0.04) or level.value

  if s.zen then
    next_overrides.enable_tab_bar = false
    next_overrides.window_padding = zen_padding
  else
    next_overrides.enable_tab_bar = nil
    next_overrides.window_padding = nil
  end

  local signature = table.concat({
    s.theme,
    tostring(s.opacity),
    tostring(s.zen),
    tostring(next_overrides.window_background_opacity),
  }, '|')

  if signatures[id] == signature then
    return
  end
  signatures[id] = signature
  window:set_config_overrides(next_overrides)
end

function M.sync_all()
  if not (wezterm.gui and wezterm.gui.gui_windows) then
    return
  end
  local windows = core.safe(wezterm.gui.gui_windows)
  if not windows then
    return
  end
  for _, window in ipairs(windows) do
    local s = state_for(window)
    s.theme = manual_key or M.auto_key()
    M.sync_window(window)
  end
end

--------------------------------------------------------------------------------
-- Commands used by keys.lua / commands.lua
--------------------------------------------------------------------------------

function M.set_theme(window, key)
  if not defs[key] then
    return
  end
  manual_key = key
  M.sync_all()
  if window then
    -- sync_all can be a no-op in the mux server; still update this window.
    state_for(window).theme = key
    M.sync_window(window)
  end
  toast(window, 'NEXUS // theme', defs[key].name)
end

function M.cycle_theme(window)
  local s = state_for(window)
  local index = 1
  for i, key in ipairs(order) do
    if key == s.theme then
      index = i
      break
    end
  end
  M.set_theme(window, order[(index % #order) + 1])
end

function M.reset_auto(window)
  manual_key = nil
  M.sync_all()
  local s = state_for(window)
  s.theme = M.auto_key()
  M.sync_window(window)
  toast(window, 'NEXUS // theme', 'Auto · ' .. defs[s.theme].name)
end

function M.cycle_opacity(window)
  local s = state_for(window)
  s.opacity = (s.opacity % #opacity_levels) + 1
  M.sync_window(window)
  toast(window, 'NEXUS // surface', opacity_levels[s.opacity].label)
end

function M.toggle_zen(window)
  local s = state_for(window)
  s.zen = not s.zen
  M.sync_window(window)
  toast(window, 'NEXUS // focus', s.zen and 'Zen mode on' or 'Zen mode off')
end

function M.current_key(window)
  return state_for(window).theme
end

function M.current_name(window)
  local def = defs[M.current_key(window)]
  return def and def.name or 'unknown'
end

function M.choices()
  local choices = {}
  for _, key in ipairs(order) do
    local def = defs[key]
    table.insert(choices, {
      id = key,
      label = def.name .. '  ·  ' .. def.mode,
    })
  end
  return choices
end

--------------------------------------------------------------------------------
-- Bootstrap
--------------------------------------------------------------------------------

function M.apply(config, options)
  M.options = options or {}
  M.options.day_theme = M.options.day_theme or 'daylight'
  M.options.night_theme = M.options.night_theme or 'aura'
  M.options.poll_seconds = M.options.poll_seconds or 300

  for _, key in ipairs(order) do
    build_theme(defs[key])
  end

  local initial_key = M.options.default_theme
  if not initial_key or initial_key == 'auto' or not defs[initial_key] then
    initial_key = M.auto_key()
  end
  M.options.default_theme = initial_key
  local initial = defs[initial_key]

  config.color_scheme_dirs = { colors_dir }
  config.colors = initial.colors
  config.window_frame = initial.window_frame
  config.window_background_gradient = initial.gradient
  config.window_background_opacity = initial.opacity
  config.text_background_opacity = 0.94

  if wezterm.add_to_config_reload_watch_list then
    for _, key in ipairs(order) do
      wezterm.add_to_config_reload_watch_list(defs[key].path)
    end
  end

  wezterm.on('window-config-reloaded', function(window)
    if not window then
      return
    end
    local s = state_for(window)
    if not manual_key then
      s.theme = M.auto_key()
    end
    M.sync_window(window)
  end)

  -- Sunrise/sunset are not events; poll gently and only when in auto mode.
  if wezterm.time and wezterm.time.call_after then
    local function schedule()
      wezterm.time.call_after(M.options.poll_seconds, function()
        if not manual_key then
          M.sync_all()
        end
        schedule()
      end)
    end
    schedule()
  end
end

return M
