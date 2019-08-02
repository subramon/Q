-- Coding convention. Local variables start with underscore
local qconsts = require 'Q/UTILS/lua/q_consts'
local qc = require 'Q/UTILS/lua/q_core'
local record_time = require 'Q/UTILS/lua/record_time'
local log = require 'Q/UTILS/lua/log'
local register_type = require 'Q/UTILS/lua/q_types'
local Reducer = {}
Reducer.__index = Reducer
local ffi = require 'Q/UTILS/lua/q_ffi'

setmetatable(Reducer, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

register_type(Reducer, "Reducer")
-- local original_type = type  -- saves `type` function
-- -- monkey patch type function
-- type = function( obj )
--   local otype = original_type( obj )
--   if  otype == "table" and getmetatable( obj ) == Reducer then
--     return "Reducer"
--   end
--   return otype
-- end

function Reducer.new(arg)
  local start_time = qc.RDTSC()
  assert(arg.coro == nil, "check to make sure old code eliminated")
  assert(type(arg) == "table",
    "Reducer: Constructor needs a table as input argument.")

  local reducer = setmetatable({}, Reducer)
  -- gen is optional
  -- value is optional
  -- func is necessary
  assert(type(arg.func) == "function",
  "Reducer: Table must have arg [func] which must be a function used to extract reducer")
  reducer._func = arg.func

  -- TODO: WHY THE HECK??? reducer._get_scalars = arg.get_scalars

  if arg.gen == nil then
    reducer._value= assert(arg.value, 
      "value cannot be nil if there is no method to generate new values")
    reducer._value = arg.value
    reducer._is_eov = true -- we have the final answer
  else
    reducer._value = arg.value -- TODO WHY THE HECK?? 
    reducer._gen = arg.gen
    reducer._is_eov = false -- we need ro figure out final answer
  end
  reducer._index = 0
  record_time(start_time, "Reducer.new")
  return reducer
end

function Reducer:next()
  if ( self._is_eov ) then
    return false
  end
  local start_time = qc.RDTSC()
  if self._gen == nil then return false end
  -- assert(self._gen ~= nil,  'Reducer: The reducer is materialized')
  local val = self._gen(self._index)
  self._index = self._index + 1
  if val then
    self._value = val
    return true
  else
    self._is_eov = true
    self._gen = nil -- destroy the generator once generation done
    return false
  end
  record_time(start_time, "Reducer.next")
end

function Reducer:get_name()
  return self._name
end

function Reducer:set_name(value)
  assert( (value == nil) or ( type(value) == "string") )
  self._name = value
  return self
end

function Reducer:value()
  if ( self._value and type(self._value) == "table" ) then 
  end 
  -- We are allowing user to obtain partial values
  local start_time = qc.RDTSC()
  assert(self._value ~= nil, "The reducer has not been evaluated yet")
  record_time(start_time, "Reducer.value")
  return self._func(self._value)
end

function Reducer:eval()
  local start_time = qc.RDTSC()
  local status = self._gen ~= nil
  if ( self._is_eov ) then 
    return self._func(self._value)
  end
  while status == true do
    status = self:next()
  end
  record_time(start_time, "Reducer.eval")
  return self:value()
end

return Reducer
