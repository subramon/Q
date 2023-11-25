-- Coding convention. Local variables start with underscore
local ffi           = require 'ffi'
local cutils        = require 'libcutils'
local record_time   = require 'Q/UTILS/lua/record_time'
local register_type  = require 'Q/UTILS/lua/register_type'
local Reducer = {}
Reducer.__index = Reducer

setmetatable(Reducer, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

register_type(Reducer, "Reducer")

function Reducer.new(arg)
  assert(type(arg) == "table")
  local reducer = setmetatable({}, Reducer)
  -- gen is optional
  -- value is optional
  -- func is necessary
  assert(type(arg.func) == "function")
  -- func is a function which does XXXX 
  reducer._func = arg.func
  --[[ I liked this test but there are cases where we want a default
  -- value even before we have generated anything
  -- TODO P4 Think about a smart way of handling it 
  -- we need generator or value but not both
  if ( arg.gen ) then assert ( not arg.value ) end 
  if ( arg.value ) then assert ( not arg.gen ) end 
  --]]
  assert ( ( arg.gen ) or ( arg.value ) )
  --==============
  -- is_eor = is end of reducer
  if arg.value then 
    reducer._value = arg.value
    reducer._is_eor = true -- we have the final answer
  end
  -- Note that when you provide both a value and a generator
  -- is_eor is set to false
  if ( arg.gen ) then 
    assert(type(arg.gen) == "function")
    reducer._gen = arg.gen
    reducer._is_eor = false -- we still need to figure out final answer
  end
  if ( arg.destructor ) then 
    -- print("Reducer: setting destructor")
    assert(type(arg.destructor) == "function")
    reducer._destructor = arg.destructor
  end
  if ( arg.name ) then -- for debugging 
    reducer._name = arg.name
  else
    reducer._name = "anonymous"
  end
  assert(type(reducer._name) == "string")

  reducer._index = 0
  return reducer
end

function Reducer:delete()
  -- print("Destructor called on " .. self._name)
  if ( self._is_eor == false ) then return false end 
  if ( not self._destructor ) then return false end 
  assert(self._destructor(self._value))
  return true
end

function Reducer:next()
  local start_time = cutils.rdtsc()
  -- return false if end-of-reducer or no generator
  if ( self._is_eor ) then return false end
  if self._gen == nil then return false end
  -- assert(self._gen ~= nil,  'Reducer: The reducer is materialized')
  local val, is_eor = self._gen(self._index)
  self._index = self._index + 1
  if val then
    self._value = val
    if ( type(is_eor) == "boolean" ) then 
      self._is_eor = is_eor
    end
    return true
  else
    print("REDUCER got back nil, ending....")
    self._is_eor = true
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
  local start_time = cutils.rdtsc()
  local status = self._gen ~= nil
  if ( self._is_eor ) then 
    return self._func(self._value)
  end
  while status == true do
    status = self:next()
  end
  record_time(start_time, "Reducer.eval")
  return self:value()
end

return Reducer
