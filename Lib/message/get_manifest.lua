return function(event, pkt)
  local data = {
    command = "write_manifest",
    data = engine.manifest,
  }
  event.peer:send(engine.string.serialize(data))
end