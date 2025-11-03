local function peek(self, job)
  local child, err = Command("vorbiscomment")
    :arg("--list")
    :arg(tostring(job.file.url))
    :stdout(Command.PIPED)
    :stderr(Command.PIPED)
    :spawn()

  if not child then
    ya.err("Failed to start `vorbiscomment`: %s", err)
    return
  end

  local output, err = child:wait_with_output()
  if not output then
    ya.err("Failed to run `vorbiscomment`: %s", err)
    return
  end

  if not output.status.success or output.status.code ~= 0 then
    ya.err("`vorbiscomment` failed due to non-zero exit status", output.status.code, output.stdout, output.stderr)
    return
  end

  local elements = {}

  for line in output.stdout:gmatch("([^\r\n]+)") do
    local key, value = line:match("([^=]+)=(.*)")
    if key and value then
      elements[#elements + 1] = ui.Line {
        ui.Span(key):style(ui.Style():bold()),
        ui.Span(" = "),
        ui.Span(value)
      }
    else
      elements[#elements + 1] = ui.Line { ui.Span(line) }
    end
  end

  ya.preview_widget(job, ui.Text(elements):area(job.area))
end

return {
  init = function(state, opts) end,
  entry = function(self, job) end,
  peek = peek,
  seek = peek,
}

