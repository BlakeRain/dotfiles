local function get_rust_edition(root)
  local Path = require("plenary.path")
  local cargo_toml = Path:new(root .. "/" .. "Cargo.toml")

  if cargo_toml:exists() and cargo_toml:is_file() then
    for _, line in ipairs(cargo_toml:readlines()) do
      local edition = line:match([[^edition%s*=%s*%"(%d+)%"]])
      if edition then
        return edition
      end
    end
  end

  return nil
end

return {
  get_rust_edition = get_rust_edition
}
