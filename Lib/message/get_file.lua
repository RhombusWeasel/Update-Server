return function(event, pkt)
  print(event.peer, "Requesting "..pkt.path)
  local path = pkt.path
  local ext = string.sub(path, #path - 3, #path)
  if ext == ".lua" or ext == ".sha" then
    local f = io.open("./"..path, "rb")
    local pkt = {
      command = "write_file",
      path = path,
      data = f:read("*a")
    }
    f:close()
    event.peer:send(engine.string.serialize(pkt))
  end
end