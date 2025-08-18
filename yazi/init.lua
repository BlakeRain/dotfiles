function Linemode:size_and_mtime()
  local time = math.floor(self._file.cha.mtime or 0)

  local timestr = ""
  if time == 0 then
    timestr = "N"
  elseif os.date("%Y", time) == os.date("%Y") then
    timestr = os.date("%b %d %H:%M", time)
  else
    timestr = os.date("%b %d  %Y", time)
  end

  local size = self._file:size()
  return string.format("%s %s", size and ya.readable_size(size) or "-", timestr)
end
