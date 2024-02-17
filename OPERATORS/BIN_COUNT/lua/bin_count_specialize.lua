local ffi       = require 'ffi'
local cmem      = require 'libcmem'
local cutils    = require 'libcutils'
local Scalar    = require 'libsclr'
local lVector   = require 'Q/RUNTIME/VCTRS/lua/lVector'
local get_ptr   = require 'Q/UTILS/lua/get_ptr'
local is_in     = require 'Q/UTILS/lua/is_in'
local to_scalar = require 'Q/UTILS/lua/to_scalar'

local function bin_count_specialize(x, y, optargs)
  local subs = {}
  assert(type(x) == "lVector")
  assert(x:has_nulls() == false)
  local qtypes = { 
    "I1", "I2", "I4", "I8", "UI1", "UI2", "UI4", "UI8",  "F4", "F8", }
  subs.qtype = x:qtype()
  assert(is_in(subs.qtype, qtypes))

  local width = cutils.get_width_qtype(subs.qtype)

  assert(type(y) == "lVector")
  assert(y:has_nulls() == false)
  assert(subs.qtype == y:qtype())
  -- TODO P2 Check that y is sorted ascending and unique
  if ( y:is_eov() == false ) then y:eval() end 
  local nb = y:num_elements() + 1
  subs.nb = nb
  -- which one? TODO P3 subs.max_num_in_chunk = get_max_num_in_chunk(optargs)
  subs.max_num_in_chunk = y:max_num_in_chunk()

  -- need to over-allocate a bit to turn cmem into Vector using put_chunk
  local num_chunks = math.floor(nb / subs.max_num_in_chunk)
  if ( ( num_chunks * subs.max_num_in_chunk ) ~= nb )  then
    num_chunks = num_chunks + 1 
  end 
  local sz = ffi.sizeof("int64_t") * num_chunks * subs.max_num_in_chunk
  local cnt_cmem = cmem.new({qtype = "I8", size = sz})
  cnt_cmem:zero() -- IMPORTANT 
  subs.cnt = get_ptr(cnt_cmem, "I8")

  local sz = width * num_chunks * subs.max_num_in_chunk
  local lb_cmem = cmem.new({qtype = subs.qtype, size = sz})
  subs.lb = get_ptr(lb_cmem, subs.qtype)

  local sz = width * num_chunks * subs.max_num_in_chunk
  local ub_cmem = cmem.new({qtype = subs.qtype, size = sz})
  subs.ub = get_ptr(ub_cmem, subs.qtype)

  local sz = ffi.sizeof("int") * subs.nb
  local lock = cmem.new({qtype = "I4", size = sz})
  lock:zero()
  subs.lock = get_ptr(lock, "I4")

  -- currently, we require floor/ceil to be set explicitly. Relax this
  assert(type(optargs) == "table") 

  assert(type(optargs.floor) == "Scalar") 
  assert(optargs.floor:qtype() == subs.qtype)
  local c = optargs.floor:to_cmem()
  c = get_ptr(c, subs.qtype)
  subs.lb[0] = c[0]

  assert(type(optargs.ceil) == "Scalar") 
  assert(optargs.ceil:qtype() == subs.qtype)
  local c = optargs.ceil:to_cmem()
  c = get_ptr(c, subs.qtype)
  subs.ub[subs.nb-1] = c[0]
  --======================================================
  -- Now, get access to y's data and set other lb/ub values
  y:chunks_to_lma()
  local ycmem, nn_ycmem, ny = y:get_lma_write()
  assert(ny+1 == subs.nb)
  assert(type(ycmem) == "CMEM")
  assert(type(nn_ycmem) == "nil")
  local yptr = get_ptr(ycmem, subs.qtype)
  -- careful of the indexing below 
  for i = 1, ny do 
    subs.lb[i] = yptr[i-1] 
  end
  for i = 1, ny do 
    subs.ub[i-1] = yptr[i-1] 
  end
  y:unget_lma_write()
  --======================================================


  subs.qtype = x:qtype()
  assert(x:has_nulls() == false) -- can be relaxed later 

  subs.fn = "bin_count_" .. subs.qtype 
  subs.ctype = cutils.str_qtype_to_str_ctype(subs.qtype)
  subs.cast_in_as = subs.ctype .. " *"
  subs.cast_lb_as = subs.ctype .. " *"
  subs.cast_ub_as = subs.ctype .. " *"
  subs.cast_cnt_as = "int64_t *"

  subs.tmpl   = "OPERATORS/BIN_COUNT/lua/bin_count.tmpl"
  subs.incdir = "OPERATORS/BIN_COUNT/gen_inc/"
  subs.srcdir = "OPERATORS/BIN_COUNT/gen_src/"
  subs.incs = { "UTILS/inc/", "OPERATORS/BIN_COUNT/gen_inc/" }

  --==============================
  subs.getter = function (x) 
    assert(type(cnt_cmem) == "CMEM")
    local lb = lVector.new( {qtype = subs.qtype, gen = true, 
      has_nulls = false, max_num_in_chunk = subs.max_num_in_chunk})
    lb:put_chunk(lb_cmem, nb)
    lb:eov()

    local ub = lVector.new( {qtype = subs.qtype, gen = true, 
      has_nulls = false, max_num_in_chunk = subs.max_num_in_chunk})
    ub:put_chunk(ub_cmem, nb)
    ub:eov()

    local cnt = lVector.new( {qtype = "I8", gen = true, 
      has_nulls = false, max_num_in_chunk = subs.max_num_in_chunk})
    cnt:put_chunk(cnt_cmem, nb)
    cnt:eov()
    return lb, ub, cnt 
  end
  subs.destructor = function (x) 
    lb_cmem:delete()
    ub_cmem:delete()
    cnt_cmem:delete() 
    lock:delete() 
  end
  return subs
end
return bin_count_specialize
