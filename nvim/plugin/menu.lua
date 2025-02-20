vim.cmd [[
  aunmenu PopUp
  anoremenu PopUp.Inspect       <cmd>Inspect<CR>
  amenu PopUp.-1-               <nop>
  anoremenu PopUp.Definition    <cmd>lua vim.lsp.buf.definition()<CR>
  anoremenu PopUp.References    <cmd>Telescope lsp_references<CR>
  anoremenu PopUp.Rename        <cmd>lua vim.lsp.buf.rename()<CR>
  nnoremenu PopUp.Back          <C-t>
]]

local group = vim.api.nvim_create_augroup("nvim_popupmenu", { clear = true })
vim.api.nvim_create_autocmd("MenuPopup", {
  pattern = "*",
  group = group,
  desc = "Custom PopUp Setup",
  callback = function()
    vim.cmd [[
      amenu disable PopUp.Definition
      amenu disable PopUp.References
      amenu disable PopUp.Rename
    ]]

    if vim.lsp.buf_get_clients(0)[1] then
      vim.cmd [[
        amenu enable PopUp.Definition
        amenu enable PopUp.References
        amenu enable PopUp.Rename
      ]]
    end
  end
})
