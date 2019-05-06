local Logger= {}
Logger.__index = Logger
setmetatable(Logger, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})




local modes = {
  { name = "trace", color = "\27[34m", },
  { name = "debug", color = "\27[36m", },
  { name = "info",  color = "\27[32m", },
  { name = "warn",  color = "\27[33m", },
  { name = "error", color = "\27[31m", },
  { name = "fatal", color = "\27[35m", },
}

local levels = {}
for i, v in ipairs(modes) do
  levels[v.name] = i
end

-- inflate log levels
for i, x in ipairs(modes) do
  local name = x.name:upper()
  Logger[x.name] = function(self, ...)
    assert(type(self) == "table" and getmetatable(self) == Logger, "Use : to call")
    local my_level = levels[x.name]
    if self.level ~= nil and my_level < self.level then
      return false
    end
    local msg = table.concat({...}, " ")
    local my_name = debug.getinfo(2, "Sl").short_src
    local idx = 2
    local info = debug.getinfo(idx, "Sl")
    -- generally idx 2 is fine but we dont want people to get confused as
    -- the asserts are now happening inside the logger to get the correct
    -- format, so removing self from the stack if thats the point of failure
    while info.short_src == my_name do
      idx = idx + 1
      info = debug.getinfo(idx, "Sl")
    end
    local lineinfo = info.short_src .. ":" .. info.currentline
    if self.outfile ~= nil then
      local file = io.open(self.outfile, "a")
      local str = string.format("[%-6s%s] %s: %s\n",
      name, os.date("%H:%M:%S"), lineinfo, msg)
      file:write(str)
      file:close()
    else -- output to console
      print(
      string.format("%s[%-6s%s]%s %s: %s",
      x.color, name, os.date("%H:%M:%S"), "\27[0m", lineinfo, msg))
    end
    return true
  end
end
function Logger.new(args)
  assert(type(args) == "table" or args == nil, "Args if specified should be a table")
  local log = setmetatable({}, Logger)
  if args == nil then
    return log
  end
  log.outfile = args.outfile
  if args.level ~= nil then
    log.level =  assert(levels[args.level], "must be a valid level")
  end
  log.level = levels[args.level]
  return log
end

return Logger
