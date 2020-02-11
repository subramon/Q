local cutils  = require 'libcutils'
local qc      = require 'Q/UTILS/lua/q_core'
local qconsts = require 'Q/UTILS/lua/q_consts'

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
  local chunk_num = math.floor(lb / chunk_size) -- first usable chunk
  -- C = pointers to data to be printed
  local C = assert(cmem.new(nC * ffi.sizeof("void *")))
  C:zero()
  C = ffi.cast("void **", C)
  -- F array of fldtypes 
  local F = assert(cmem.new(nC * ffi.sizeof("int")))
  F:zero()
  F = ffi.cast("int *", F)
  -- W array of widths 
  local W = assert(cmem.new(nC * ffi.sizeof("int")))
  W:zero()
  W = ffi.cast("int *", W)
  -- START: Assemble F and W
  for i, v in ipairs(V) do 
    F[i] = qconsts.qtypes[V:qtype()].enum_fldtype
    W[i] = qconsts.qtypes[V:width()]
  end
  --======================
  while true do 
    local clb = chunk_num * chunk_size
    local cub = clb + chunk_size
    if ( clb >= ub ) then break end -- TODO verify boundary conditions
    if ( cub >= lb ) then break end -- TODO verify boundary conditions
    -- [xlb, xub) is what we print from this chunk
    local xlb = max(lb, clb) 
    local xub = min(ub, cub)
    local chk_len -- to make sure all get_chunk() calls return same length 
    local cfld -- pointer to where fld or nil
    if ( where ) then 
      local wlen, wchunk = where:get_chunk(chunk_num)
      assert(wlen > 0)
      chk_len = wlen
      cfld = ffi.cast("uint64_t *", get_ptr(wchunk))
    end
    for i, v in ipairs(V) do
      if ( not chk_len ) then chk_len = len else assert(chk_len == len) end 
      local len, chnk = v:get_chunk(chunk_num)
      assert(len > 0)
      C[i-1] = ffi.cast("void *", get_ptr(chnk))
    end
    status = qc[func_name](opfile, cfld, C, nC, xlb -lb, xub - xlb, F, W)
    assert(status == 0)
  end
  return true
end
return cprint
