-- Coding convention. Local variables start with underscore
local ffi           = require 'ffi'
local cutils        = require 'libcutils'
local record_time   = require 'Q/UTILS/lua/record_time'
local register_type  = require 'Q/UTILS/lua/register_type'
local KeyCounter = {}
KeyCounter.__index = KeyCounter

setmetatable(KeyCounter, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

register_type(KeyCounter, "KeyCounter")

function KeyCounter.new(label, vecs)
  assert(type(label) == "string")
  assert(type(vecs) == "table")
  local keycounter = setmetatable({}, KeyCounter)
  keycounter._is_eor = false -- have not finished counting 
  if ( arg.name ) then -- for debugging 
    keycounter._name = arg.name
  else
    keycounter._name = "anonymous"
  end
  assert(type(keycounter._name) == "string")
  -- create configs for .so file/cdef creation
  local configs = {}
  configs.label = label
  local n = 0
  local qtypes = {}
  for k, v in ipairs(vecs) do 
    assert(type(v) == "lVector")
    local qtype = v:qtype()
    if ( qtype == "I1" ) then 
      qtypes[#qtypes+1] = "int8_t" 
    elseif ( qtype == "I2" ) then 
      qtypes[#qtypes+1] = "int16_t" 
    elseif ( qtype == "I4" ) then 
      qtypes[#qtypes+1] = "int32_t" 
    elseif ( qtype == "I8" ) then 
      qtypes[#qtypes+1] = "int64_t" 
    elseif ( qtype == "F4" ) then 
      qtypes[#qtypes+1] = "float" 
    elseif ( qtype == "F8" ) then 
      qtypes[#qtypes+1] = "double" 
    elseif ( qtype == "SC" ) then 
      qtypes[#qtypes+1] = "char:" .. tostring(v:width())
    else
      error("qtype of vector not supported -> " .. qtype)
    end
    n = n + 1
  end
  assert(( n >= 1 ) and ( n <= 4 )) -- cannot group count > 4 keys at a time
  configs.qtypes = qtypes
  -- call function to create .so file and functions to be cdef'd


  -- cdef functions in .so file 
  -- load .so file 
  keycounter._kc = ffi.load(

  keycounter._index = 0
  return keycounter
end

function KeyCounter:delete()
  -- print("Destructor called on " .. self._name)
  if ( self._is_eor == false ) then return false end 
  if ( not self._destructor ) then return false end 
  assert(self._destructor(self._value))
  return true
end

function KeyCounter:next()
  local start_time = cutils.rdtsc()
  -- return false if end-of-keycounter or no generator
  if ( self._is_eor ) then return false end
  if self._gen == nil then return false end
  -- assert(self._gen ~= nil,  'KeyCounter: The keycounter is materialized')
  local val, is_eor = self._gen(self._index)
  self._index = self._index + 1
  if val then
    self._value = val
    if ( type(is_eor) == "boolean" ) then 
      self._is_eor = is_eor
    end
    return true
  else
    self._is_eor = true
    self._gen = nil -- destroy the generator once generation done
    return false
  end
  record_time(start_time, "KeyCounter.next")
end

function KeyCounter:get_name()
  return self._name
end

function KeyCounter:set_name(value)
  assert( (value == nil) or ( type(value) == "string") )
  self._name = value
  return self
end

function KeyCounter:value()
  -- We are allowing user to obtain partial values
  assert(self._value, "The keycounter has not been evaluated yet")
  return self._func(self._value) -- apply getter on value
end

function KeyCounter:eval()
  local start_time = cutils.rdtsc()
  local status = self._gen ~= nil
  if ( self._is_eor ) then 
    return self._func(self._value)
  end
  while status == true do
    status = self:next()
  end
  record_time(start_time, "KeyCounter.eval")
  return self:value()
end

return KeyCounter
