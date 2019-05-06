--
-- log.lua
--
-- Copyright (c) 2016 rxi
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.
--

local log = { _version = "0.1.0" }

log.usecolor = true
log.outfile = nil
log.level = "trace"


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


local round = function(x, increment)
    increment = increment or 1
    x = x / increment
    return (x > 0 and math.floor(x + .5) or math.ceil(x - .5)) * increment
end


local _tostring = tostring

local tostring = function(...)
    local t = {}
    for i = 1, select('#', ...) do
        local x = select(i, ...)
        if type(x) == "number" then
            x = round(x, .01)
        end
        t[#t + 1] = _tostring(x)
    end
    return table.concat(t, " ")
end


for i, x in ipairs(modes) do
    local nameupper = x.name:upper()
    log[x.name] = function(...)

        -- Return early if we're below the log level
        if i < levels[log.level] then
            return
        end

        local msg = tostring(...)
        local my_name = debug.getinfo(1, "Sl").short_src
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

        -- Output to console
        print(string.format("%s[%-6s%s]%s %s: %s",
                log.usecolor and x.color or "",
                nameupper,
                os.date("%H:%M:%S"),
                log.usecolor and "\27[0m" or "",
                lineinfo,
            msg))

        -- Output to log file
        if log.outfile then
            local fp = io.open(log.outfile, "a")
            local str = string.format("[%-6s%s] %s: %s\n",
                nameupper, os.date(), lineinfo, msg)
            fp:write(str)
            fp:close()
        end

    end
end

-- Not overriding if already defined
--[[
if oassert == nil then
    oassert = assert
end
assert = function(cond, ...)
    if cond then
        return cond, ...
    else
        log.fatal(...)
        -- now remove self from top of stack (second line)
        local idx = 1
        for line in string.gmatch(debug.traceback(), "[^\n]+" ) do
            if idx ~= 2 then
                log.fatal(line)
            end
            idx = idx + 1
        end
        oassert(cond, ...)
    end
end
]]
return log
