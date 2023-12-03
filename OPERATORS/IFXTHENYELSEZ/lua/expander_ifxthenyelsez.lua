local qc      = require 'Q/UTILS/lua/qcore'
local ffi     = require 'ffi'
local cmem    = require 'libcmem'
local cutils  = require 'libcutils'
local Scalar  = require 'libsclr'
local lVector = require 'Q/RUNTIME/VCTRS/lua/lVector'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'

local function expander_ifxthenyelsez(x, y, z)
  local spfn = require("Q/OPERATORS/IFXTHENYELSEZ/lua/ifxthenyelsez_specialize" )
  assert(type(spfn) == "function")
  local status, subs = pcall(spfn, x, y, z)
  assert(status, subs)
  qc.q_add(subs)
  local func_name = subs.fn; assert(qc[func_name])

  local l_chunk_num = 0

  -- START Handle some scalar conversion issues
  local sclr_yval, sclr_zval, sclr_ymem, sclr_zmem
  if ( type(y) == "number" ) then 
    y = assert(Scalar.new(y, subs.wqtype))
    y:set_name("y_ifxthenyelsez")
  end
  if ( type(y) == "Scalar") then 
    sclr_ymem = y:to_cmem()
  end
  if ( type(z) == "number" ) then 
    z = assert(Scalar.new(z, subs.wqtype))
    z:set_name("z_ifxthenyelsez")
  end
  if ( type(z) == "Scalar") then 
    sclr_zmem = z:to_cmem()
  end
  -- STOP  Handle some scalar conversion issues

  local function gen(chunk_num)
    local cast_yptr, cast_zptr
    assert(chunk_num == l_chunk_num)
    local wbuf = cmem.new({ size = subs.wbufsz, qtype = subs.wqtype,
      name = 'ifxthenyelsez'})
    wbuf:stealable(true)
    local xlen, xptr = x:get_chunk(l_chunk_num) 
    if ( xlen == 0 )  then
      wbuf:delete()
      if ( sclr_ymem ) then sclr_ymem:delete() end 
      if ( sclr_zmem ) then sclr_zmem:delete() end 
      return 0
    end
    if ( subs.variation == "vv" ) then 
      local ylen, yptr = y:get_chunk(l_chunk_num) 
      local zlen, zptr = z:get_chunk(l_chunk_num) 
      assert(xlen == ylen)
      assert(xlen == zlen)
      cast_yptr = ffi.cast(subs.cast_y_as, get_ptr(yptr))
      cast_zptr = ffi.cast(subs.cast_z_as, get_ptr(zptr))
    elseif ( subs.variation == "vs" ) then 
      local ylen, yptr = y:get_chunk(l_chunk_num) 
      assert(ylen == xlen)
      cast_yptr = ffi.cast(subs.cast_y_as, get_ptr(yptr))

      cast_zptr = get_ptr(sclr_zmem, subs.wqtype)
    elseif ( subs.variation == "sv" ) then 
      if ( type(y) == "number" ) then 
        y = assert(Scalar.new(y, z:qtype()))
        y:set_name("y_ifxthenyelsez")
      end
      cast_yptr = get_ptr(sclr_ymem, subs.wqtype)

      local zlen, zptr = z:get_chunk(l_chunk_num) 
      assert(zlen == xlen)
      cast_zptr = ffi.cast(subs.cast_z_as, get_ptr(zptr))
    elseif ( subs.variation == "ss" ) then 
      if ( type(y) == "number" ) then 
        y = assert(Scalar.new(y, subs.wqtype))
        y:set_name("y_ifxthenyelsez")
      end
      cast_yptr = get_ptr(sclr_ymem, subs.wqtype)

      if ( type(z) == "number" ) then 
        z = assert(Scalar.new(z, subs.wqtype))
        z:set_name("z_ifxthenyelsez")
      end
      cast_zptr = get_ptr(sclr_zmem, subs.wqtype)
    else
      error("bad variation in ifxthenyelsez")
    end
    --=============================================
    local cast_xptr = ffi.cast(subs.cast_x_as, get_ptr(xptr))
    local cast_wbuf = ffi.cast(subs.cast_w_as, get_ptr(wbuf))    
    --=============================================
    local start_time = cutils.rdtsc()
    local status = qc[func_name](cast_xptr, cast_yptr, cast_zptr, 
      cast_wbuf, xlen)
    record_time(start_time, func_name)
    assert(status == 0)
    -- START release resources acquired 
    x:unget_chunk(l_chunk_num) 
    if ( subs.variation == "vv" ) then 
      y:unget_chunk(l_chunk_num) 
      z:unget_chunk(l_chunk_num) 
    elseif ( subs.variation == "vs" ) then 
      y:unget_chunk(l_chunk_num) 
    elseif ( subs.variation == "sv" ) then 
      z:unget_chunk(l_chunk_num) 
    end
    -- STOP  release resources acquired 
    l_chunk_num = l_chunk_num + 1
    if ( xlen < subs.max_num_in_chunk ) then -- no more calls to gen()
      if ( sclr_ymem ) then sclr_ymem:delete() end 
      if ( sclr_zmem ) then sclr_zmem:delete() end 
    end 
    return xlen, wbuf
  end
  local vargs = {gen = gen, has_nulls = false, 
    max_num_in_chunk = subs.max_num_in_chunk, qtype = subs.wqtype}
  return lVector(vargs)
end
return expander_ifxthenyelsez
