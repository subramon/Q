-- Coding convention. Local variables start with underscore
local ffi           = require 'ffi'
local cutils        = require 'libcutils'
local record_time   = require 'Q/UTILS/lua/record_time'
local make_all      = require 'Q/TMPL_FIX_HASHMAP/KEY_COUNTER/lua/make_all'
local register_type = require 'Q/UTILS/lua/register_type'
local KeyCounter = {}
KeyCounter.__index = KeyCounter

-- Following hack of __gc is needed because of inability to set
-- __gc on anything other than userdata in 5.1.* 
local setmetatable = require 'Q/UTILS/lua/rs_gc'
setmetatable(KeyCounter, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

register_type(KeyCounter, "KeyCounter")

--==================================================
local function make_HC(optargs) 
  if ( optargs ) then assert(type(optargs) == "table") end 
  local HC = ffi.new("rs_hmap_config_t[?]", 1)
  ffi.fill(HC, ffi.sizeof("rs_hmap_config_t"))
  if ( optargs ) then 
    if ( optargs.min_size ) then 
      assert(optargs.min_size == "number")
      assert(optargs.min_size > 16)
      HC[0].min_size = optargs.min_size
    end
    if ( optargs.max_size ) then 
      assert(optargs.max_size == "number")
      assert(optargs.max_size > 16)
      HC[0].max_size = optargs.max_size
    end
    if ( optargs.low_water_mark ) then 
      assert(optargs.low_water_mark == "number")
      assert(optargs.low_water_mark > 0.05)
      assert(optargs.low_water_mark < 0.50)
      HC[0].low_water_mark = optargs.low_water_mark
    end
    if ( optargs.high_water_mark ) then 
      assert(optargs.high_water_mark == "number")
      assert(optargs.high_water_mark > 0.50)
      assert(optargs.high_water_mark < 0.95)
      HC[0].high_water_mark = optargs.high_water_mark
    end
  end
  HC[0].so_file = so_file -- TODO  P1
  HC[0].so_file = so_handle -- TODO  P1
  return HC
end
--==================================================
local function make_configs(label, vecs)
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
  return configs
end
--==================================================
function KeyCounter.new(label, vecs, optargs)
  assert(type(label) == "string")
  assert(type(vecs) == "table")
  local keycounter = setmetatable({}, KeyCounter)
  keycounter._name  = label
  keycounter._chunk_idx  = 0
  keycounter._is_eor = false -- becomes true when counting done
  -- create configs for .so file/cdef creation
  local configs = make_configs(label, vecs)
  -- call function to create .so file and functions to be cdef'd
  local sofile, cdef_str = make_all(configs)
  ffi.cdef(cdef_str)
  local kc = ffi.load(sofile); keycounter._kc = kc 
  -- create the configs for the  hashmap 
  local HC = make_HC(optargs) 
  local htype = label .. "_rs_hmap_t"
  local H = ffi.new(htype .. "[?]", 1)
  local H  = make_H(optargs) 
  local init = label .. "_rs_hmap_instantiate"
  kc.init(H, HC)
  keycounter._H = H
  keycounter._HC = HC
  -- cdef functions in .so file and load .so file 
  return keycounter
end

function KeyCounter:delete()
  print("Destructor called on " .. self._name)
  self._kc["rs_hmap_destroy"](self._H)
  -- TODO P1 How do we make sure that this is called by __gc?
  return true
end

function KeyCounter:next()
  local start_time = cutils.rdtsc()
  if ( self._is_eor ) then return false end
end

function KeyCounter:get_name()
  return self._name
end

function KeyCounter:set_name(value)
  assert( (value == nil) or ( type(value) == "string") )
  self._name = value
  return self
end

function KeyCounter:nitems()
  return self._H[0].nitems 
end

function KeyCounter:eval()
  local start_time = cutils.rdtsc()
  while status == true do
    status = self:next()
  end
  record_time(start_time, "KeyCounter.eval")
  return self:value()
end

return KeyCounter
