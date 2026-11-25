--- NEXUS v2 · key system
--- Leader ALT+e. Legacy muscle memory kept; new modes and commands added.

local wezterm = require 'wezterm'
local act = wezterm.action
local core = require 'nexus.core'
local commands = require 'nexus.commands'

local M = {}

local function k(key, mods, action)
  return { key = key, mods = mods, action = action }
end

local function rename_tab_action()
  return act.PromptInputLine {
    description = wezterm.format {
      core.bold(),
      core.fg('Magenta'),
      core.text(core.icons.palette .. '  Rename tab > '),
    },
    action = wezterm.action_callback(function(window, _, line)
      if line and line ~= '' then
        window:active_tab():set_title(line)
      end
    end),
  }
end

--------------------------------------------------------------------------------
-- Key tables
--------------------------------------------------------------------------------

local function pop()
  return { key = 'Escape', action = 'PopKeyTable' }
end

local key_tables = {
  resize_pane = {
    { key = 'h', action = act.AdjustPaneSize { 'Left', 2 } },
    { key = 'j', action = act.AdjustPaneSize { 'Down', 1 } },
    { key = 'k', action = act.AdjustPaneSize { 'Up', 1 } },
    { key = 'l', action = act.AdjustPaneSize { 'Right', 2 } },
    { key = 'LeftArrow', action = act.AdjustPaneSize { 'Left', 2 } },
    { key = 'DownArrow', action = act.AdjustPaneSize { 'Down', 1 } },
    { key = 'UpArrow', action = act.AdjustPaneSize { 'Up', 1 } },
    { key = 'RightArrow', action = act.AdjustPaneSize { 'Right', 2 } },
    { key = '<', action = act.AdjustPaneSize { 'Left', 5 } },
    { key = '>', action = act.AdjustPaneSize { 'Right', 5 } },
    { key = '-', action = act.AdjustPaneSize { 'Down', 3 } },
    { key = '+', action = act.AdjustPaneSize { 'Up', 3 } },
    pop(),
    { key = 'Enter', action = 'PopKeyTable' },
  },

  move_tab = {
    { key = 'h', action = act.MoveTabRelative(-1) },
    { key = 'j', action = act.MoveTabRelative(-1) },
    { key = 'k', action = act.MoveTabRelative(1) },
    { key = 'l', action = act.MoveTabRelative(1) },
    { key = 'LeftArrow', action = act.MoveTabRelative(-1) },
    { key = 'RightArrow', action = act.MoveTabRelative(1) },
    pop(),
    { key = 'Enter', action = 'PopKeyTable' },
  },

  ['goto'] = {
    { key = 'w', action = commands.event('workspace-picker') },
    { key = 'n', action = commands.event('workspace-new') },
    { key = 't', action = act.ShowTabNavigator },
    { key = 'p', action = act.PaneSelect { alphabet = '1234567890' } },
    { key = 'c', action = act.ActivateCommandPalette },
    { key = 'l', action = act.ShowLauncher },
    { key = 's', action = commands.event('snippets') },
    { key = 'a', action = act.ActivateLastTab },
    pop(),
  },
}

--------------------------------------------------------------------------------
-- Bootstrap
--------------------------------------------------------------------------------

function M.apply(config)
  config.leader = { key = 'e', mods = 'ALT', timeout_milliseconds = 1500 }
  config.key_tables = key_tables

  local keys = {
    -- tmux-style escape hatch
    k('a', 'LEADER|CTRL', act.SendKey { key = 'a', mods = 'CTRL' }),

    -- navigation / discovery
    k('[', 'LEADER', act.ActivateCopyMode),
    k(':', 'LEADER', act.ActivateCommandPalette),
    k('/', 'LEADER', act.Search { CaseSensitiveString = '' }),
    k('K', 'LEADER', commands.event('clear-scrollback')),
    k('g', 'LEADER', act.ActivateKeyTable { name = 'goto', one_shot = false }),
    k('L', 'LEADER', commands.event('reload')),
    k('D', 'LEADER', commands.event('doctor')),
    k('d', 'LEADER', commands.event('debug')),

    -- tabs
    k('w', 'LEADER', act.ShowTabNavigator),
    k('c', 'LEADER', act.SpawnTab 'CurrentPaneDomain'),
    k('a', 'LEADER', act.ActivateLastTab),
    k('p', 'LEADER', act.ActivateTabRelative(-1)),
    k('n', 'LEADER', act.ActivateTabRelative(1)),
    k(',', 'LEADER', rename_tab_action()),
    k('.', 'LEADER', act.ActivateKeyTable { name = 'move_tab', one_shot = false }),
    k('m', 'LEADER', act.ActivateKeyTable { name = 'move_tab', one_shot = false }),

    -- panes
    k('q', 'LEADER', act.SplitVertical { domain = 'CurrentPaneDomain' }),
    k('W', 'LEADER', act.SplitHorizontal { domain = 'CurrentPaneDomain' }),
    k('%', 'LEADER', act.SplitHorizontal { domain = 'CurrentPaneDomain' }),
    k('"', 'LEADER', act.SplitVertical { domain = 'CurrentPaneDomain' }),
    k('h', 'LEADER', act.ActivatePaneDirection 'Left'),
    k('j', 'LEADER', act.ActivatePaneDirection 'Down'),
    k('k', 'LEADER', act.ActivatePaneDirection 'Up'),
    k('l', 'LEADER', act.ActivatePaneDirection 'Right'),
    k('LeftArrow', 'LEADER', act.ActivatePaneDirection 'Left'),
    k('DownArrow', 'LEADER', act.ActivatePaneDirection 'Down'),
    k('UpArrow', 'LEADER', act.ActivatePaneDirection 'Up'),
    k('RightArrow', 'LEADER', act.ActivatePaneDirection 'Right'),
    k('Space', 'LEADER', act.RotatePanes 'Clockwise'),
    k('z', 'LEADER', act.TogglePaneZoomState),
    k('x', 'LEADER', act.CloseCurrentPane { confirm = true }),
    k('X', 'LEADER', act.CloseCurrentTab { confirm = true }),
    k('!', 'LEADER|SHIFT', wezterm.action_callback(function(_, pane)
      if pane then
        pcall(pane.move_to_new_tab, pane)
      end
    end)),
    k('r', 'LEADER', act.ActivateKeyTable { name = 'resize_pane', one_shot = false }),

    -- workspaces
    k('s', 'LEADER', act.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' }),
    k('S', 'LEADER', commands.event('workspace-picker')),
    k('N', 'LEADER', commands.event('workspace-new')),
    k('R', 'LEADER', commands.event('workspace-rename')),

    -- NEXUS systems
    k('t', 'LEADER', commands.event('theme-picker')),
    k('T', 'LEADER', commands.event('theme-next')),
    k('o', 'LEADER', commands.event('opacity')),
    k('f', 'LEADER', commands.event('zen')),
    k('u', 'LEADER', commands.event('snippets')),
    k('F', 'LEADER', act.ToggleFullScreen),
    k('B', 'LEADER', act.ShowLauncher),

    -- font / zoom
    k('=', 'LEADER', act.IncreaseFontSize),
    k('-', 'LEADER', act.DecreaseFontSize),
    k('0', 'LEADER', act.ResetFontSize),
  }

  for i = 1, 9 do
    table.insert(keys, k(tostring(i), 'LEADER', act.ActivateTab(i - 1)))
  end

  config.keys = keys

  -- Middle-click paste from the primary selection on X11/Wayland.
  config.mouse_bindings = {
    {
      event = { Down = { streak = 1, button = 'Middle' } },
      action = act.PasteFrom 'PrimarySelection',
    },
  }
end

return M
