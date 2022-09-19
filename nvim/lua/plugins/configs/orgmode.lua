local orgmode = require("orgmode")

local M = {}
M.setup = function()
  orgmode.setup({
    org_agenda_files = { "~/cs/org/**/*" },
    org_default_notes_file = "~/cs/org/refile.org",
    org_todo_keywords = {
      "TODO(t)",
      "STARTED(s)",
      "WAITING(w)",
      "|",
      "DONE(d)",
      "CANCELLED(c)",
      "DEFERRED(f)",
      "BLOCKED(b)",
    },
    org_todo_keyword_faces = {
      WAITING = ":foreground blue :weight bold",
      BLOCKED = ":foreground red :weight bold",
      STARTED = ":foreground cyan :weight bold",
    }
  })
end

return M
