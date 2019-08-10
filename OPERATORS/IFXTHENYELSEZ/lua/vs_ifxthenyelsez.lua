local function vs_ifxthenyelsez(x, y, z)
  local Q       = require 'Q/q_export'
  local qc      = require 'Q/UTILS/lua/q_core'
  local qconsts = require 'Q/UTILS/lua/q_consts'
  local ffi = require 'ffi'
  local lVector = require 'Q/RUNTIME/lua/lVector'
  local cmem    = require 'libcmem'
  local get_ptr = require 'Q/UTILS/lua/get_ptr'
  local record_time = require 'Q/UTILS/lua/record_time'

  assert(type(x) == "lVector", "error")
  assert(type(y) == "lVector", "error")
  assert(type(z) == "Scalar", "error")
  local spfn = require("Q/OPERATORS/IFXTHENYELSEZ/lua/ifxthenyelsez_specialize" )
  assert(type(spfn) == "function")
  assert(x:fldtype() == "B1")
  assert(y:fldtype() == z:fldtype())
  local status, subs, tmpl = pcall(spfn, "vs", y:fldtype())
  if ( not status ) then print(subs) end
  assert(status, "error in call to ifxthenyelsez_specialize")
  assert(type(subs) == "table", "error in call to ifxthenyelsez_specialize")
  local func_name = assert(subs.fn)

  -- START: Dynamic compilation
  if ( not qc[func_name] ) then
    print("Dynamic compilation kicking in... ")
    qc.q_add(subs, tmpl, func_name)
  end
  -- STOP: Dynamic compilation
  assert(qc[func_name], "Symbol not defined " .. func_name)

  -- allocate buffer for output
  local wbufsz = qconsts.chunk_size * ffi.sizeof(subs.ctype)
  local wbuf = nil
  local chunk_idx = 0
  --
  local function vs_ifxthenyelsez_gen(chunk_num)
    -- Adding assert on chunk_idx to have sync between expected chunk_num and generator's chunk_idx state
    assert(chunk_num == chunk_idx)
    wbuf = wbuf or cmem.new(wbufsz)
    local xlen, xptr, nn_xptr = x:chunk(chunk_idx) 
    local ylen, yptr, nn_yptr = y:chunk(chunk_idx) 
    if ( ylen == 0 )  then
      return 0, nil, nil
    end
    assert(nn_xptr == nil, "Not prepared for null values in x")
    assert(nn_yptr == nil, "Not prepared for null values in y")
    assert(xlen == ylen)
    local zptr = z:to_cmem()
    local casted_xptr = ffi.cast(qconsts.qtypes[x:fldtype()].ctype .. "*", get_ptr(xptr))
    local casted_yptr = ffi.cast(qconsts.qtypes[y:fldtype()].ctype .. "*", get_ptr(yptr))
    local casted_zptr = ffi.cast(qconsts.qtypes[z:fldtype()].ctype .. "*", get_ptr(zptr))
    local casted_wbuf = ffi.cast(qconsts.qtypes[y:fldtype()].ctype .. "*", get_ptr(wbuf))
    local start_time = qc.RDTSC()
    local status = qc[func_name](casted_xptr, casted_yptr, casted_zptr, casted_wbuf, ylen)
    record_time(start_time, func_name)
    assert(status == 0, "C error in ifxthenyelsez") 
    chunk_idx = chunk_idx + 1
    return ylen, wbuf, nil
  end
  return lVector( {gen=vs_ifxthenyelsez_gen, has_nulls=false, 
    qtype=subs.qtype} )
end
return vs_ifxthenyelsez
