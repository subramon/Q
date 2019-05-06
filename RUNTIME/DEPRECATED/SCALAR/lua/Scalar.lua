-- Coding convention. Local variables start with underscore
local log = require 'Q/UTILS/lua/log'
local plpath = require("pl.path")
local Scalar = {}
Scalar.__index = Scalar
local ffi = require 'Q/UTILS/lua/q_ffi'
-- local DestructorLookup = {}
-- local dbg = require 'Q/UTILS/lua/debugger'

setmetatable(Scalar, {
        __call = function (cls, ...)
            return cls.new(...)
        end,
    })

    --[[ TODO Delete later. Not needed for scalar
function Scalar.destructor(data)
    -- Works with Lua but not luajit so adding a little hack
    if type(data) == type(Scalar) then
        ffi.free(data.destructor_ptr)
        DestructorLookup[data.destructor_ptr] = nil
    else
        -- local tmp_slf = DestructorLookup[data]
        DestructorLookup[data] = nil
        ffi.free(data)
    end
end

Scalar.__gc = Scalar.destructor
--]]

local original_type = type  -- saves `type` function
-- monkey patch type function
type = function( obj )
    local otype = original_type( obj )
    if  otype == "table" and getmetatable( obj ) == Scalar then
        return "Scalar"
    end
    return otype
end

function Scalar.new(arg)
   assert(type(arg) == "table", 
   "Scalar: Constructor needs a table as input argument. Instead got " .. type(arg))
   assert(type(arg.coro) == "thread", 
   "Scalar: Table must have argument coro which must be a coroutine")
   assert(type(arg.func) == "function", 
   "Scalar: Table must have arg [func] which must be a function used to extract scalar")
   local scalar = setmetatable({}, Scalar)
   -- TODO Delete scalar.destructor_ptr = ffi.malloc(1, Scalar.destructor)
   -- TODO Delete DestructorLookup[scalar.destructor_ptr] = scalar
   scalar._coro = arg.coro
   scalar._func = arg.func
   -- scalar._val contains partial results. 
   return scalar
end

function Scalar:next()
   assert(coroutine.status(self._coro) ~= "dead" , 
   "Scalar: The coroutine is no longer alive")
   local status, val = coroutine.resume(self._coro)
   if status == true and val ~= nil then
      self._val = val
   end
   return coroutine.status(self._coro) ~= "dead"
end

function Scalar:value()
   -- We are allowing user to obtain partial values
   assert(self._val ~= nil, "The scalar has not been evaluated yet")
   return self._func(self._val)
end

function Scalar:eval()
    local status = coroutine.status(self._coro) ~= "dead"
    while status == true do
      status = self:next()
    end
    return self:value()
end

return Scalar
