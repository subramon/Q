-- Coding convention. Local variables start with underscore
require 'Q/UTILS/lua/strict'
local ffi          = require 'ffi'
local cutils       = require 'libcutils'
local lgutils      = require 'liblgutils'
local Scalar       = require 'libsclr'
local record_time  = require 'Q/UTILS/lua/record_time'
local qcfg         = require 'Q/UTILS/lua/qcfg'
local make_HC      = require 'Q/RUNTIME/CNTR/lua/make_HC'
local make_configs = require 'Q/RUNTIME/CNTR/lua/make_configs'
local make_kc_so   = require 'Q/TMPL_FIX_HASHMAP/KEY_COUNTER/lua/make_kc_so'
local register_type = require 'Q/UTILS/lua/register_type'
local get_ptr      = require 'Q/UTILS/lua/get_ptr'
local strip_pound  = require 'Q/UTILS/lua/strip_pound'
local is_base_qtype  = require 'Q/UTILS/lua/is_base_qtype'
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
  local inc_file = inc_dir .. "/rs_hmap_destroy.h"
  assert(cutils.isfile(inc_file), "File not found " .. inc_file)
  local cdef_str = assert(strip_pound(inc_file), "strip failed")
  status = pcall(ffi.cdef, cdef_str)
  -- print(cdef_str)
  --
  -- repeat cdef for custom get function
  local inc_dir = root_dir .. "/TMPL_FIX_HASHMAP/KEY_COUNTER/" .. label .. "/inc/" 
  assert(cutils.isdir(inc_dir), "Directory not found " .. inc_dir)
  local inc_file = inc_dir .. "/rs_hmap_get.h"
  assert(cutils.isfile(inc_file), "File not found " .. inc_file)
  local cdef_str = assert(strip_pound(inc_file), "strip failed")
  status = pcall(ffi.cdef, cdef_str)
  if ( status ) then 
    print("cdef for get worked")
  else
    print("cdef for get failed")
  end
  -- print(cdef_str)
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
  -- record memory usage 
  local bkttype = keycounter._label .. "_rs_hmap_bkt_t";
  local bktsize = ffi.sizeof(bkttype)
  local n = bktsize * keycounter._H[0].size -- for bkts
  lgutils.incr_mem_used(n)
  local n = ffi.sizeof("bool") * keycounter._H[0].size -- for bkt_full
  lgutils.incr_mem_used(n)
  --================================================

  -- just to check that this function exists 
  local destroy_name = label .. "_rs_hmap_destroy"
  local destroy_fn = assert(kc[destroy_name])
  local get_name = label .. "_rs_hmap_get"
  print(get_name)
  local get_fn = assert(kc[get_name])

  print("Created KeyCouter")
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
  -- record memory usage 
  local bkttype = keycounter._label .. "_rs_hmap_bkt_t";
  local bktsize = ffi.sizeof(bkttype)
  local n = bktsize * keycounter._H[0].size -- for bkts
  lgutils.incr_mem_used(n)
  local n = ffi.sizeof("bool") * self._H[0].size -- for bkt_full
  lgutils.incr_mem_used(n)
  --================================================
  -- print("Cloned KeyCouter")
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
    print("A: No more chunks", self._chunk_num)
    self._is_eor = true
    -- vectors used to construct counter must be stable 
    for k, v in ipairs(self._vecs) do assert(v:is_eov()) end
    return false
  end
  local data = ffi.new("char *[?]", #self._vecs)
  data = ffi.cast("char **", data)
  for k, v in ipairs(self._vecs) do 
    data[k-1] = get_ptr(chunks[k], "char *")
  end
  local mput_fn = self._label .. "_rsx_kc_put"
  local fn = assert(self._kc[mput_fn])

  local old_size = self._H[0].size -- record size before insert
  local status = fn(self._H, data, self._widths, lens[1])
  assert(status == 0)
  local new_size = self._H[0].size -- record size after insert
  -- release chunks 
  for k, v in ipairs(self._vecs) do 
    v:unget_chunk(self._chunk_num)
  end
  --=====================================================
  -- record increase in memory usage 
  if ( new_size > old_size ) then 
    local bkttype = self._label .. "_rs_hmap_bkt_t";
    local bktsize = ffi.sizeof(bkttype)
    local n = bktsize * (new_size - old_size) -- for bkts
    lgutils.incr_mem_used(n)
    local n = ffi.sizeof("bool") * (new_size - old_size) -- for bkt_full
    lgutils.incr_mem_used(n)
  end
  --=====================================================
  if ( lens[1] < self._vecs[1]:max_num_in_chunk() ) then 
    print("B: No more chunks", self._chunk_num)
    self._is_eor = true
    -- vectors used to construct counter must be stable 
    for k, v in ipairs(self._vecs) do assert(v:is_eov()) end
    return false
  end
  --=====================================================
  self._chunk_num = self._chunk_num + 1
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

-- returns size of  hashmap
function KeyCounter:size()
  return self._H[0].size 
end

-- returns number of items in the hashmap
function KeyCounter:nitems()
  return self._H[0].nitems 
end

-- returns whether KeyCounter has completed consuming its  input
function KeyCounter:is_eor()
  return self._is_eor
end

function KeyCounter:sum_count()
  if ( self._sum_count ) then  
    return self._sum_count
  end
  local kc = assert(self._kc)
  assert(type(kc) == "userdata")
  local sum_name = self._label .. "_rsx_kc_sum_count"
  local sum_fn = assert(kc[sum_name])
  --============================================
  local sum_count = ffi.new("uint64_t[?]", 1)
  local status = sum_fn(self._H, sum_count)
  assert(status == 0)
  self._sum_count = sum_count[0]  -- note memoization
  return sum_count[0]
end

function KeyCounter:__gc()
  local kc = assert(self._kc)
  assert(type(kc) == "userdata")
  local destroy_name = self._label .. "_rs_hmap_destroy"
  local destroy_fn = assert(kc[destroy_name])
  -- record decrease in memory usage after destroy
  local bkttype = self._label .. "_rs_hmap_bkt_t";
  local bktsize = ffi.sizeof(bkttype)
  local n = bktsize * self._H[0].size -- for bkts
  lgutils.decr_mem_used(n)
  local n = ffi.sizeof("bool") * self._H[0].size -- for bkt_full
  lgutils.decr_mem_used(n)
  --============================================
  destroy_fn(self._H)
  return true
end

function KeyCounter:get_count(sclrs)
  assert(type(sclrs) == "table")
  assert(#sclrs == #self._vecs)
  for k, s in ipairs(sclrs) do 
    if ( type(s) == "number") then 
      sclrs[k] = Scalar.new(s, self._vecs[k]:qtype())
    end
    s = sclrs[k]
    assert(type(s) == "Scalar")
    assert(s:qtype() == self._vecs[k]:qtype())
  end
  -- make a key and value 
  local keytype = self._label .. "_rs_hmap_key_t";
  local key = ffi.new(keytype .. "[?]", 1)
  key = ffi.cast(keytype .. " *", key)

  local valtype = self._label .. "_rs_hmap_val_t";
  local val = ffi.new(valtype .. "[?]", 1)
  val = ffi.cast(valtype .. " *", val)

  local is_found = ffi.new("bool[?]", 1)
  local where_found = ffi.new("uint32_t[?]", 1)
    --==================================================
  for k, s in ipairs(sclrs) do 
    local sclr_val = ffi.cast("SCLR_REC_TYPE *", s)
    local key_id = "key" .. tostring(k)
    local sqtype = s:qtype()
    if ( is_base_qtype(sqtype) ) then 
      key[0][key_id] = sclr_val[0].val[string.lower(sqtype)]
    elseif ( sqtype == "SC" ) then 
      error("TODO")
    else
      error("Bad scalar qtype = " .. sqtype)
    end
  end
    --==================================================
  local kc = assert(self._kc)
  assert(type(kc) == "userdata")
  local get_name = self._label .. "_rs_hmap_get"
  local get_fn = assert(kc[get_name])
  local status = get_fn(self._H, key, val, is_found, where_found)
  assert(status == 0)
  return key, keytype, val, valtype, is_found, where_found
end

function KeyCounter:condense()
  assert(self._is_eor) -- counter must be stable
  local count_chunk_num = 0; local count_offset = 0
  local guid_chunk_num = 0; local guid_offset = 0
  local bufsz = qcfg.max_num_in_chunk 
  local function gen(mode)
    assert((mode == "guid") or ( mode == "count"))
    -- NOTE: Both guid and count are uint32_t
    local buf = cmem.new(bufsz * ffi.sizeof("uint32_t"))
    buf:stealable(true)
    local buf_idx = 0
    if ( mode == "guid"  ) then start = guid_offset end 
    if ( mode == "count" ) then start = count_offset end 
    for i = start, self._H[0].size do 
      if ( buf_idx == bufsz ) then 
        start = i
        break
      else
        if ( _H[0].bkt_full[i] ) then
          buf[buf_idx] = _H[0].bkts[i].val.count
          buf_idx = buf_idx + 1 
        end
      end
    end
    if ( mode == "guid"  ) then guid_offset  = start  end 
    if ( mode == "count" ) then count_offset = start end 
    if ( buf_idx == 0 ) then buf:delete(); buf = nil end 
    return buf_idx, buf
  end
  local gen_count = gen_count("count") 
  local gen_guid = gen_guid("guid") 
  local vargs = {}
  vargs.count = {gen = gen_count, qtype = "I4", has_nulls=false}
  vargs.guid  = {gen = gen_guid,  qtype = "I4", has_nulls=false}
  return lVector(vargs.count), lVector(vargs.guid)
end

function KeyCounter:make_permutation(vecs)
  error("TODO")
  --[[
  assert(self._is_eor) -- counter must be stable
  assert(type(vecs) == "table")
  assert(#vecs == #self._vecs)
  for k, v in ipairs(vecs) do 
    assert(v:qtype() == self._vecs[k].qtype())
    assert(v:width() == self._vecs[k].width())
  end
  -- all incoming vectors should have same chunk size 
  for k, v in ipairs(vecs) do 
    assert(v:max_num_in_chunk() == vecs[k]:max_num_in_chunk())
  end
  -- incoming vetors should be stable 
  for k, v in ipairs(vecs) do assert(v:is_eov()) end
  -- incomin vectors should be same length as number of items in Counte
  local nitems = self._H[0].nitems
  for k, v in ipairs(vecs) do assert(v:length() == nitems) end 
  -- allocate space for outgoing vector 
  local outbuf = cmem.new({size = nitems, qtype = "I8"})
  local permutation = assert(get_ptr(outbuf, "I8"))
  -- set up pointers to incoming data 
  local data = ffi.new("char *[?]", #vecs)
  data = ffi.cast("char **", data)
  for k, v in ipairs(vecs) do 
    data[k-1] = get_ptr(chunks[k], "char *")
  end
  -- 
  local perm_name = self._label .. "_rsx_kc_make_permutation"
  local perm_fn = assert(kc[perm_name])
--   local status = perm_fn(self._H, data, self._widths, nitems, permutation)
--  assert(status == 0)
  -- convert permutation into a vector 
  --]]
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
