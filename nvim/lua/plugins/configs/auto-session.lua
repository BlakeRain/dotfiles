local auto_session = require('auto-session')

local M = {}
M.setup = function()
    auto_session.setup({
        log_level = "auto",
        auto_restore_enabled = false,
        auto_session_suppress_dirs = {"~/"},
        pre_save_cmds = {"tabdo NeoTreeClose"},
        post_save_cmds = {"tabdo NeoTreeReveal"},
        post_restore_cmds = {"tabdo NeoTreeReveal"}
    })
end

return M
