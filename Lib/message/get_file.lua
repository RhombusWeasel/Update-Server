return function(event, pkt)
  print(event.peer, "Requesting "..pkt.path)
  local path = pkt.path
  local ext = string.sub(path, #path - 3, #path)
--  if ext == ".lua" or ext == ".sha" or ext == ".txt" then
    
    local f = io.open("./"..path, "r")
    local s_data = f:read("*a")
    f:close()
    
    local b_data = {}
    for i = 1, #s_data do
      b_data[i] = string.byte(s_data, i)
    end
    
    local spkt = {
      command = "write_file",
      path = path,
      data = b_data,
    }
    event.peer:send(engine.string.serialize(spkt))
--  else
    
--  end
end