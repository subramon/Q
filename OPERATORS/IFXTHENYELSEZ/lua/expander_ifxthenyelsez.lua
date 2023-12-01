local qc      = require 'Q/UTILS/lua/qcore'
local ffi     = require 'ffi'
local cutils  = require 'libcutils'
local lVector = require 'Q/RUNTIME/VCTRS/lua/lVector'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'

local function expander_ifxthenyelsez(x, y, z)
  assert(type(x) == "lVector")
  assert(type(y) == "lVector")
  assert(type(z) == "lVector")
  local spfn = require("Q/OPERATORS/IFXTHENYELSEZ/lua/ifxthenyelsez_specialize" )
  assert(type(spfn) == "function")
  local status, subs = pcall(spfn, x, y, z)
  assert(status, subs)
  qc.q_add(subs)

  -- allocate buffer for output
  local chunk_size = cVector.chunk_size() 
  local wbufsz = chunk_size * ffi.sizeof(subs.ctype)
  local wbuf = cmem.new(0)
  local l_chunk_num = 0
  local cast_x_as = qconsts.qtypes[x:fldtype()].ctype .. "*"
  local cast_y_as = qconsts.qtypes[y:fldtype()].ctype .. "*"
  local cast_z_as = qconsts.qtypes[z:fldtype()].ctype .. "*"
  local cast_w_as = qconsts.qtypes[subs.qtype].ctype .. "*"
  --
  local function gen(chunk_num)
    local cast_xptr, cast_yptr, cast_zptr, cast_wbuf
    assert(chunk_num == l_chunk_num)
    if ( not wbuf:is_data() ) then
      wbuf = cmem.new({ size = wbufsz, qtype = subs.ctype})
      wbuf:is_stealable(true)
    end
    local xlen, xptr = x:chunk(l_chunk_num) 
    if ( xlen == 0 )  then
      return 0, nil, nil
    end
    if ( variation == "vv" ) then 
      local ylen, yptr = y:chunk(l_chunk_num) 
      local zlen, zptr = z:chunk(l_chunk_num) 
      assert(xlen == ylen)
      assert(xlen == zlen)
      cast_yptr = ffi.cast(cast_y_as, get_ptr(yptr))
      cast_zptr = ffi.cast(cast_z_as, get_ptr(zptr))
    elseif ( variation == "vs" ) then 
      local ylen, yptr = y:chunk(l_chunk_num) 
      assert(xlen == ylen)
      cast_yptr = ffi.cast(cast_y_as, get_ptr(yptr))
      cast_zptr = XXXXXX
    elseif ( variation == "sv" ) then 
      cast_yptr = XXXXXX
      local zlen, zptr = y:chunk(l_chunk_num) 
      assert(xlen == zlen)
      cast_zptr = ffi.cast(cast_z_as, get_ptr(zptr))
    elseif ( variation = "ss" ) then 
      cast_yptr = XXXXXX
      cast_zptr = XXXXXX
    else
      error("")
    end
    --=============================================
    cast_xptr = ffi.cast(cast_x_as, get_ptr(xptr))
    cast_wbuf = ffi.cast(cast_w_as, get_ptr(wbuf))    
    --=============================================
    local start_time = qc.RDTSC()
    local status = qc[func_name](cast_xptr, cast_yptr, cast_zptr, cast_wbuf, ylen)
    record_time(start_time, func_name)
    assert(status == 0)
    l_chunk_num = l_chunk_num + 1
    return ylen, wbuf, nil
  end
  return lVector( {gen = gen, has_nulls = false, qtype = subs.qtype} )
end
return expander_ifxthenyelsez
