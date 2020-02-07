local Q       = require 'Q/q_export'
local qc      = require 'Q/UTILS/lua/q_core'
local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi     = require 'ffi'
local cVector = require 'libvctr'
local cmem    = require 'libcmem'
local lVector = require 'Q/RUNTIME/VCTR/lua/lVector'
local chk_subs= require 'Q/OPERATORS/IFXTHENYELSEZ/lua/chk_subs'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'

local function expander_ifxthenyelsez(variation, x, y, z)
  assert(type(x) == "lVector")
  assert(type(y) == "lVector")
  assert(type(z) == "lVector")
  local spfn = require("Q/OPERATORS/IFXTHENYELSEZ/lua/ifxthenyelsez_specialize" )
  assert(type(spfn) == "function")
  local status, subs = pcall(spfn, variation, x, y, z)
  if ( not status ) then print(subs); error(status) end
  assert(chk_subs(subs))
  local func_name = assert(subs.fn)
  -- START: Dynamic compilation
  if ( not qc[func_name] ) then
    qc.q_add(subs); print("Dynamic compilation kicking in... ")
  end
  -- STOP: Dynamic compilation
  assert(qc[func_name], "Symbol not defined " .. func_name)

  -- allocate buffer for output
  local chunk_size = cVector.chunk_size() 
  local wbufsz = cVector.chunk_size() * ffi.sizeof(subs.ctype)
  local wbuf = cmem.new(0)
  local l_chunk_num = 0
  local cst_x_as = qconsts.qtypes[x:fldtype()].ctype .. "*"
  local cst_y_as = qconsts.qtypes[y:fldtype()].ctype .. "*"
  local cst_z_as = qconsts.qtypes[z:fldtype()].ctype .. "*"
  local cst_w_as = qconsts.qtypes[subs.qtype].ctype .. "*"
  --
  local function gen(chunk_num)
    local cst_xptr, cst_yptr, cst_zptr, cst_wbuf
    assert(chunk_num == l_chunk_num)
    if ( not wbuf:is_data() ) then
      wbuf = cmem.new({ size = wbufsz, qtype = subs.ctype})
      wbuf:is_stealable(true)
    end
    local xlen, xptr = x:chunk(l_chunk_num) 
    if ( xlen == 0 )  then
      return 0, nil, nil
    end
    if ( variation = "vv" ) then 
      local ylen, yptr = y:chunk(l_chunk_num) 
      local zlen, zptr = z:chunk(l_chunk_num) 
      assert(xlen == ylen)
      assert(xlen == zlen)
      cst_yptr = ffi.cast(cst_y_as, get_ptr(yptr))
      cst_zptr = ffi.cast(cst_z_as, get_ptr(zptr))
    elseif ( variation = "vs" ) then 
      local ylen, yptr = y:chunk(l_chunk_num) 
      assert(xlen == ylen)
      cst_yptr = ffi.cast(cst_y_as, get_ptr(yptr))
      cst_zptr = XXXXXX
    elseif ( variation = "sv" ) then 
      cst_yptr = XXXXXX
      local zlen, zptr = y:chunk(l_chunk_num) 
      assert(xlen == zlen)
      cst_zptr = ffi.cast(cst_z_as, get_ptr(zptr))
    elseif ( variation = "ss" ) then 
      cst_yptr = XXXXXX
      cst_zptr = XXXXXX
    else
      error("")
    end
    --=============================================
    cst_xptr = ffi.cast(cst_x_as, get_ptr(xptr))
    cst_wbuf = ffi.cast(cst_w_as, get_ptr(wbuf))    
    --=============================================
    local start_time = qc.RDTSC()
    local status = qc[func_name](cst_xptr, cst_yptr, cst_zptr, cst_wbuf, ylen)
    record_time(start_time, func_name)
    assert(status == 0)
    l_chunk_num = l_chunk_num + 1
    return ylen, wbuf, nil
  end
  return lVector( {gen = gen, has_nulls = false, qtype = subs.qtype} )
end
return expander_ifxthenyelsez
