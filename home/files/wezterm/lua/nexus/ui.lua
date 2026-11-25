--- NEXUS v2 · UI layer
--- Powerline-flavoured tabs, process-aware titles and a live status line.

local wezterm = require 'wezterm'
local core = require 'nexus.core'

local M = {}

local process_icons = {
  fish  = core.icons.terminal,
  bash  = core.icons.terminal,
  zsh   = core.icons.terminal,
  sh    = core.icons.terminal,
  nvim  = core.icons.code,
  vim   = core.icons.code,
  hx    = core.icons.code,
  helix = core.icons.code,
  git   = core.icons.git,
  btop  = core.icons.charging,
  top   = core.icons.charging,
  ssh   = core.icons.lock,
}

local function icon_for(process)
  return process_icons[process] or core.icons.terminal
end

local function tab_title(tab)
  if tab.tab_title and #tab.tab_title > 0 then
    return tab.tab_title
  end
  if tab.active_pane and tab.active_pane.title then
    return tab.active_pane.title
  end
  return 'shell'
end

local function progress_items(pane)
  local progress = pane and pane.progress
  if not progress or progress == 'None' then
    return {}
  end
  if type(progress) == 'table' then
    if progress.Percentage then
      return { core.fg('#7DE2B8'), core.text(' ' .. progress.Percentage .. '%') }
    elseif progress.Error ~= nil then
      return { core.fg('#FF7A93'), core.text(' !') }
    end
  end
  return { core.fg('#F5CE7A'), core.text(' ~') }
end

--------------------------------------------------------------------------------
-- Git branch cache (run_child_process is not allowed in synchronous callbacks,
-- so this only runs from the periodic update-status event).
--------------------------------------------------------------------------------

local git_cache = { key = '', branch = '', at = 0 }

local function git_branch(full_cwd)
  if not full_cwd or full_cwd == '' then
    return ''
  end
  local now = os.time()
  if git_cache.key == full_cwd and now - git_cache.at < 5 then
    return git_cache.branch
  end

  local branch = ''
  local ok, success, stdout = pcall(wezterm.run_child_process, {
    'git', '-C', full_cwd, 'rev-parse', '--abbrev-ref', 'HEAD',
  })
  if ok and success and stdout then
    branch = stdout:gsub('%s+$', '')
    if branch == 'HEAD' then
      branch = ''
    end
  end

  git_cache.key = full_cwd
  git_cache.branch = branch
  git_cache.at = now
  return branch
end

local battery_cache = { value = '', at = 0 }

local function battery_status()
  local now = os.time()
  if now - battery_cache.at < 20 then
    return battery_cache.value
  end

  local result = ''
  local ok, batteries = pcall(wezterm.battery_info)
  if ok and batteries then
    for _, b in ipairs(batteries) do
      local pct = math.floor((b.state_of_charge or 0) * 100 + 0.5)
      local icon = b.state == 'Charging' and core.icons.charging or core.icons.battery
      result = string.format('%s %d%%', icon, pct)
      break
    end
  end

  battery_cache.value = result
  battery_cache.at = now
  return result
end

--------------------------------------------------------------------------------
-- Events
--------------------------------------------------------------------------------

function M.apply(config)
  config.status_update_interval = 1000

  wezterm.on('format-tab-title', function(tab, _, _, conf, hover, max_width)
    local tab_colors = (conf.colors and conf.colors.tab_bar) or {}
    local frame = conf.window_frame or {}
    local bar_bg = tab_colors.background or frame.active_titlebar_bg or '#000000'

    local style = tab_colors.inactive_tab or {}
    if tab.is_active then
      style = tab_colors.active_tab or style
    elseif hover then
      style = tab_colors.inactive_tab_hover or style
    end

    local bg = style.bg_color or bar_bg
    local fg = style.fg_color or '#FFFFFF'
    local accent = (conf.colors and conf.colors.cursor_bg) or fg
    local pane = tab.active_pane
    local process = core.process_name(pane)
    local title = core.truncate(tab_title(tab), math.max(8, (max_width or 26) - 10))

    local unseen = false
    for _, p in ipairs(tab.panes or {}) do
      if p.has_unseen_output then
        unseen = true
        break
      end
    end

    local items = {
      core.bg(bar_bg), core.fg(bg), core.text(core.icons.divider_l),
      core.bg(bg), core.fg(accent), core.text(string.format(' %d ', tab.tab_index + 1)),
      core.fg(fg), core.text(icon_for(process) .. ' '),
    }

    for _, item in ipairs(progress_items(pane)) do
      table.insert(items, item)
    end

    if unseen and not tab.is_active then
      table.insert(items, core.fg(accent))
      table.insert(items, core.text(' •'))
    end

    table.insert(items, core.fg(fg))
    table.insert(items, core.text(' ' .. title .. ' '))

    if pane and pane.is_zoomed then
      table.insert(items, core.fg(accent))
      table.insert(items, core.text(core.icons.eye .. ' '))
    end

    table.insert(items, core.bg(bar_bg))
    table.insert(items, core.fg(bg))
    table.insert(items, core.text(core.icons.divider_r))

    return items
  end)

  wezterm.on('format-window-title', function(_, pane)
    local short_cwd = core.cwd_info(pane)
    local process = core.process_name(pane)
    local workspace = ''

    if wezterm.mux and wezterm.mux.get_active_workspace then
      local ok, name = pcall(wezterm.mux.get_active_workspace)
      if ok and name and name ~= '' then
        workspace = name .. ' · '
      end
    end

    return workspace .. (short_cwd ~= '' and (short_cwd .. ' · ') or '') .. (process ~= '' and process or 'wezterm')
  end)

  wezterm.on('update-status', function(window, pane)
    if not window or not pane then
      return
    end

    local effective = core.safe(function()
      return window:effective_config()
    end) or {}
    local colors = effective.colors or {}
    local tab_colors = colors.tab_bar or {}
    local accent = colors.cursor_bg or '#67E8F9'
    local accent2 = colors.cursor_border or accent
    local inactive = tab_colors.inactive_tab or {}
    local muted = inactive.fg_color or '#7487A8'

    -- left: mode / workspace / git branch
    local mode = window:active_workspace() or 'main'
    local mode_color = accent
    local key_table = window:active_key_table()
    if key_table then
      mode = key_table:upper()
      mode_color = accent2
    elseif window:leader_is_active() then
      mode = 'LDR'
      mode_color = accent2
    end

    local left = {
      core.fg(accent), core.text(' ' .. core.icons.workspace .. ' '),
      core.fg(mode_color), core.text(core.truncate(mode, 22) .. ' '),
    }

    local short_cwd, full_cwd = core.cwd_info(pane)
    local branch = git_branch(full_cwd)
    if branch ~= '' then
      table.insert(left, core.fg(muted))
      table.insert(left, core.text('│'))
      table.insert(left, core.fg(accent2))
      table.insert(left, core.text(core.icons.git .. ' ' .. core.truncate(branch, 20)))
    end
    table.insert(left, core.text(' '))
    window:set_left_status(wezterm.format(left))

    -- right: battery / clock / cwd / foreground process
    local process = core.process_name(pane)
    local right = {}

    local bat = battery_status()
    if bat ~= '' then
      table.insert(right, core.fg(accent2))
      table.insert(right, core.text(bat .. ' '))
    end

    table.insert(right, core.fg(muted))
    table.insert(right, core.text(core.icons.clock .. ' ' .. wezterm.strftime('%H:%M')))
    table.insert(right, core.fg(muted))
    table.insert(right, core.text(' │ '))
    table.insert(right, core.fg(accent))
    table.insert(right, core.text(short_cwd ~= '' and short_cwd or '~'))

    if process ~= '' then
      table.insert(right, core.fg(muted))
      table.insert(right, core.text(' │ '))
      table.insert(right, core.fg(accent2))
      table.insert(right, core.text(icon_for(process) .. ' ' .. core.truncate(process, 16)))
    end

    table.insert(right, core.text(' '))
    window:set_right_status(wezterm.format(right))
  end)
end

return M
