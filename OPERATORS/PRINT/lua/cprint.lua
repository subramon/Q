local cVector  = require 'libvctr'
local cutils   = require 'libcutils'
local cmem     = require 'libcmem'
local ffi      = require 'ffi'
local qc       = require 'Q/UTILS/lua/q_core'
local qconsts  = require 'Q/UTILS/lua/q_consts'
local get_ptr  = require 'Q/UTILS/lua/get_ptr'

local function cprint( 
  opfile, -- file for destination fo print
  where, -- nil or lVector of type B1
  lb, -- number
  ub, -- number
  V -- table of lVectors to be printed
  )
  -- START: Dynamic compilation
  local func_name = "cprint"
  if ( not qc[func_name] ) then 
    local root = assert(qconsts.Q_SRC_ROOT)
    assert(cutils.isdir(root))
    local subs = {}
    subs.fn = func_name
    subs.dotc = root .. "/OPERATORS/PRINT/src/cprint.c"
    subs.doth = root .. "/OPERATORS/PRINT/inc/cprint.h"
    qc.q_add(subs); print("Dynamic compilation kicking in... ")
  end 
  -- STOP : Dynamic compilation
  assert(qc[func_name], "Symbol not available" .. func_name)

  cutils.delete(opfile) -- clean out any existing file
  local function min(x, y) if x < y then return x else return y end end
  local function max(x, y) if x > y then return x else return y end end
  local nC = #V -- determine number of columns to be printed
  local chunk_size = cVector.chunk_size()
  local chunk_num = math.floor(lb / chunk_size) -- first usable chunk
  -- C = pointers to data to be printed
  local C = assert(cmem.new({size = (nC * ffi.sizeof("void *")), name = "C"}))
  C:zero()
  local C = get_ptr(C, "void **")
  -- F array of fldtypes 
  local F = assert(cmem.new({size = (nC * ffi.sizeof("int")), name = "F"}))
  F:zero()
  F = get_ptr(F, "I4")
  -- W array of widths 
  local W = assert(cmem.new({size = nC * ffi.sizeof("int"), name = "W"}))
  W:zero()
  W = get_ptr(W, "I4")
  -- START: Assemble F and W
  for i, v in ipairs(V) do 
    local qtype = v:fldtype()
    qtype = qconsts.qtypes[qtype].cenum -- convert string to integer for C
    local width = v:width()
    -- Note: we create temporary local variables because the
    -- function calls return 2 things not just a single number
    assert(( i >= 1 ) and ( i <= nC ))
    F[i-1] = qtype
    W[i-1] = width
  end
  local c_opfile = cmem.new({ size = #opfile+1, qtype = "SC", name='fname'})
  c_opfile:set(opfile)
  c_opfile = get_ptr(c_opfile, "char *")
  --======================
  while true do 
    local clb = chunk_num * chunk_size
    local cub = clb + chunk_size
    if ( clb >= ub ) then break end -- TODO verify boundary conditions
    if ( cub <  lb ) then break end -- TODO verify boundary conditions
    -- [xlb, xub) is what we print from this chunk
    local xlb = max(lb, clb) 
    local xub = min(ub, cub)
    local wlen -- length of where fld if any 
    local chk_len -- to make sure all get_chunk() calls return same length 
    local cfld -- pointer to where fld or nil
    if ( where ) then 
      local wchunk
      wlen, wchunk = where:get_chunk(chunk_num)
      assert(wlen > 0)
      cfld = get_ptr(wchunk, "uint64_t *")
    end
    for i, v in ipairs(V) do
      local len, chnk = v:get_chunk(chunk_num)
      if ( not chk_len ) then chk_len = len else assert(chk_len == len) end 
      assert(len > 0)
      C[i-1] = get_ptr(chnk, "void *")
    end
    if ( wlen ) then assert( chk_len == wlen) end 
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
