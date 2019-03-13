return function(event, pkt)
  print(event.peer, "Requesting "..pkt.path)
  local path = pkt.path
  local ext = string.sub(path, #path - 3, #path)
  if ext == ".lua" or ext == ".sha" then
    local f = io.open("./"..path, "r")
    local s_data = f:read("*a")
    local b_data = {}
    for i = 1, #s_data do
      b_data[i] = string.byte(str, i).." "
    end
    local pkt = {
      command = "write_file",
      path = path,
      data = b_data,
    }
    f:close()
    event.peer:send(engine.string.serialize(pkt))
  end
end