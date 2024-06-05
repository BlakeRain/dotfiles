local SIGN_CACHE = {}

local function add_sign(bufnr, text, line, id, priority)
  priority = priority or 10

  local sign_name = "mark_" .. text
  if not SIGN_CACHE[sign_name] then
    vim.fn.sign_define(sign_name, { text = text, texthl = "MarkSignHM", numhl = "MarkSignNumHL" })
    SIGN_CACHE[sign_name] = true
  end

  vim.fn.sign_place(id, "MarkSigns", sign_name, bufnr, { lnum = line, priority = priority })
end

local function is_upper(char)
  return (65 <= char:byte() and char:byte() <= 90)
end

local function is_lower(char)
  return (97 <= char:byte() and char:byte() <= 122)
end

local PRIORITIES = {
  upper = 20,
  lower = 30,
  builtin = 10
}

local function add_mark_sign(bufnr, mark, line)
  local priority
  if is_upper(mark) then
    priority = PRIORITIES.upper
  elseif is_lower(mark) then
    priority = PRIORITIES.lower
  else
    priority = PRIORITIES.builtin
  end

  local id = mark:byte() * 100
  add_sign(bufnr, mark, line, id, priority)
  return id
end

local BUFFERS = {}

local function unregister_mark(bufnr, mark)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  local buffer = BUFFERS[bufnr]
  if (not buffer) or (not buffer.marks[mark]) then return end

  if buffer.marks[mark].id ~= nil then
    vim.fn.sign_unplace("MarkSigns", { id = buffer.marks[mark].id, buffer = bufnr })
  end

  buffer.marks[mark] = nil
end

local function register_mark(bufnr, mark, line, col)
  col = col or 1
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  local buffer = BUFFERS[bufnr]
  if not buffer then return end

  if buffer.marks[mark] then
    unregister_mark(bufnr, mark)
  end

  buffer.marks[mark] = { line = line, col = col, id = add_mark_sign(bufnr, mark, line) }
end

local BUILTINS = { ".", "^", "`", "'", '"', "<", ">", "[", "]" }

local IGNORE_FILETYPES = {}
local IGNORE_BUFTYPES = {}

local function ignoreFiletype(name)
  IGNORE_FILETYPES[name] = true
end

local function ignoreBuftype(name)
  IGNORE_BUFTYPES[name] = true
end

local function addDefaultIgnores()
  ignoreFiletype("neo-tree")
  ignoreFiletype("qf")
  ignoreFiletype("help")
  ignoreFiletype("minifiles")

  ignoreBuftype("terminal")
  ignoreBuftype("nofile")
end

local function shouldIgnore()
  return IGNORE_FILETYPES[vim.bo.ft] or IGNORE_BUFTYPES[vim.bo.bt]
end

local function refresh(bufnr, force)
  if shouldIgnore() then return end

  bufnr = bufnr or vim.api.nvim_get_current_buf()
  force = force or false

  if not BUFFERS[bufnr] then
    BUFFERS[bufnr] = { marks = {} }
  end

  local buffer = BUFFERS[bufnr]

  for mark, _ in pairs(buffer.marks) do
    if vim.api.nvim_buf_get_mark(bufnr, mark)[1] == 0 then
      unregister_mark(bufnr, mark)
    end
  end

  local function process_mark(data, predicate)
    local mark = data.mark:sub(2, 3)
    local pos = data.pos
    local cached = buffer.marks[mark]

    if predicate(mark) and (force or not cached or pos[2] ~= cached.line) then
      register_mark(bufnr, mark, pos[2], pos[3])
    end
  end

  for _, data in ipairs(vim.fn.getmarklist()) do
    process_mark(data, function(mark) return is_upper(mark) and data.pos[1] == bufnr end)
  end

  for _, data in ipairs(vim.fn.getmarklist("%")) do
    process_mark(data, is_lower)
  end

  for _, mark in ipairs(BUILTINS) do
    local pos = vim.fn.getpos("'" .. mark)
    local cached = buffer.marks[mark]

    if (pos[1] == 0 or pos[1] == bufnr) and pos[2] ~= 0 and (force or not cached or pos[2] ~= cached.line) then
      register_mark(bufnr, mark, pos[2], pos[3])
    end
  end
end

return {
  _onBufEnter = function()
    if shouldIgnore() then return end
    refresh(nil, true)
  end,

  _onBufDelete = function()
    local bufnr = tonumber(vim.fn.expand("<abuf>"))
    if not bufnr then return end

    BUFFERS[bufnr] = nil;
  end,

  setup = function()
    addDefaultIgnores()

    vim.cmd [[augroup mark_signs_au
      autocmd!
      autocmd BufEnter * lua require("custom.mark_signs")._onBufEnter()
      autocmd BufDelete * lua require("custom.mark_signs")._onBufDelete()
    augroup end]]

    vim.cmd [[
      hi default link MarkSignHL Identifier
      hi default link MarkSignNumHL CursorLineNr
    ]]

    local timer = vim.uv.new_timer()
    timer:start(2000, 2000, vim.schedule_wrap(refresh))
  end
}
