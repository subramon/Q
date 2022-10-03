local cutils   = require 'libcutils'
local cmem     = require 'libcmem'
local ffi      = require 'ffi'
local qc       = require 'Q/UTILS/lua/qcore'
local qcfg     = require 'Q/UTILS/lua/qcfg'
local get_ptr  = require 'Q/UTILS/lua/get_ptr'
local max_num_in_chunk = qcfg.max_num_in_chunk

local function cprint( 
  opfile, -- file for destination fo print
  where, -- nil or lVector of type B1
  lb, -- number
  ub, -- number
  V, -- table of lVectors to be printed
  max_num_in_chunk
  )
  local func_name = "cprint"
  local subs = {}
  subs.fn = func_name
  -- IMPORTANT: In specifying files, Do not start with a backslash
  subs.dotc = "OPERATORS/PRINT/src/cprint.c"
  subs.doth = "OPERATORS/PRINT/inc/cprint.h"
  subs.srcs = { "UTILS/src/get_bit_u64.c" }
  subs.incs = { "OPERATORS/PRINT/inc/", "UTILS/inc/" }
  subs.structs = nil -- no structs need to be cdef'd
  subs.libs = nil -- no libaries need to be linked
  qc.q_add(subs); 

  -- =======================
  local function min(x, y) if x < y then return x else return y end end
  local function max(x, y) if x > y then return x else return y end end
  local nC = #V -- determine number of columns to be printed
  assert(nC > 0)
  local chunk_num = math.floor(lb / max_num_in_chunk) -- first usable chunk
  -- C = pointers to data to be printed
  local C = ffi.new("void *[?]", nC)
  C = ffi.cast("void **", C)
  -- F array of qtypes 
  local F = ffi.new("int[?]", nC)
  F = ffi.cast("int *", F)
  -- W array of widths 
  local W = ffi.new("int[?]", nC)
  W = ffi.cast("int *", W)
  -- START: Assemble F and W
  for i, v in ipairs(V) do 
    local str_qtype = v:qtype()
    local width = v:width()
    -- Note: we create temporary local variables because the
    -- function calls return 2 things not just a single number
    assert(( i >= 1 ) and ( i <= nC ))
    F[i-1] = cutils.get_c_qtype(str_qtype)
    W[i-1] = width
  end

  local c_opfile = ffi.NULL
  if ( opfile ) then 
    c_opfile = ffi.new("char[?]", #opfile+1) 
    ffi.fill(c_opfile, #opfile+1)
    c_opfile = ffi.cast("char *", c_opfile)
    ffi.copy(c_opfile, opfile, #opfile)
  end
  --======================
  while true do 
    local clb = chunk_num * max_num_in_chunk
    local cub = clb + max_num_in_chunk
    if ( clb >= ub ) then break end -- TODO verify boundary conditions
    if ( cub <  lb ) then break end -- TODO verify boundary conditions
    -- [xlb, xub) is what we print from this chunk
    local xlb = max(lb, clb) 
    local xub = min(ub, cub)
    local wlen -- length of where fld if any 
    local cfld = ffi.NULL -- pointer to where fld or nil
    --=========================================
    local chk_len -- to make sure all get_chunk() calls return same length 
    for i, v in ipairs(V) do
      local len, chnk = v:get_chunk(chunk_num)
      if ( not chk_len ) then chk_len = len else assert(chk_len == len) end 
      assert(len > 0)
      C[i-1] = get_ptr(chnk, "void *")
    end
    --=========================================
    if ( where ) then 
      local wchunk
      wlen, wchunk = where:get_chunk(chunk_num)
      assert(wlen > 0)
      if ( where:qtype() == "BL" ) then 
        cfld = get_ptr(wchunk, "bool *")
      elseif ( where:qtype() == "B1" ) then 
        cfld = get_ptr(wchunk, "uint64_t *")
      else
        error("bad qtype for where Vector ")
      end
      assert(chk_len == wlen) 
      error("NOT YET IMPLEMENTED on THE C side")
    end
    --=========================================
    local status = qc[func_name](c_opfile, cfld, C, nC, xlb - clb, 
      xub - xlb, F, W)
    assert(status == 0)
    -- release chunks 
    if ( where ) then 
      where:unget_chunk(chunk_num)
    end
    for i, v in ipairs(V) do
      v:unget_chunk(chunk_num)
    end
    chunk_num = chunk_num + 1 
  end
  return true
end
return cprint
