-- Coding convention. Local variables start with underscore
local ffi          = require 'ffi'
local cutils       = require 'libcutils'
local record_time  = require 'Q/UTILS/lua/record_time'
local make_HC      = require 'Q/RUNTIME/CNTR/lua/make_HC'
local make_configs = require 'Q/RUNTIME/CNTR/lua/make_configs'
local make_kc_so   = require 'Q/TMPL_FIX_HASHMAP/KEY_COUNTER/lua/make_kc_so'
local register_type = require 'Q/UTILS/lua/register_type'
local get_ptr      = require 'Q/UTILS/lua/get_ptr'
local KeyCounter = {}
KeyCounter.__index = KeyCounter

-- FILE struct from http://tigcc.ticalc.org/doc/stdio.html#FILE
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
-- pcall above to ignore error on repeated cdefs of FILE

-- Following hack of __gc is needed because of inability to set
-- __gc on anything other than userdata in 5.1.* 
-- TODO Make sure you are using __gc properly
local setmetatable = require 'Q/UTILS/lua/rs_gc'
setmetatable(KeyCounter, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})
register_type(KeyCounter, "KeyCounter")
--==================================================
function KeyCounter.new(label, vecs, optargs)
  -- label must be unique across all KeyCounters
  if ( not label ) then 
    label = tostring(cutils.RDTSC())
  end
  assert(type(label) == "string")
  -- vecs validated in make_configs()

  local keycounter = setmetatable({}, KeyCounter)
  keycounter._name  = label
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
  ffi.cdef(cdef_str)
  local kc = assert(ffi.load("kc" .. label)); keycounter._kc = kc 
  -- create the configs for the  hashmap 
  local HC = assert(make_HC(optargs, sofile))
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

  -- cdef functions in .so file and load .so file 
  return keycounter
end

function KeyCounter:next()
  print("next(): chunk = ", self._chunk_num)
  local start_time = cutils.rdtsc()
  if ( self._is_eor ) then return false end
  local lens = {}
  local chunks = {}
  for k, v in ipairs(self._vecs) do 
    local len, chunk, nn_chunk = v:get_chunk(self._chunk_num)
    lens[k] = len
    chunks[k] = chunk
    assert(nn_chunk == nil) -- null values not supported 
  end
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
    print("No more chunks")
    self._is_eor = true
    return false
  end
  local data = ffi.new("char *[?]", #self._vecs)
  data = ffi.cast("char **", data)
  for k, v in ipairs(self._vecs) do 
    data[k-1] = get_ptr(chunks[k], "char *")
  end
  local mput_fn = self._name .. "_rsx_kc_put"
  local fn = assert(self._kc[mput_fn])
  print("mput_fn = ", mput_fn)
  --[[
  print(self._H)
  print(self._widths)
  print(data)
  --]]

  local status = fn(self._H, data, self._widths, lens[1])
  -- assert(status == 0)
  -- release chunks 
  for k, v in ipairs(self._vecs) do 
    v:unget_chunk(self._chunk_num)
    assert(nn_chunk == nil) -- null values not supported 
  end
  self._chunk_num = self._chunk_num + 1
  return true -- => more to come 
end

function KeyCounter:eval()
  local start_time = cutils.rdtsc()
  while status == true do
    status = self:next()
  end
  record_time(start_time, "KeyCounter.eval")
  return true
end

function KeyCounter:name()
  return self._name
end

function KeyCounter:nitems()
  return self._H[0].nitems 
end

function KeyCounter:delete()
  print("Destructor called on " .. self._name)
  self._kc["rs_hmap_destroy"](self._H)
  -- TODO P1 How do we make sure that this is called by __gc?
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
