--- NEXUS v2 · commands
--- Command palette entries, launcher recipes and every namespaced action.

local wezterm = require 'wezterm'
local act = wezterm.action
local core = require 'nexus.core'
local themes = require 'nexus.themes'

local M = {}

function M.event(name)
  return act.EmitEvent('nexus.' .. name)
end

local function on(name, fn)
  wezterm.on('nexus.' .. name, fn)
end

local function rename_tab_action()
  return act.PromptInputLine {
    description = wezterm.format {
      core.bold(),
      core.fg('Magenta'),
      core.text(wezterm.nerdfonts.md_palette .. '  Rename tab  '),
      core.fg('Yellow'),
      core.text('> '),
    },
    action = wezterm.action_callback(function(window, _, line)
      if line and line ~= '' then
        window:active_tab():set_title(line)
      end
    end),
  }
end

local function workspace_choices()
  return {
    { id = 'main',  label = core.icons.workspace .. '  main' },
    { id = 'code',  label = core.icons.code .. '  code' },
    { id = 'ops',   label = core.icons.cog .. '  ops' },
    { id = 'notes', label = core.icons.layers .. '  notes' },
  }
end

local function snippet_choices()
  return {
    { id = 'git status\n',        label = core.icons.git .. '  git status' },
    { id = 'git log --oneline -20\n', label = core.icons.git .. '  git log --oneline -20' },
    { id = 'btop\n',              label = core.icons.charging .. '  btop' },
    { id = 'hx .\n',              label = core.icons.code .. '  hx .' },
    { id = 'ls -lah\n',           label = core.icons.folder .. '  ls -lah' },
    { id = 'clear\n',             label = core.icons.search .. '  clear' },
  }
end

function M.apply(config, options)
  options = options or {}
  local shell = options.shell or 'fish'

  ------------------------------------------------------------------------------
  -- Launcher / command palette recipes
  ------------------------------------------------------------------------------

  config.launch_menu = {
    { label = core.icons.terminal .. '  Shell', args = { shell } },
    { label = core.icons.code .. '  Editor (hx .)', args = { 'hx', '.' } },
    { label = core.icons.charging .. '  System monitor (btop)', args = { 'btop' } },
    { label = core.icons.git .. '  Git log (this directory)', args = { 'git', 'log', '--oneline', '--graph', '-20' } },
    { label = core.icons.search .. '  WezTerm version', args = { 'wezterm', '--version' } },
  }

  ------------------------------------------------------------------------------
  -- Commands
  ------------------------------------------------------------------------------

  on('theme-picker', function(window, pane)
    if not window then
      return
    end
    window:perform_action(act.InputSelector {
      title = core.icons.palette .. '  NEXUS // THEME',
      description = 'Select a palette · Esc cancels',
      fuzzy = true,
      choices = themes.choices(),
      action = wezterm.action_callback(function(win, _, id)
        if id then
          themes.set_theme(win, id)
        end
      end),
    }, pane)
  end)

  on('theme-next', function(window)
    themes.cycle_theme(window)
  end)

  on('theme-auto', function(window)
    themes.reset_auto(window)
  end)

  on('opacity', function(window)
    themes.cycle_opacity(window)
  end)

  on('zen', function(window)
    themes.toggle_zen(window)
  end)

  on('workspace-picker', function(window, pane)
    if not window then
      return
    end
    window:perform_action(act.InputSelector {
      title = core.icons.workspace .. '  NEXUS // WORKSPACE',
      fuzzy = true,
      choices = workspace_choices(),
      action = wezterm.action_callback(function(win, pn, id)
        if id then
          win:perform_action(act.SwitchToWorkspace { name = id }, pn)
        end
      end),
    }, pane)
  end)

  on('workspace-new', function(window, pane)
    if not window then
      return
    end
    window:perform_action(act.PromptInputLine {
      description = 'New workspace name > ',
      action = wezterm.action_callback(function(win, pn, line)
        if line and line ~= '' then
          win:perform_action(act.SwitchToWorkspace { name = line }, pn)
        end
      end),
    }, pane)
  end)

  on('workspace-rename', function(window)
    if not window or not wezterm.mux then
      return
    end
    local current = window:active_workspace()
    window:perform_action(act.PromptInputLine {
      description = 'Rename current workspace > ',
      initial_value = current,
      action = wezterm.action_callback(function(_, _, line)
        if line and line ~= '' and wezterm.mux.rename_workspace then
          pcall(wezterm.mux.rename_workspace, current, line)
        end
      end),
    }, window:active_pane())
  end)

  on('snippets', function(window, pane)
    if not window then
      return
    end
    window:perform_action(act.InputSelector {
      title = core.icons.rocket .. '  NEXUS // SNIPPETS',
      fuzzy = true,
      choices = snippet_choices(),
      action = wezterm.action_callback(function(_, pn, id)
        if id then
          pn:send_text(id)
        end
      end),
    }, pane)
  end)

  on('doctor', function(window)
    if not window then
      return
    end
    local message = table.concat({
      'WezTerm  ' .. tostring(wezterm.version),
      'Theme    ' .. themes.current_name(window),
      'Shell    ' .. tostring(options.shell),
      'Config   ' .. tostring(wezterm.config_dir),
      'Target   ' .. tostring(wezterm.target_triple),
    }, '\n')
    pcall(function()
      window:toast_notification('NEXUS v2 · system check', message, nil, 5000)
    end)
  end)

  on('reload', function(window)
    pcall(wezterm.reload_configuration)
    if window then
      pcall(function()
        window:toast_notification('NEXUS v2', 'configuration reloaded', nil, 1800)
      end)
    end
  end)

  on('pane-to-tab', function(_, pane)
    if pane then
      pcall(pane.move_to_new_tab, pane)
    end
  end)

  on('clear-scrollback', function(window, pane)
    if window then
      window:perform_action(act.ClearScrollback 'ScrollbackOnly', pane)
    end
  end)

  on('debug', function(window, pane)
    if window then
      window:perform_action(act.ShowDebugOverlay, pane)
    end
  end)

  on('rename-tab', function(window, pane)
    if window then
      window:perform_action(rename_tab_action(), pane)
    end
  end)

  ------------------------------------------------------------------------------
  -- Command palette additions (synchronous by contract)
  ------------------------------------------------------------------------------

  wezterm.on('augment-command-palette', function()
    return {
      {
        brief = 'NEXUS: Theme picker',
        doc = 'Choose between Aura Glass, Daylight Porcelain and Nocturne Void',
        icon = 'md_palette',
        action = M.event('theme-picker'),
      },
      {
        brief = 'NEXUS: Next theme',
        doc = 'Cycle to the next palette and pin it for this session',
        icon = 'md_weather_sunny',
        action = M.event('theme-next'),
      },
      {
        brief = 'NEXUS: Auto theme',
        doc = 'Return to OS appearance / sunrise based theme selection',
        icon = 'md_cog',
        action = M.event('theme-auto'),
      },
      {
        brief = 'NEXUS: Zen mode',
        doc = 'Hide the tab bar and widen the padding for distraction-free work',
        icon = 'md_eye',
        action = M.event('zen'),
      },
      {
        brief = 'NEXUS: Surface opacity',
        doc = 'Cycle Glass / Frost / Solid window opacity',
        icon = 'md_layers',
        action = M.event('opacity'),
      },
      {
        brief = 'NEXUS: Workspace picker',
        doc = 'Jump to or create a named workspace',
        icon = 'oct_table',
        action = M.event('workspace-picker'),
      },
      {
        brief = 'NEXUS: New workspace',
        doc = 'Prompt for a new workspace name',
        icon = 'md_plus',
        action = M.event('workspace-new'),
      },
      {
        brief = 'NEXUS: Rename workspace',
        doc = 'Rename the workspace containing this window',
        icon = 'md_pencil',
        action = M.event('workspace-rename'),
      },
      {
        brief = 'NEXUS: Command snippets',
        doc = 'Send a frequently used command to the active pane',
        icon = 'cod_rocket',
        action = M.event('snippets'),
      },
      {
        brief = 'NEXUS: Rename tab',
        doc = 'Set an explicit title for the current tab',
        icon = 'md_rename_box',
        action = rename_tab_action(),
      },
      {
        brief = 'NEXUS: System check',
        doc = 'Show version, active theme, shell and config directory',
        icon = 'md_eye',
        action = M.event('doctor'),
      },
      {
        brief = 'NEXUS: Reload configuration',
        doc = 'Re-read wezterm.lua and all modules',
        icon = 'cod_debug_restart',
        action = M.event('reload'),
      },
    }
  end)
end

return M
