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
    local xptr, yptr, zptr, wptr 
    local nn_yptr = ffi.NULL 
    local nn_zptr = ffi.NULL
    local nn_wptr = ffi.NULL
    assert(chunk_num == l_chunk_num)
    local nn_wbuf
    local wbuf = cmem.new({ size = subs.wbufsz, qtype = subs.wqtype,
      name = 'ifxthenyelsez'})
    wbuf:stealable(true)
    if ( subs.has_nulls ) then 
      nn_wbuf = cmem.new({ size = subs.nn_wbufsz, qtype = subs.nn_wqtype,
        name = 'nn_ifxthenyelsez'})
      nn_wbuf:stealable(true)
    end
    local xlen, xchunk, nn_xchunk = x:get_chunk(l_chunk_num) 
    local xptr = ffi.cast(subs.cast_x_as, get_ptr(xchunk))
    assert(nn_xchunk == nil)

    if ( xlen == 0 ) then
      wbuf:delete()
      if ( sclr_ymem ) then sclr_ymem:delete() end 
      if ( sclr_zmem ) then sclr_zmem:delete() end 
      return 0
    end
    if ( subs.variation == "vv" ) then 
      local ylen, ychunk, nn_ychunk = y:get_chunk(l_chunk_num) 
      local zlen, zchunk, nn_zchunk = z:get_chunk(l_chunk_num) 
      assert(xlen == ylen)
      assert(xlen == zlen)
      yptr = ffi.cast(subs.cast_y_as, get_ptr(ychunk))
      zptr = ffi.cast(subs.cast_z_as, get_ptr(zchunk))
      if ( nn_ychunk ) then 
        nn_yptr = ffi.cast("bool *", get_ptr(nn_ychunk))
      end
      if ( nn_zchunk ) then 
        nn_zptr = ffi.cast("bool *", get_ptr(nn_zchunk))
      end
    elseif ( subs.variation == "vs" ) then 
      if ( type(z) == "number" ) then 
        z = assert(Scalar.new(z, y:qtype()))
        z:set_name("z_ifxthenyelsez")
      end
      zptr = get_ptr(sclr_zmem, subs.wqtype)

      local ylen, ychunk, nn_ychunk = y:get_chunk(l_chunk_num) 
      assert(ylen == xlen)
      yptr = ffi.cast(subs.cast_y_as, get_ptr(ychunk))
      if ( nn_ychunk ) then 
        nn_yptr = ffi.cast("bool *", get_ptr(nn_ychunk))
      end

    elseif ( subs.variation == "sv" ) then 
      if ( type(y) == "number" ) then 
        y = assert(Scalar.new(y, z:qtype()))
        y:set_name("y_ifxthenyelsez")
      end
      yptr = get_ptr(sclr_ymem, subs.wqtype)

      local zlen, zchunk, nn_zchunk = z:get_chunk(l_chunk_num) 
      assert(zlen == xlen)
      zptr = ffi.cast(subs.cast_z_as, get_ptr(zchunk))
      if ( nn_zchunk ) then 
        nn_zptr = ffi.cast("bool *", get_ptr(nn_zchunk))
      end
    elseif ( subs.variation == "ss" ) then 
      --[[
      if ( type(y) == "number" ) then 
        y = assert(Scalar.new(y, subs.wqtype))
        y:set_name("y_ifxthenyelsez")
      end
      --]]
      yptr = get_ptr(sclr_ymem, subs.wqtype)

      --[[
      if ( type(z) == "number" ) then 
        z = assert(Scalar.new(z, subs.wqtype))
        z:set_name("z_ifxthenyelsez")
      end
      ==]]
      zptr = get_ptr(sclr_zmem, subs.wqtype)
    else
      error("bad variation in ifxthenyelsez")
    end
    --=============================================
    local wptr = ffi.cast(subs.cast_w_as, get_ptr(wbuf))    
    if ( subs.has_nulls ) then 
      nn_wptr = ffi.cast(subs.cast_nn_w_as, get_ptr(nn_wbuf))    
    end
    --=============================================
    local start_time = cutils.rdtsc()
    local status = qc[func_name](xptr, yptr, nn_yptr, zptr, nn_zptr,
      wptr, nn_wptr, xlen)
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
