local state = ya.sync(function()
  local selected = {}
  for _, url in pairs(cx.active.selected) do
    selected[#selected + 1] = url
  end

  if #selected == 0 and cx.active.current.hovered then
    selected[1] = cx.active.current.hovered.url
  end

  return cx.active.current.cwd, selected
end)

local function run_gpg(args)
  local child, err = Command("gpg")
    :arg(args)
    :stdout(Command.PIPED)
    :stderr(Command.PIPED)
    :spawn()

  if not child then
    return false, Err("Failed to start `gpg`: %s", err)
  end

  local output, err = child:wait_with_output()
  if not output then
    return false, Err("Failed to run `gpg`: %s", err)
  elseif not output.status.success or output.status.code ~= 0 then
    ya.err("GPG failed due to non-zero exit status", output.status.code, output.stdout, output.stderr)
    return false, Err("`gpg` exited with non-zero error code %s", output.status.code)
  end

  return true
end

local function gpg_encrypt(url)
  return run_gpg {
    "--encrypt",
    "--recipient",
    "blake.rain@blakerain.com",
    tostring(url)
  }
end

local function gpg_decrypt(url, output)
  return run_gpg {
    "--decrypt",
    "--output",
    output,
    tostring(url)
  }
end

local function gpg_sign(url)
  return run_gpg {
    "--detach-sign",
    "--recipient",
    "blake.rain@blakerain.com",
    tostring(url)
  }
end

local function encrypt()
  local _, selected = state()
  if #selected == 0 then
    return false, Err("No selection") end

  for _, url in pairs(selected) do
    local cha, err = fs.cha(url)
    if not cha then
      return false, Err("Failed to get characteristics for URL %s: %s", tostring(url), err)
    end

    if cha.is_dir then
      return false, Err("URL %s is a directory", tostring(url))
    end
  end

  local permit = ya.hide()

  for _, url in pairs(selected) do
    local ok, err = gpg_encrypt(url)
    if not ok then
      return false, Err("Failed to encrypt %s: %s", tostring(url), err)
    end
  end

  permit:drop()

  ya.notify {
    title = "gpg",
    content = string.format("Encrypted %d file(s) successfully", #selected),
    timeout = 5,
    level = "info"
  }

  return true
end

local function decrypt()
  local cwd, selected = state()
  if #selected == 0 then
    return false, Err("No selection")
  end

  for _, url in pairs(selected) do
    local cha, err = fs.cha(url)
    if not cha then
      return false, Err("Failed to get characteristics for URL %s: %s", tostring(url), err)
    end

    if cha.is_dir then
      return false, Err("URL %s is a directory", tostring(url))
    end
  end

  for _, url in pairs(selected) do
    local target = url.name:match("([^/\\]+)%.%w+$") or ""
    local output, event = ya.input {
      position = { "center", w = 50 },
      title = string.format("Output for decryption of '%s':", url.name),
      value = target
    }

    if event ~= 1 or not output then
      return false, Err("User cancelled")
    end

    local permit = ya.hide()

    local ok, err = gpg_decrypt(url, output)
    if not ok then
      return false, Err("Failed to decrypt %s: %s", tostring(url), err)
    end

    permit:drop()
  end

  ya.notify {
    title = "gpg",
    content = string.format("Decrypted %d file(s) successfully", #selected),
    timeout = 5,
    level = "info"
  }

  return true
end

local function sign()
  ya.emit("escape", { visual = true })
  local _, selected = state()
  if #selected ~= 1 then
    return false, Err("Expected exactly one selection")
  end

  local url = selected[1]
  local cha, err = fs.cha(url)
  if not cha then
    ya.err("Failed to get characteristics for URL", tostring(url), err)
    return false, Err("Failed to get file characteristics: %s", err)
  end

  if cha.is_dir then
    ya.err("URL is a directory", tostring(url))
    return false, Err("`gpg` encryption cannot operate on directories")
  end

  local permit = ya.hide()
  local ok, err = gpg_sign(url)
  if not ok then
    return false, Err("Failed to sign %s: %s", tostring(url), err)
  end

  permit:drop()

  ya.notify {
    title = "gpg",
    content = "Signed successfully",
    timeout = 5,
    level = "info"
  }

  return true
end

local function gpg(self, job)
  if job.args[2] == "encrypt" then
    local ok, err = encrypt()
    if not ok then
      ya.notify {
        title = "gpg",
        content = tostring(err),
        timeout = 5,
        level = "error"
      }
    end
  elseif job.args[2] == "decrypt" then
    local ok, err = decrypt()
    if not ok then
      ya.notify {
        title = "gpg",
        content = tostring(err),
        timeout = 5,
        level = "error"
      }
    end
  elseif job.args[2] == "sign" then
    local ok, err = sign()
    if not ok then
      ya.notify {
        title = "gpg",
        content = tostring(err),
        timeout = 5,
        level = "error"
      }
    end
  else
    error(string.format("Unknown GPG action `%s` (expected `encrypt`, `decrypt`, or `sign`)", job.args[2]))
  end
end

return {
  init = function(state, opts) end,
  entry = function(self, job)
    if job.args[1] == "gpg" then
      return gpg(self, job)
    else
      error(string.format("Unknown action `%s` (expected `gpg`)", job.args[1]))
    end
  end
}
