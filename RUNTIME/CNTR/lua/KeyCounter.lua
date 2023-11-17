-- Coding convention. Local variables start with underscore
require 'Q/UTILS/lua/strict'
local ffi          = require 'ffi'
local cutils       = require 'libcutils'
local cmem         = require 'libcmem'
local lgutils      = require 'liblgutils'
local Scalar       = require 'libsclr'
local lVector      = require 'Q/RUNTIME/VCTRS/lua/lVector'
local record_time  = require 'Q/UTILS/lua/record_time'
local qcfg         = require 'Q/UTILS/lua/qcfg'
local make_HC      = require 'Q/RUNTIME/CNTR/lua/make_HC'
local make_configs = require 'Q/RUNTIME/CNTR/lua/make_configs'
local mod_hmap_storage = require 'Q/RUNTIME/CNTR/lua/mod_hmap_storage'
local chk_vecs_old_new = require 'Q/RUNTIME/CNTR/lua/chk_vecs_old_new'
local chk_chnks_lens_across_vecs = require 'Q/RUNTIME/CNTR/lua/chk_chnks_lens_across_vecs'
local make_kc_so   = require 'Q/TMPL_FIX_HASHMAP/KEY_COUNTER/lua/make_kc_so'
local register_type = require 'Q/UTILS/lua/register_type'
local get_ptr      = require 'Q/UTILS/lua/get_ptr'
local strip_pound  = require 'Q/UTILS/lua/strip_pound'
local is_base_qtype  = require 'Q/UTILS/lua/is_base_qtype'
-- for SCLR_REC_TYPE, cdef sclr_struct.h
local qc        = require 'Q/UTILS/lua/qcore'
qc.q_cdef("RUNTIME/SCLR/inc/sclr_struct.h", { "UTILS/inc/" })

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
-- some local functions
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
  -- for k, v in pairs(configs) do print(k, v) end 
  -- call function to create .so file and functions to be cdef'd
  -- print("in KeyCounter")
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
  --
  -- repeat cdef for custom get function
  local inc_dir = root_dir .. "/TMPL_FIX_HASHMAP/KEY_COUNTER/" .. label .. "/inc/" 
  assert(cutils.isdir(inc_dir), "Directory not found " .. inc_dir)
  local inc_file = inc_dir .. "/rs_hmap_get.h"
  assert(cutils.isfile(inc_file), "File not found " .. inc_file)
  local cdef_str = assert(strip_pound(inc_file), "strip failed")
  status = pcall(ffi.cdef, cdef_str)
  --
  if ( status ) then 
    print("cdef for get worked")
  else
    print("cdef for get failed")
  end
  --]]
  -- print(cdef_str)
  --==========================================================
  local kc = ffi.load("kc" .. label)
  -- print("Loaded " .. "kc" .. label)
  keycounter._kc = kc 
  -- create the configs for the  hashmap 
  local HC = assert(make_HC(optargs, sofile))
  local htype = label .. "_rs_hmap_t"
  -- create empty hashmap
  local H = ffi.new(htype .. "[?]", 1)
  local init_name = label .. "_rs_hmap_instantiate"
  local init_fn = assert(kc[init_name])
  -- print("Checked that function exists -> ", init_name)
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
  -- record increase in memory usage 
  mod_hmap_storage(keycounter._label, keycounter._H[0].size, "incr")
  -- just to check that this function exists 
  local destroy_name = label .. "_rs_hmap_destroy"
  local destroy_fn = assert(kc[destroy_name])
  -- print("Checked that function exists -> ", destroy_name)
  local get_name = label .. "_rs_hmap_get"
  local get_fn = assert(kc[get_name])
  -- print("Checked that function exists -> ", get_name)
  print("Created KeyCounter")
  return keycounter
end

function KeyCounter:clone(vecs, optargs)
  if ( optargs ) then
    assert(type(optargs) == "table")
    assert(not optargs.label) -- cannot set in clone
  end
  --===================================
  local name
  if ( optargs and optargs.name ) then 
    assert(type(optargs.name) == "string")
    name = optargs.name
  end
  --===================================
  -- vecs must match that used to create KeyCounter being cloned
  assert(#vecs == #self._vecs)
  for k, v in ipairs(vecs) do 
    assert(type(v) == "lVector")
    assert(v:qtype() == self._vecs[k]:qtype())
    assert(v:width() == self._vecs[k]:width())
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
  -- record increase in memory usage 
  mod_hmap_storage(keycounter._label, keycounter._H[0].size, "incr")
  print("Cloned KeyCouter")
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
  local len = chk_chnks_lens_across_vecs(lens, chunks, #self._vecs)
  if ( len == 0 ) then 
    print("A: No more chunks", self._chunk_num)
    self._is_eor = true
    -- vectors used to construct counter must be stable 
    for k, v in ipairs(self._vecs) do assert(v:is_eov()) end
    return false
  end
  --==================================================
  local data = ffi.new("char *[?]", #self._vecs)
  data = ffi.cast("char **", data)
  for k, v in ipairs(self._vecs) do 
    data[k-1] = get_ptr(chunks[k], "char *")
  end
  local mput_fn = self._label .. "_rsx_kc_put"
  local fn = assert(self._kc[mput_fn])

  local old_size = self._H[0].size -- record size before insert
  local status = fn(self._H, data, self._widths, len)
  assert(status == 0)
  local new_size = self._H[0].size -- record size after insert
  -- release chunks 
  for k, v in ipairs(self._vecs) do 
    v:unget_chunk(self._chunk_num)
  end
  --=====================================================
  -- record increase in memory usage 
  if ( new_size > old_size ) then 
    mod_hmap_storage(self._label, new_size - old_size, "incr")
  end
  --=====================================================
  if ( len < self._vecs[1]:max_num_in_chunk() ) then 
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
  if ( name ) then 
    assert(type(name) == "string")
  end
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
  print("Destructor on ", self._name)
  print("mem before destruct = ", lgutils.mem_used())
  local kc = assert(self._kc)
  assert(type(kc) == "userdata")
  local destroy_name = self._label .. "_rs_hmap_destroy"
  local destroy_fn = assert(kc[destroy_name])
  -- record decrease in memory usage after destroy
  mod_hmap_storage(self._label, self._H[0].size, "decr")
  --============================================
  destroy_fn(self._H)
  if ( self._auxvals ) then 
    for k, v in pairs(self._auxvals) do 
      v:delete()
    end
  end
  print("mem after destruct = ", lgutils.mem_used())
  return true
end

function KeyCounter:get_val(sclrs)
  assert(type(sclrs) == "table")
  assert(#sclrs == #self._vecs)
  for k, s in ipairs(sclrs) do 
    -- special case for SC, need to make sure string is not too large 
    if ( type(s) == "string" ) then 
      assert(self._vecs[k]:qtype() == "SC")
      assert(#s < self._vecs[k]:width()) 
    end 
    --=====
    sclrs[k] = assert(Scalar.new(s, self._vecs[k]:qtype()))
    assert(type(sclrs[k]) == "Scalar")
    assert(sclrs[k]:qtype() == self._vecs[k]:qtype())
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
    assert(type(s) == "Scalar")
    local sclr_val = ffi.cast("SCLR_REC_TYPE *", s)
    local key_id = "key" .. tostring(k)
    local sqtype = s:qtype()
    if ( is_base_qtype(sqtype) ) then 
      key[0][key_id] = sclr_val[0].val[string.lower(sqtype)]
    elseif ( sqtype == "SC" ) then 
      local x = ffi.string(sclr_val[0].val.str)
      ffi.copy(key[0][key_id], x)
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

function KeyCounter:condense(fld)
  assert(type(fld) == "string")
  assert(self._is_eor) -- counter must be stable
  local offset = 0 -- where to start from for next chunk
  local bufsz = qcfg.max_num_in_chunk 
  local val_from_aux = true -- value to be condensed in self._auxvals
  local hidx = false
  if ( ( fld == "count" ) or ( fld == "guid" ) or ( fld == "idx" ) ) then
    val_from_aux = false
    if ( fld == "idx" ) then
      hidx = true
    end
  end
  local bufwidth  = 0
  local bufqtype
  local inbuf 
  if ( val_from_aux ) then
    inbuf = assert(self._auxvals[fld])
    assert(type(inbuf == "CMEM"))
    bufqtype = assert(inbuf:qtype())
    inbuf = get_ptr(inbuf, bufqtype)
  else
    bufqtype = "UI4" 
    if ( fld == "count" ) then 
      bufqtype = "UI8"  -- this is potentially over-kill
    end 
    -- NOTE: guid, count, idx are uint32_t
    -- This is limitation of current implementation
    -- Can be changed but serious surgery required
  end
  bufwidth = cutils.get_width_qtype(bufqtype)
  assert(bufwidth > 0)
  local is_eov = false -- for debugging 
  --=========================================
  local function gen()
    assert(is_eov == false)
    -- print("mem before condensor = ", lgutils.mem_used())
    local buf = cmem.new(bufsz * bufwidth)
    buf:stealable(true)
    -- print("mem after condensor = ", lgutils.mem_used())
    local bufptr = get_ptr(buf, bufqtype)
    local buf_idx = 0
    local start = offset
    local bkts = self._H[0].bkts
    for i = start, self._H[0].size do 
      if ( buf_idx == bufsz ) then 
        -- next time, we must start from position i
        offset = i
        break
      end
      if ( self._H[0].bkt_full[i] ) then
        if( val_from_aux ) then 
          bufptr[buf_idx] = inbuf[i]
        else
          if ( hidx ) then 
            bufptr[buf_idx] = i
          else
            bufptr[buf_idx] = bkts[i].val[fld]
          end
        end
        buf_idx = buf_idx + 1 
      end
    end
    if ( buf_idx < bufsz ) then is_eov = true end
    if ( buf_idx == 0 ) then buf:delete(); buf = nil end 
    return buf_idx, buf
  end
  local vargs = {}
  if ( bufqtype == "UI4" ) then bufqtype = "I4" end  --TODO P3
  if ( bufqtype == "UI8" ) then bufqtype = "I8" end  --TODO P3
  vargs = {gen = gen, qtype = bufqtype, has_nulls=false}
  return lVector(vargs)
end

function KeyCounter:make_cum_count()
  if ( ( self._auxvals ) and ( self._auxvals.cum_count ) ) then 
    assert(type(self._auxvals.cum_count) == "CMEM")
    return true
  end
  local size = self._H[0].size
  local cmem = cmem.new({
    size = size * ffi.sizeof("uint64_t"), qtype = "UI8"})
  cmem:zero()
  local cum_count = get_ptr(cmem, "UI8")
  local lua_impl = false -- set to true for testing 
  local x_sum_count -- independent of Lua or C implementation
  if ( lua_impl ) then 
    local sum_count = 0 -- Lua implementation
    local bkts = self._H[0].bkts
    local bkt_full = self._H[0].bkt_full
    for i = 0, size do 
      if ( bkt_full[i] ) then
        local l_count = bkts[i].val.count
        cum_count[i] = sum_count
        sum_count  = sum_count + l_count
      end
    end
    x_sum_count = sum_count
  else
    local cum_count_name = self._label .. "_rsx_kc_cum_count"
    local cum_count_fn = assert(self._kc[cum_count_name])
    local sum_count = ffi.new("uint64_t[?]", 1) -- for C implementation
    local status = cum_count_fn(self._H, cum_count, sum_count)
    assert(status == 0)
    x_sum_count = sum_count[0]
  end
  if ( self._sum_count ) then assert(self._sum_count == x_sum_count)  end
  -- START memoization 
  self._sum_count = x_sum_count  
  if ( self._auxvals ) then 
    assert(type(self._auxvals) == "table")
  else
    self._auxvals = {}
    self._auxvals.cum_count = cmem
  end
  -- STOP  memoization 
  return true 
end

function KeyCounter:make_permutation(vecs)
  assert(self._is_eor) -- counter must be stable
  assert(chk_vecs_old_new(vecs, self._vecs))
  -- NOT NECESSARY incoming vetors should be stable 
  -- for k, v in ipairs(vecs) do assert(v:is_eov()) end
  -- incoming vectors should be same length as number of items in KeyCounter
  local permute_name = self._label .. "_rsx_kc_make_permutation"
  local permute_fn = assert(self._kc[permute_name])
  --===========================
  -- set up some stuff shared across function invocations
  local bufsz = qcfg.max_num_in_chunk
  local nitems = self._H[0].nitems
  local run_count_sz = nitems * ffi.sizeof("uint32_t")
  local run_count = assert(cmem.new(run_count_sz))
  run_count:zero()
  local l_chunk_num = 0
  local run_ptr = get_ptr(run_count, "UI4")
  if ( ( self._auxvals ) and ( self._auxvals.cum_count ) ) then 
    -- nothing to do 
  else
    self:make_cum_count()
  end
  assert(self._auxvals.cum_count)
  local cum_ptr = get_ptr(self._auxvals.cum_count, "UI8")
  local function gen(chunk_num)
    -- print("Permutation ", chunk_num)
    assert(chunk_num == l_chunk_num)
    local lens = {}
    local chunks = {}
    for k, v in ipairs(vecs) do 
      local len, chunk, nn_chunk = v:get_chunk(chunk_num)
      lens[k] = len
      chunks[k] = chunk
      assert(nn_chunk == nil) -- null values not supported 
    end
    --================================================
    local len = chk_chnks_lens_across_vecs(lens, chunks, #vecs)
    if ( len == 0 ) then 
      print("C: No more chunks", self._chunk_num)
      run_count:delete()
      -- vectors used to construct permutation must be stable 
      for k, v in ipairs(vecs) do assert(v:is_eov()) end
      -- We can now check that lengths match up
      for k, v in ipairs(vecs) do 
        assert(v:num_elements() == self._vecs[k]:num_elments())
      end
      return 0
    end
    --================================================
    local data = ffi.new("char *[?]", #vecs)
    data = ffi.cast("char **", data)
    for k, v in ipairs(vecs) do 
      data[k-1] = get_ptr(chunks[k], "char *")
    end
    local perm_buf = cmem.new(bufsz*ffi.sizeof("uint64_t"))
    perm_buf:stealable(true)
    local perm_ptr = get_ptr(perm_buf, "UI8")
    local sum_count = assert(self._sum_count)
    local status = 
      permute_fn(self._H, data, self._widths, len, 
      sum_count, run_ptr, cum_ptr, perm_ptr)
    assert(status == 0)
    l_chunk_num = l_chunk_num + 1 
    for k, v in ipairs(vecs) do 
      v:unget_chunk(chunk_num)
    end
    return len, perm_buf
  end
  local vargs = {}
  -- TODO P3 Ideally, this should be UI8
  local vargs = {gen = gen, qtype = "I8", has_nulls=false}
  return lVector(vargs)
end
-- given a vector of keys (technically a table of vectors)
-- we find the position in the hash table where each key is stored
-- obviously, this makes sense only when no more updates are
-- going to be performed on the hash table. Note that inserts
-- may move things around but puts and updates do not 
function KeyCounter:get_hidx(vecs)
  assert(self._is_eor) -- counter must be stable
  assert(type(vecs) == "table")
  assert(chk_vecs_old_new(vecs, self._vecs))
  local get_idx_name = self._label .. "_rsx_kc_get_idx"
  local get_idx_fn = assert(self._kc[get_idx_name])
  -- NOT NECESSARY incoming vetors should be stable 
  -- for k, v in ipairs(vecs) do assert(v:is_eov()) end
  -- incoming vectors should be same length as number of items in Counte
  -- set up some stuff shared across function invocations
  local l_chunk_num = 0
  local out_qtype = "UI4"  
  -- since we are creating an index into the hash table and the 
  -- hash table cannot have size >= 2^32, UI4 suffices
  local out_width = cutils.get_width_qtype(out_qtype)
  assert(out_width > 0)
  local bufsz = qcfg.max_num_in_chunk
  local function gen(chunk_num)
    assert(chunk_num == l_chunk_num)
    --================================================
    local lens = {}
    local chunks = {}
    for k, v in ipairs(vecs) do 
      local len, chunk, nn_chunk = v:get_chunk(chunk_num)
      lens[k] = len
      chunks[k] = chunk
      assert(nn_chunk == nil) -- null values not supported 
    end
    local len = chk_chnks_lens_across_vecs(lens, chunks, #vecs)
    --================================================
    if ( len == 0 ) then 
      print("D: No more chunks", self._chunk_num)
      -- vectors used to construct hash-join must be stable 
      for k, v in ipairs(vecs) do assert(v:is_eov()) end
      return 0
    end
    --================================================
    local data = ffi.new("char *[?]", #vecs)
    data = ffi.cast("char **", data)
    for k, v in ipairs(vecs) do 
      data[k-1] = get_ptr(chunks[k], "char *")
    end
    local out_buf = cmem.new(bufsz * out_width)
    out_buf:stealable(true)
    local out_ptr = get_ptr(out_buf, out_qtype)
    local status = get_idx_fn(self._H, data, self._widths, len, out_ptr)
    assert(status == 0)
    l_chunk_num = l_chunk_num + 1 
    for k, v in ipairs(vecs) do 
      v:unget_chunk(chunk_num)
    end
    return len, out_buf
  end
  local vargs = {}
  if ( out_qtype == "UI4" ) then out_qtype = "I4" end  --TODO P3
  local vargs = {gen = gen, qtype = out_qtype, has_nulls=false}
  return lVector(vargs)
end
function KeyCounter:map_out(hidx, fld)
  assert(type(hidx) == "lVector")
  assert((hidx:qtype() == "I4" ) or (hidx:qtype() == "UI4" ))
  assert(type(fld) == "string")
  assert(self._is_eor) -- counter must be stable
  local bufsz = hidx:max_num_in_chunk()
  local from_qtype 
  local from_buf
  local from_ptr = ffi.NULL
  --=====================================
  -- Figure out where you are going to get data from 
  local val_from_aux = true -- value to be mapped out in self._auxvals
  local native
  if ( fld == "count" ) or ( fld == "guid" ) then
    val_from_aux = false
    from_qtype = "UI4" -- NOTE: Both guid and count are uint32_t
    native = true 
  else
    from_buf = assert(self._auxvals[fld])
    assert(type(from_buf == "CMEM"))
    from_qtype = assert(from_buf:qtype())
    from_ptr = get_ptr(from_buf, from_qtype)
    native = false
  end
  local from_width = cutils.get_width_qtype(from_qtype)
  assert(from_width > 0)
  local to_qtype = from_qtype
  local to_width = from_width
  --=====================================

  local map_out_name = self._label .. "_rsx_kc_map_out"
  if ( native ) then 
    map_out_name = map_out_name .. "_native"
  end
  local map_out_fn = assert(self._kc[map_out_name])
  local l_chunk_num = 0
  local function gen(chunk_num)
    assert(chunk_num == l_chunk_num)
    local len, hidx_chunk = hidx:get_chunk(chunk_num)
    assert(len <= bufsz)
    --================================================
    if ( len == 0 ) then 
      print("E: No more chunks", self._chunk_num)
      return 0
    end
    --================================================
    local hidx_ptr = get_ptr(hidx_chunk, "UI4")
    local to_buf = cmem.new(bufsz * to_width)
    to_buf:stealable(true)
    local to_ptr = get_ptr(to_buf, to_qtype)
    local status
    if ( native ) then 
      status = map_out_fn(self._H, fld, len, hidx_ptr, to_ptr)
    else
      error("TBC TODO")
    end
    assert(status == 0)
    hidx:unget_chunk(chunk_num)
    l_chunk_num = l_chunk_num + 1 
    return len, to_buf
  end
  local vargs = {}
  local vargs = {gen = gen, qtype = to_qtype, has_nulls=false}
  return lVector(vargs)
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
