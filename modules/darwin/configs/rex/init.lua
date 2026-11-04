local config_home = os.getenv("XDG_CONFIG_HOME") or os.getenv("HOME") .. "/.config"
local config_dir = config_home .. "/rex"

rex.bind("shift+enter", "pane.send_key", { key = "alt+enter" })

rex.action {
  name = "tab_new_next",
  title = "New Tab Next to Current",
  run = function(ctx)
    if not ctx.session_id then
      rex.client.queue("client.tab.new")
      return
    end

    local client_id = ctx.client_id
    local lock_file = (os.getenv("TMPDIR") or "/tmp") .. "/rex-tab-" .. client_id .. ".lock"

    local process, err = rex.exec.start({
      config_dir .. "/bin/flock", lock_file,
      "/Applications/Rex Beta.app/Contents/Helpers/Rex Server.rex/Contents/MacOS/rex",
      "--autostart=false", "-C", client_id,
      "do", "--session", ctx.session_id,
      config_dir .. "/new-tab-next.lua",
      "--args", rex.json.encode { client_id = client_id, block_id = ctx.block_id },
    }, { detach = true })
    if not process then error(err, 0) end
  end,
}

rex.bind("cmd+t", "tab_new_next")
