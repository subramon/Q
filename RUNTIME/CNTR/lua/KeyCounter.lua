-- Coding convention. Local variables start with underscore
require 'Q/UTILS/lua/strict'
local ffi          = require 'ffi'
local cutils       = require 'libcutils'
local record_time  = require 'Q/UTILS/lua/record_time'
local qcfg         = require 'Q/UTILS/lua/qcfg'
local make_HC      = require 'Q/RUNTIME/CNTR/lua/make_HC'
local make_configs = require 'Q/RUNTIME/CNTR/lua/make_configs'
local make_kc_so   = require 'Q/TMPL_FIX_HASHMAP/KEY_COUNTER/lua/make_kc_so'
local register_type = require 'Q/UTILS/lua/register_type'
local get_ptr      = require 'Q/UTILS/lua/get_ptr'
local strip_pound  = require 'Q/UTILS/lua/strip_pound'
local KeyCounter = {}
KeyCounter.__index = KeyCounter

-- FILE struct from http://tigcc.ticalc.org/doc/stdio.html#FILE
-- pcall to ignore error on repeated cdefs of FILE
local file_struct = [[
typedef struct {
char *fpos; /* Current position of file pointer (absolute address) */
void *base; /* Pointer to the base of the file */
unsigned short handle; /* File handle */
short flags; /* Flags (see FileFlags) */
short unget; /* 1-byte buffer for ungetc (b15=1 if non-empty) */
unsigned long alloc; /* Number of currently allocated bytes for the file */
unsigned short buffincrement; /* Number of bytes allocated at once */
} FILE;
]]
status = pcall(ffi.cdef, file_struct)
-- add structs from rs_hmap_config to stuff to be cdef'd
local root_dir = os.getenv("Q_SRC_ROOT")
assert(cutils.isdir(root_dir))
local inc_dir = root_dir .. "/TMPL_FIX_HASHMAP/inc/" 
assert(cutils.isdir(inc_dir))
local inc_file = inc_dir .. "/rs_hmap_config.h"
assert(cutils.isfile(inc_file), inc_file)
local cdef_str = strip_pound(inc_file)
status = pcall(ffi.cdef, cdef_str)
--[[
if ( status ) then 
  print("cdef of config.h succeeded")
else
  print("cdef of config.h failed")
end
--]]
  --=================================================

--
-- Following hack of __gc is needed because of inability to set
-- __gc on anything other than userdata in 5.1.* 
-- Note that the delete method is called __gc (see below)
local setmetatable = require 'Q/UTILS/lua/rs_gc'
setmetatable(KeyCounter, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})
register_type(KeyCounter, "KeyCounter")
--==================================================
function KeyCounter.new(vecs, optargs)
  -- different *kinds* of KeyCounters must have different labels
  -- but 2 KeyCounters can have same label if the keys that they are
  -- counting have the same types
  if ( optargs ) then
    assert(type(optargs) == "table")
  end
  --===================================
  local label
  if ( optargs and optargs.label ) then 
    assert(type(optargs.label) == "string")
    label = optargs.label
  else
    label = tostring(cutils.RDTSC())
  end
  --===================================
  local name
  if ( optargs and optargs.name ) then 
    assert(type(optargs.name) == "string")
    name = optargs.name
  end
  -- vecs validated in make_configs()
  --===================================
  local keycounter = setmetatable({}, KeyCounter)
  keycounter._name   = name
  keycounter._label  = label
  keycounter._chunk_num  = 0
  keycounter._is_eor = false 
  -- becomes true when vecs consumed and counting done
  -- create configs for .so file/cdef creation
  local configs = make_configs(label, vecs)
  assert(type(configs) == "table")
  -- call function to create .so file and functions to be cdef'd
  local sofile, cdef_str = make_kc_so(configs)
  -- Note that sofile is -- $Q{ROOT}/lib/libkc${label}.so 
  -- But we ffi.load("kc${label})
  status = pcall(ffi.cdef, cdef_str)
  -- repeat cdef for custom destroy function
  local inc_dir = root_dir .. "/TMPL_FIX_HASHMAP/KEY_COUNTER/" .. label .. "/inc/" 
  assert(cutils.isdir(inc_dir), "Directory not found " .. inc_dir)
  local inc_file = inc_dir .. "/_rs_hmap_destroy.h"
  assert(cutils.isfile(inc_file), "File not found " .. inc_file)
  local cdef_str = assert(strip_pound(inc_file), "strip failed")
  status = pcall(ffi.cdef, cdef_str)
  --[[
  if ( status ) then 
    print("cdef for destroy worked")
  else
    print("cdef for destroy failed")
  end
  --]]
  --==========================================================
  local kc = ffi.load("kc" .. label)
  keycounter._kc = kc 
  -- create the configs for the  hashmap 
  local HC = assert(make_HC(optargs, sofile))
  local htype = label .. "_rs_hmap_t"
  -- create empty hashmap
  local H = ffi.new(htype .. "[?]", 1)
  local init_name = label .. "_rs_hmap_instantiate"
  local init_fn = assert(kc[init_name])
  init_fn(H, HC)
  keycounter._H = H
  keycounter._HC = HC
  keycounter._vecs = vecs
  keycounter._sofile = sofile
  local widths = ffi.new("uint32_t[?]", #vecs)
  widths = ffi.cast("uint32_t *", widths)
  for k, v in ipairs(vecs) do 
    widths[k-1] = assert(v:width())
    assert(widths[k-1] > 0)
  end 
  keycounter._widths = widths

  -- just to check that this function exists 
  local destroy_name = label .. "_rs_hmap_destroy"
  local destroy_fn = assert(kc[destroy_name])

  return keycounter
end

function KeyCounter:clone(vecs, optargs)
  if ( optargs ) then
    assert(type(optargs) == "table")
  end
  --===================================
  local name
  if ( optargs and optargs.name ) then 
    assert(type(optargs.name) == "string")
    name = optargs.name
  end
  --===================================
  local keycounter     = setmetatable({}, KeyCounter)
  local label          = assert(self._label)
  keycounter._label    = label
  keycounter._sofile   = assert(self._sofile)
  keycounter._name     = name
  keycounter._chunk_num  = 0
  keycounter._is_eor   = false 
  local kc = assert(ffi.load("kc" .. label)); 
  keycounter._kc = kc 
  -- just to check that this function exists 
  local destroy_name = label .. "_rs_hmap_destroy"
  local destroy_fn = assert(kc[destroy_name])
  -- create the configs for the  hashmap 
  local HC = assert(make_HC(optargs, keycounter._sofile))
  local htype = label .. "_rs_hmap_t"
  -- create empty hashmap
  local H = ffi.new(htype .. "[?]", 1)
  local init = label .. "_rs_hmap_instantiate"
  kc[init](H, HC)
  keycounter._H = H
  keycounter._HC = HC
  keycounter._vecs = vecs
  local widths = ffi.new("uint32_t[?]", #vecs)
  widths = ffi.cast("uint32_t *", widths)
  for k, v in ipairs(vecs) do 
    widths[k-1] = assert(v:width())
    assert(widths[k-1] > 0)
  end 
  keycounter._widths = widths
  return keycounter
end
--================================================================
function KeyCounter:next()
  -- print("next(): chunk = ", self._chunk_num)
  local start_time = cutils.rdtsc()
  if ( self._is_eor ) then return false end
  --================================================
  if ( self._chunk_num == 0 ) then 
    -- max_num_in_chunk of all vectors should be of same length
    for k, v in ipairs(self._vecs) do 
      assert(self._vecs[1]:max_num_in_chunk() == v:max_num_in_chunk())
    end
  end
  --================================================
  local lens = {}
  local chunks = {}
  for k, v in ipairs(self._vecs) do 
    local len, chunk, nn_chunk = v:get_chunk(self._chunk_num)
    lens[k] = len
    chunks[k] = chunk
    assert(nn_chunk == nil) -- null values not supported 
  end
  --================================================
  -- chunks of all vectors should be of same length
  for k, v in ipairs(self._vecs) do 
    assert(lens[k] == lens[1])
  end
  -- either you get all chunks or none 
  if ( chunks[1] ) then 
    for k, v in ipairs(self._vecs) do assert(chunks[k]) end
  else
    for k, v in ipairs(self._vecs) do assert(not chunks[k]) end
  end
  --========
  if ( not chunks[1] ) then 
    -- print("No more chunks")
    self._is_eor = true
    return false
  end
  local data = ffi.new("char *[?]", #self._vecs)
  data = ffi.cast("char **", data)
  for k, v in ipairs(self._vecs) do 
    data[k-1] = get_ptr(chunks[k], "char *")
  end
  local mput_fn = self._label .. "_rsx_kc_put"
  local fn = assert(self._kc[mput_fn])

  local status = fn(self._H, data, self._widths, lens[1])
  -- assert(status == 0)
  -- release chunks 
  for k, v in ipairs(self._vecs) do 
    v:unget_chunk(self._chunk_num)
  end
  self._chunk_num = self._chunk_num + 1
  --=====================================================
  if ( lens[1] < self._vecs[1]:max_num_in_chunk() ) then 
    self._is_eor = true
    return false
  end
  --=====================================================
  return true -- => more to come 
end

function KeyCounter:eval()
  local status = true
  local start_time = cutils.rdtsc()
  while status == true do
    status = self:next()
  end
  record_time(start_time, "KeyCounter.eval")
  return true
end

function KeyCounter:label()
  return self._label
end

function KeyCounter:name()
  return self._name
end

function KeyCounter:set_name(name)
  assert((type(name) == "string") or (type(name) == "nil"))
  self._name = name
  return self
end

function KeyCounter:nitems()
  return self._H[0].nitems 
end

function KeyCounter:is_eor()
  return self._is_eor
end

function KeyCounter:__gc()
  local destroy_name = self._label .. "_rs_hmap_destroy"
  local kc = assert(self._kc)
  assert(type(kc) == "userdata")
  local destroy_fn = assert(kc[destroy_name])
  destroy_fn(self._H)
  self._name = "DELETED" -- just for testing
  return true
end

return KeyCounter

--[[ Sample program to test usage of new*() to create 
--  array of pointers sent to mput 

local ffi = require 'ffi'
ffi.cdef("void *malloc(size_t size);")
local stringify = require 'Q/UTILS/lua/stringify'

local x = ffi.new("char *[?]", 3)
x[0] = stringify("000")
x[1] = stringify("111")
x[2] = stringify("222")

for i = 0, 2 do
  print(i, ffi.string(x[i]))
end
--]]
