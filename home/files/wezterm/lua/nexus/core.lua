--- NEXUS v2 · core
--- Small, dependency-free helpers shared by every module.

local wezterm = require 'wezterm'

local M = {}

--------------------------------------------------------------------------------
-- Glyphs (all names verified against wezterm.nerdfonts)
--------------------------------------------------------------------------------

M.icons = {
  workspace = wezterm.nerdfonts.oct_table,
  folder    = wezterm.nerdfonts.md_folder,
  git       = wezterm.nerdfonts.oct_git_branch,
  clock     = wezterm.nerdfonts.md_clock,
  battery   = wezterm.nerdfonts.md_battery,
  charging  = wezterm.nerdfonts.fa_bolt,
  code      = wezterm.nerdfonts.fa_code,
  search    = wezterm.nerdfonts.md_magnify,
  layers    = wezterm.nerdfonts.md_layers,
  rocket    = wezterm.nerdfonts.cod_rocket,
  terminal  = wezterm.nerdfonts.cod_terminal,
  cog       = wezterm.nerdfonts.md_cog,
  sun       = wezterm.nerdfonts.md_weather_sunny,
  moon      = wezterm.nerdfonts.md_weather_night,
  tabs      = wezterm.nerdfonts.cod_multiple_windows,
  plus      = wezterm.nerdfonts.md_plus,
  palette   = wezterm.nerdfonts.md_palette,
  eye       = wezterm.nerdfonts.md_eye,
  lock      = wezterm.nerdfonts.cod_lock,
  divider_l = wezterm.nerdfonts.pl_right_soft_divider,
  divider_r = wezterm.nerdfonts.pl_left_soft_divider,
}

--------------------------------------------------------------------------------
-- Platform
--------------------------------------------------------------------------------

local triple = wezterm.target_triple or ''
M.is_macos   = triple:find('apple') ~= nil
M.is_windows = triple:find('windows') ~= nil
M.is_linux   = not M.is_macos and not M.is_windows

--------------------------------------------------------------------------------
-- String helpers
--------------------------------------------------------------------------------

--- POSIX/Windows agnostic basename.
function M.basename(value)
  if not value then
    return ''
  end
  local s = tostring(value)
  s = s:gsub('[/\\]+$', '')
  s = s:gsub('.*[/\\]', '')
  return s
end

--- Returns `basename, full_path` from a Pane or a PaneInformation snapshot.
function M.cwd_info(pane)
  if not pane then
    return '', ''
  end
  local cwd = pane.current_working_dir
  if not cwd and type(pane.get_current_working_dir) == 'function' then
    local ok, value = pcall(pane.get_current_working_dir, pane)
    if ok then
      cwd = value
    end
  end
  if not cwd then
    return '', ''
  end
  local path
  if type(cwd) == 'string' then
    path = cwd
  else
    -- Url object on modern WezTerm, plain string on older builds.
    path = cwd.file_path or cwd.path or ''
  end
  path = tostring(path)
  return M.basename(path), path
end

--- Foreground process name without its path.
function M.process_name(pane)
  if not pane then
    return ''
  end
  local name = pane.foreground_process_name
  if not name and type(pane.get_foreground_process_name) == 'function' then
    local ok, value = pcall(pane.get_foreground_process_name, pane)
    if ok then
      name = value
    end
  end
  if not name then
    return ''
  end
  return M.basename(name)
end

function M.truncate(text, width)
  if not text then
    return ''
  end
  return wezterm.truncate_right(tostring(text), math.max(4, width or 20))
end

--------------------------------------------------------------------------------
-- Format item helpers
--------------------------------------------------------------------------------

function M.fg(color)
  return { Foreground = { Color = color } }
end

function M.bg(color)
  return { Background = { Color = color } }
end

function M.text(value)
  return { Text = tostring(value) }
end

function M.bold()
  return { Attribute = { Intensity = 'Bold' } }
end

--------------------------------------------------------------------------------
-- Glue
--------------------------------------------------------------------------------

--- Emit a NEXUS-namespaced event from a keybinding / palette entry.
function M.emit(name)
  return wezterm.action.EmitEvent('nexus.' .. name)
end

--- Run a function without letting a missing API kill the whole config.
function M.safe(fn, ...)
  local ok, result = pcall(fn, ...)
  if ok then
    return result
  end
  return nil
end

return M
