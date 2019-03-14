--[[Basic class library:
  This simple class lib is added to engine.class, you can create a new class by calling:-
  
  local new_class = engine.class:extend()
  
  Extend does support multiclassing so you can pass another class as an argument to extend.
]]
local class = {}

function log(text)
  print(text)
end

function class:extend(subClass)
  return setmetatable(subClass or {}, {__index = self})
end

function class:new(...)
  local inst = setmetatable({}, {__index = self})
  return inst, inst:init(...)
end

function class:init(...) end

--[[Recursive Load:
  Recursively load files and store them in a table.
]]

local function scandir(directory)
  local i, t, popen = 0, {}, io.popen
  local pfile = popen('ls -a "'..directory..'"')
  for filename in pfile:lines() do
    i = i + 1
    t[i] = filename
  end
  pfile:close()
  return t
end

local function getFile(tab, path, folder, file)
  if tab[folder] == nil then
    tab[folder] = {}
  end
  local ext = string.sub(file, #file - 3, #file)
  file = string.sub(file, 1, #file - 4)
  local filePath = path.."/"..folder.."/"..file
  if ext == ".lua" then
    tab[folder][file] = require(path.."."..folder.."."..file)
  end
  if tab[folder][file] ~= nil then
    print("Loaded : engine."..folder.."."..file)
  end
end

local function getFiles(tab, path, folder)
  local filePath = path
  if folder == nil then
    folder = ""
  else
    filePath = path.."/"..folder
  end
  local data = scandir(filePath)
  for i = 1, #data do
    local file = data[i]
    if file ~= "." and file ~= ".." then
      local f = io.open(filePath.."/"..file, "r")
      local x,err=f:read(1)
      if err == "Is a directory" then
        if folder ~= "" then
          getFiles(tab, filePath, file)
        else
          getFiles(tab, path, file)
        end
      else
        getFile(tab, path, folder, file)
      end
    end
  end
end


--[[Main Functions:
  load_game is called once at program start.

  Update is then looped until the exit condition is met.
]]

local enet = require("enet")

engine = {
  class = class,
  log = log,
  host = enet.host_create("*:6789"),
}

local function getManifest(tab, path, folder)
  local filePath = path
  if folder == nil then
    folder = ""
  else
    filePath = path.."/"..folder
  end
  local data = scandir(filePath)
  for i = 1, #data do
    local file = data[i]
    if file ~= "." and file ~= ".." then
      local f = io.open(filePath.."/"..file, "r")
      local x,err=f:read(1)
      f:close()
      if err == "Is a directory" then
        if file ~= ".git" then
          if folder ~= "" then
            getManifest(tab, filePath, file)
          else
            getManifest(tab, path, file)
          end
        end
      else
        local f = io.open(filePath.."/"..file, "r")
        local s_data = f:read("*a")
        f:close()
        
        local total = 0
        for i = 1, #s_data do
          total = total + string.byte(s_data, i)
        end
        local data = {
          file = file,
          path = filePath.."/"..file,
          down = false,
          chk = total,
        }
        table.insert(tab, data)
      end
    end
  end
  return tab
end

function update()
  local event = engine.host:service(100)
  while event do
    local pkt = engine.string.unpack(event.data)
    if pkt then
      if event.type == "receive" then
        if engine.message[pkt.command] then
          engine.message[pkt.command](event, pkt)
        end
      end
    end
    event = engine.host:service()
  end
end

--PROGRAM START:
os.execute("clear")

getFiles(engine, "Lib")

engine.manifest = getManifest({}, "Expense")
for i = 1, #engine.manifest do
  print(engine.string.l_pad(engine.manifest[i].file, 25), engine.manifest[i].chk)
end

engine.exit_bool = false
while not engine.exit_bool do
  update()
end