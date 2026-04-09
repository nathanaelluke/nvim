
-- I will not cap, this is all AI generated.
-- However, I no longer need the obsidian client at all.

local uv = vim.uv or vim.loop

local AUTO_SYNC_GROUP = vim.api.nvim_create_augroup("obsidian_git_auto_sync", { clear = true })
local IDLE_SYNC_MS = 5000
local PERIODIC_PULL_MS = 10 * 60 * 1000

local state = {
  active_workspace = nil,
  synced_workspaces = {},
  sync_timer = nil,
  sync_running = false,
  paused = false,
  last_pull_at = {},
}

local function notify(message, level)
  vim.schedule(function()
    vim.notify(message, level or vim.log.levels.INFO)
  end)
end

local function normalize_dir(path)
  if not path or path == "" then
    return nil
  end

  if type(path) == "table" then
    if path.filename then
      path = path.filename
    else
      path = tostring(path)
    end
  end

  return vim.fs.normalize(path):gsub("/+$", "")
end

local function is_path_in_dir(path, dir)
  path = normalize_dir(path)
  dir = normalize_dir(dir)

  if not path or not dir then
    return false
  end

  return path == dir or vim.startswith(path, dir .. "/")
end

local function stop_timer()
  if state.sync_timer then
    state.sync_timer:stop()
    state.sync_timer:close()
    state.sync_timer = nil
  end
end

local function run_git(args, cwd, on_exit)
  if vim.fn.executable("git") ~= 1 then
    notify("Obsidian Git sync: git executable not found", vim.log.levels.ERROR)
    return
  end

  local cmd = { "git" }
  vim.list_extend(cmd, args)

  vim.system(cmd, { cwd = cwd, text = true }, function(result)
    vim.schedule(function()
      on_exit(result)
    end)
  end)
end

local function repo_has_changes(cwd, on_result)
  run_git({ "status", "--porcelain" }, cwd, function(result)
    if result.code ~= 0 then
      on_result(false, result)
      return
    end

    on_result((result.stdout or ""):match("%S") ~= nil, result)
  end)
end

local function repo_is_blocked(cwd, on_result)
  run_git({ "rev-parse", "--git-dir" }, cwd, function(result)
    if result.code ~= 0 then
      on_result(true, "Unable to inspect git directory")
      return
    end

    local git_dir = normalize_dir(result.stdout)
    if not git_dir then
      on_result(true, "Unable to determine git directory")
      return
    end

    local markers = {
      rebase_apply = git_dir .. "/rebase-apply",
      rebase_merge = git_dir .. "/rebase-merge",
      merge_head = git_dir .. "/MERGE_HEAD",
      cherry_pick_head = git_dir .. "/CHERRY_PICK_HEAD",
    }

    for name, marker in pairs(markers) do
      if uv.fs_stat(marker) then
        on_result(true, name)
        return
      end
    end

    on_result(false)
  end)
end

local function pause_automation(message)
  state.paused = true
  stop_timer()
  notify(message, vim.log.levels.ERROR)
end

local function mark_pull(cwd)
  cwd = normalize_dir(cwd)
  if cwd then
    state.last_pull_at[cwd] = uv.now()
  end
end

local function pull_is_due(cwd)
  cwd = normalize_dir(cwd)
  if not cwd then
    return false
  end

  local last_pull_at = state.last_pull_at[cwd]
  if not last_pull_at then
    return true
  end

  return (uv.now() - last_pull_at) >= PERIODIC_PULL_MS
end

local function sync_workspace(cwd, reason)
  cwd = normalize_dir(cwd)
  if not cwd or state.paused or state.sync_running then
    return
  end

  state.sync_running = true

  local function finish()
    state.sync_running = false
  end

  local function fail(message)
    finish()
    pause_automation(message)
  end

  repo_is_blocked(cwd, function(blocked, marker)
    if blocked then
      fail("Obsidian Git sync paused: repository needs manual attention (" .. marker .. ")")
      return
    end

    repo_has_changes(cwd, function(has_changes, status_result)
      if status_result.code ~= 0 then
        fail("Obsidian Git sync paused: unable to read git status")
        return
      end

      if not has_changes then
        finish()
        return
      end

      run_git({ "add", "-A" }, cwd, function(add_result)
        if add_result.code ~= 0 then
          fail("Obsidian Git sync paused: git add failed")
          return
        end

        local commit_message = string.format(
          "obsidian autosync %s",
          os.date("%Y-%m-%d %H:%M:%S")
        )

        run_git({ "commit", "-m", commit_message }, cwd, function(commit_result)
          if commit_result.code ~= 0 then
            local stderr = commit_result.stderr or ""
            if stderr:match("nothing to commit") then
              finish()
              return
            end

            fail("Obsidian Git sync paused: git commit failed")
            return
          end

          run_git({ "push" }, cwd, function(push_result)
            if push_result.code == 0 then
              finish()
              return
            end

            run_git({ "fetch" }, cwd, function(fetch_result)
              if fetch_result.code ~= 0 then
                fail("Obsidian Git sync paused: git fetch failed after push rejection")
                return
              end

              run_git({ "pull", "--rebase" }, cwd, function(pull_result)
                if pull_result.code ~= 0 then
                  fail("Obsidian Git sync paused: git pull --rebase failed after push rejection")
                  return
                end

                run_git({ "push" }, cwd, function(retry_push_result)
                  if retry_push_result.code ~= 0 then
                    fail("Obsidian Git sync paused: git push failed after retry")
                    return
                  end

                  finish()
                end)
              end)
            end)
          end)
        end)
      end)
    end)
  end)
end

local function schedule_sync(cwd, reason)
  cwd = normalize_dir(cwd)
  if not cwd or state.paused then
    return
  end

  stop_timer()

  state.sync_timer = assert(uv.new_timer())
  state.sync_timer:start(
    IDLE_SYNC_MS,
    0,
    vim.schedule_wrap(function()
      stop_timer()
      sync_workspace(cwd, reason)
    end)
  )
end

local function initial_pull(cwd)
  cwd = normalize_dir(cwd)
  if not cwd or state.paused or state.synced_workspaces[cwd] then
    return
  end

  run_git({ "fetch" }, cwd, function(fetch_result)
    if fetch_result.code ~= 0 then
      pause_automation("Obsidian Git sync paused: initial git fetch failed")
      return
    end

    run_git({ "pull", "--rebase" }, cwd, function(pull_result)
      if pull_result.code ~= 0 then
        pause_automation("Obsidian Git sync paused: initial git pull --rebase failed")
        return
      end

      state.synced_workspaces[cwd] = true
      mark_pull(cwd)
    end)
  end)
end

local function periodic_pull(cwd)
  cwd = normalize_dir(cwd)
  if not cwd or state.paused or state.sync_running or not pull_is_due(cwd) then
    return
  end

  state.sync_running = true

  local function finish()
    state.sync_running = false
  end

  local function fail(message)
    finish()
    pause_automation(message)
  end

  repo_is_blocked(cwd, function(blocked, marker)
    if blocked then
      fail("Obsidian Git sync paused: repository needs manual attention (" .. marker .. ")")
      return
    end

    run_git({ "fetch" }, cwd, function(fetch_result)
      if fetch_result.code ~= 0 then
        fail("Obsidian Git sync paused: periodic git fetch failed")
        return
      end

      run_git({ "pull", "--rebase" }, cwd, function(pull_result)
        if pull_result.code ~= 0 then
          fail("Obsidian Git sync paused: periodic git pull --rebase failed")
          return
        end

        mark_pull(cwd)
        finish()
      end)
    end)
  end)
end

local function workspace_root_for_path(path)
  local workspace = state.active_workspace
  if not workspace or not workspace.root then
    return nil
  end

  if not is_path_in_dir(path, workspace.root) then
    return nil
  end

  return normalize_dir(workspace.root)
end

local function setup_git_autocmds()
  vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    group = AUTO_SYNC_GROUP,
    callback = function(ev)
      local path = vim.api.nvim_buf_get_name(ev.buf)
      local cwd = workspace_root_for_path(path)
      if cwd then
        schedule_sync(cwd, "buf_write")
      end
    end,
  })

  vim.api.nvim_create_autocmd({ "FocusLost", "VimLeavePre" }, {
    group = AUTO_SYNC_GROUP,
    callback = function()
      local workspace = state.active_workspace
      if workspace and workspace.root then
        stop_timer()
        sync_workspace(workspace.root, "session_end")
      end
    end,
  })

  vim.api.nvim_create_autocmd({ "FocusGained" }, {
    group = AUTO_SYNC_GROUP,
    callback = function()
      local workspace = state.active_workspace
      if workspace and workspace.root then
        periodic_pull(workspace.root)
      end
    end,
  })
end

local function setup_git_commands()
  vim.api.nvim_create_user_command("ObsidianGitResume", function()
    state.paused = false
    notify("Obsidian Git sync resumed")

    local workspace = state.active_workspace
    if workspace and workspace.root then
      initial_pull(workspace.root)
    end
  end, {})

  vim.api.nvim_create_user_command("ObsidianGitSyncNow", function()
    local workspace = state.active_workspace
    if not workspace or not workspace.root then
      notify("Obsidian Git sync: no active Obsidian workspace", vim.log.levels.WARN)
      return
    end

    stop_timer()
    sync_workspace(workspace.root, "manual")
  end, {})
end

setup_git_autocmds()
setup_git_commands()

return {
  {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = true,
    ft = "markdown",
    cmd = {
      "ObsidianNew",
      "ObsidianToday",
      "ObsidianTomorrow",
      "ObsidianYesterday",
      "ObsidianQuickSwitch",
      "ObsidianSearch",
      "ObsidianOpen",
      "ObsidianWorkspace",
    },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = function()
      return {
        workspaces = {
          {
            name = "Vault",
            path = "/home/nathanael/GitHub/Vault/",
          },
        },
        notes_subdir = "Notes",
        new_notes_location = "notes_subdir",
        note_id_func = function(title)
          if title and title ~= "" then
            local name = title
              :gsub("[/\\]", "-")
              :gsub("[%c]", "")
              :gsub("^%s+", "")
              :gsub("%s+$", "")

            if name ~= "" then
              return name
            end
          end

          return tostring(os.time())
        end,
        completion = {
          nvim_cmp = true,
        },

        ui = {
          enable = false,
        },

        note_frontmatter_func = function(_)
          return {}
        end,

        callbacks = {
          post_set_workspace = function(_, workspace)
            state.active_workspace = workspace
            initial_pull(workspace.root)
          end,
          enter_note = function()
            vim.keymap.set("n", "<leader>h", function()
              vim.cmd("VaultDashboard")
            end, { buffer = true, desc = "Open Obsidian vault dashboard" })
          end,
          leave_note = function(_, note)
            if note and note.path then
              local cwd = workspace_root_for_path(tostring(note.path))
              if cwd then
                schedule_sync(cwd, "leave_note")
              end
            end
          end,
        },
      }
    end,
  },
}

