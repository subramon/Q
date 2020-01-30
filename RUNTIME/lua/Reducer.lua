-- Coding convention. Local variables start with underscore
local ffi      = require 'ffi'
local cutils   = require 'libcutils'
local qconsts  = require 'Q/UTILS/lua/q_consts'
local record_time = require 'Q/UTILS/lua/record_time'
local register_type = require 'Q/UTILS/lua/q_types'
local Reducer = {}
Reducer.__index = Reducer

setmetatable(Reducer, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

register_type(Reducer, "Reducer")

function Reducer.new(arg)
  local start_time = cutils.RDTSC()
  assert(type(arg) == "table")
  local reducer = setmetatable({}, Reducer)
  -- gen is optional
  -- value is optional
  -- func is necessary
  assert(type(arg.func) == "function")
  -- func is a function which does XXXX 
  reducer._func = arg.func
  -- we need generator or value but not both
  if ( arg.gen ) then assert ( not arg.value ) end 
  if ( arg.value ) then assert ( not arg.gen ) end 
  assert ( ( arg.gen ) or ( arg.value ) )
  --==============
  if arg.value then 
    reducer._value= assert(arg.value) 
    reducer._is_eov = true -- we have the final answer
  end
 if ( arg.gen ) then 
    reducer._gen = arg.gen
    reducer._is_eov = false -- we still need to figure out final answer
  end
  reducer._index = 0
  record_time(start_time, "Reducer.new")
  return reducer
end

function Reducer:next()
  if ( self._is_eov ) then
    return false
  end
  local start_time = cutils.RDTSC()
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
  -- We are allowing user to obtain partial values
  assert(self._value, "The reducer has not been evaluated yet")
  return self._func(self._value) -- apply getter on value
end

function Reducer:eval()
  local start_time = cutils.RDTSC()
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
