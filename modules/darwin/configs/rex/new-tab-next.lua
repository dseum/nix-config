local view, err = rex.session.view {}
if err then error(err, 0) end

local existing_window_ids = {}
local before_window_id
for i, window in ipairs(view.windows) do
  existing_window_ids[window.window_id] = true
  if (rex.args.block_id and window.focused_block_id == rex.args.block_id)
    or (not rex.args.block_id and window.window_id == view.active_window_id) then
    local next_window = view.windows[i + 1]
    before_window_id = next_window and next_window.window_id
  end
end

local _, err = rex.call("client.perform", {
  client_id = rex.args.client_id,
  session_id = rex.session_id,
  block_id = rex.args.block_id,
  action = "client.tab.new",
})
if err then error(err, 0) end

local updated_view, err = rex.session.view {}
if err then error(err, 0) end

local new_window_id
for _, window in ipairs(updated_view.windows) do
  if not existing_window_ids[window.window_id] then
    if new_window_id then error("More than one new tab; leaving tab order unchanged", 0) end
    new_window_id = window.window_id
  end
end
if not new_window_id then error("New tab not ready; leaving tab order unchanged", 0) end
if not before_window_id then return end

local _, err = rex.session.move_window {
  window_id = new_window_id,
  before_window_id = before_window_id,
}
if err then error(err, 0) end
