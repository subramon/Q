local ffi = require 'ffi'
local qconsts       = require 'Q/UTILS/lua/q_consts'
local log           = require 'Q/UTILS/lua/log'
local qc            = require 'Q/UTILS/lua/q_core'
local register_type = require 'Q/UTILS/lua/q_types'
local get_ptr       = require 'Q/UTILS/lua/get_ptr'
local serialize     = require 'Q/RUNTIME/lua/serialize' -- TODO P4 delete
local cmem          = require 'libcmem'
--====================================
local lDictionary = {}
lDictionary.__index = lDictionary

setmetatable(lDictionary, {
   __call = function (cls, ...)
      return cls.new(...)
   end,
})

register_type(lDictionary, "lDictionary")

local function map_to_string(
  tbl
  )
  local T = {}
  T[#T+1] = "local T = {} "
  for k, v in ipairs(tbl) do
    T[#T+1] = "T[" .. k .. "] = '" .. v .. "'"
  end
  T[#T+1] = "return T"
  return table.concat(T, '\n')
end

function lDictionary:get_name()
  if ( qconsts.debug ) then self:check() end
  return self._meta.name
end

function lDictionary:to_file(filename)
  if ( qconsts.debug ) then self:check() end
  assert(filename)
  assert(type(filename) == "string")
  assert(#filename > 0)
  -- TODO Need to finish
  return true
end

function lDictionary.new(inparam, optargs)
  local dictionary = setmetatable({}, lDictionary)
  -- for meta data stored in dictionary
  dictionary._meta = {}

  assert( ( type(inparam) == "table") or ( type(inparam) == "string") )
  local chk = true
  if ( optargs ) then 
    if ( type(opatargs.chk) ~= nil ) then
      assert(type(optargs.chk) == "boolean")
      chk = optargs.chk
    end
  end

  local rmap -- map from string to int
  local fmap -- map from int to string
  if ( type(inparam) == "string" ) then 
    local filename = inparam
    assert(qc.file_exists(filename))
    assert(qc.get_file_size(filename) > 0)
    fmap = dofile(filename)
  end
  if ( type(inparam) == "table" ) then 
    fmap = inparam
  end
  assert ( type(fmap) == "table" )
  assert(#fmap > 0)
  if ( chk ) then 
    local chk_n = 0
    for k, v in pairs(fmap) do chk_n = chk_n + 1 end
    assert(#fmap == chk_n)
  end
  local rmap = {}
  for k, v in pairs(fmap) do 
     assert(not rmap[v])
    rmap[v] = k
  end
  dictionary._map_str_to_int = rmap
  dictionary._map_int_to_str = fmap
  return dictionary
end

function lDictionary:num_elements()
  if ( qconsts.debug ) then self:check() end
  return #self._map_int_to_str
end


function lDictionary:pr(direction)
  assert( (direction and type(direction) == "string"))
  if ( direction == "forward" ) then 
    for k, v in pairs(self._map_int_to_str) do print(k, v) end 
  elseif ( direction == "reverse" ) then 
    for k, v in pairs(self._map_str_to_int) do print(k, v) end 
  else
    assert(nil)
  end
  return true
end

function lDictionary:check()
  assert(self._map_int_to_str)
  assert(type(self._map_int_to_str) == "table")
  assert(#self._map_int_to_str > 0)
  return true
end

function lDictionary:meta()
  return self._meta
end

function lDictionary:reincarnate()
  -- create a random file name in data directory
  local len = 64 -- TODO P4 Do not hard code
  local file_name = cmem.new(len)
  file_name:zero()
  file_name = ffi.cast("char *", get_ptr(file_name))
  assert(qc['rand_file_name'](file_name, len-1))
  file_name = qconsts.Q_DATA_DIR .. "/" .. ffi.string(file_name)
  -- replace suffix of .bin with .lua
  file_name = string.gsub(file_name, ".bin", ".lua")
  assert(io.open(file_name, "w+"))
  io.output(file_name)
  io.write(map_to_string(self._map_int_to_str))
  return "lDictionary ( \"" .. file_name .. "\" ) "
end
  

return lDictionary
