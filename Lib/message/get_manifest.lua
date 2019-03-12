return function(event, pkt)
  event.peer:send(engine.string.serialize(engine.manifest))
end