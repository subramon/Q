-- local dbg = require 'Q/UTILS/lua/debugger'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local lVector  = require 'Q/RUNTIME/lua/lVector'
local qconsts = require 'Q/UTILS/lua/q_consts'
local qc      = require 'Q/UTILS/lua/q_core'
local cmem    = require 'libcmem'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'

-- This is matrix vector multiply, done chunks at a time 
local mv_mul = function(X, y, optargs)
  local sp_fn_name = "Q/OPERATORS/MM/lua/mv_mul_specialize"
  local spfn = assert(require(sp_fn_name))
  local status, subs, tmpl = pcall(spfn, X, y, optargs)
  if not status then print(subs) end
  assert(status, "Error in specializer " .. sp_fn_name)
  local func_name = assert(subs.fn)

  -- START: Dynamic compilation
  if ( not qc[func_name] ) then
    print("Dynamic compilation kicking in... ")
    qc.q_add(subs, tmpl, func_name)
  end
  -- STOP: Dynamic compilation

  assert(qc[func_name], "Symbol not available" .. func_name)
  local m = 0 -- number of columns of X
  for k, v in ipairs(X) do
    m = m + 1
  end
  assert(m == #X)
 
  -- run time checks not made in compile time specializer
  y:eval() -- y must be fully evaluated

  -- for closure
  local chunk_idx = 0

  local z_buf     = nil 
  local z_buf = nil
  local cst_z_buf = nil
  local z_qtype   = subs.z_qtype
  local z_ctype   = subs.z_ctype
  local z_width   = qconsts.qtypes[z_qtype].width 
  local z_sz      = z_width * qconsts.chunk_size
  local Xptr      -- pointers to chunks of X
  local first_call = true
  local y_len, yptr, nn_yptr, cst_y_buf
  
  local y_qtype = subs.y_qtype
  local y_ctype = subs.y_ctype

  local x_qtype   = subs.x_qtype
  local x_ctype   = subs.x_ctype
  local gen_fn = function(chunk_num)
    -- Adding assert on chunk_idx to have sync between expected 
    -- chunk_num and generator's chunk_idx state
    assert(chunk_num == chunk_idx)
    if  ( first_call ) then 
      -- START: malloc
      --[[
      Xptr = get_ptr(cmem.new(ffi.sizeof(x_ctype .. " *") * m))
      Xptr = ffi.cast(x_ctype .. "**", Xptr)
      --]]

      -- TODO P2: Why does using CMEM cause segfault?
      -- TODO P1: Use 
      Xptr = ffi.C.malloc(ffi.sizeof(x_ctype .. "*") * m)
      -- Xptr = ffi.gc(ffi.C.malloc(ffi.sizeof(x_ctype .. "*") * m), ffi.C.free)
      Xptr = ffi.cast(x_ctype .. " **", Xptr)

      z_buf = assert(cmem.new(z_sz, z_qtype))
      cst_z_buf = ffi.cast(z_ctype .. " *", get_ptr(z_buf))

      -- STOP : malloc

      --all of y needs to be evaluated
      y_len, yptr, nn_yptr = y:get_all()
      assert(nn_yptr == nil, "Don't support null values")
      assert(yptr)
      assert(y_len == m, "Y must have same length as num cols of X")
      cst_y_buf = ffi.cast(y_ctype .. " *", get_ptr(yptr))

      first_call = false
    end
    -- START: assemble Xptr
    local n = 0 -- number of elements in each vector of X
    for xidx = 1, m do
      local x_len, xptr, nn_xptr = X[xidx]:chunk(chunk_idx) 
      if ( x_len == 0 ) then break end 
      assert(nn_xptr == nil, "Don't support null values")
      if ( n == 0 ) then 
        n = x_len
      else 
        assert(n == x_len)
      end
      Xptr[xidx-1] = ffi.cast(x_ctype .. " *", get_ptr(xptr))
    end
    -- STOP : assemble Xptr
    chunk_idx = chunk_idx + 1
    --=================================
    if ( n > 0 ) then 
      -- mv_mul_simple_F4_F4_F4( float ** x, float * y, float * z, int m, int k);
      local start_time = qc.RDTSC()
      local status = qc[func_name](Xptr, cst_y_buf, cst_z_buf, n, m);
      record_time(start_time, func_name)
      assert(status == 0, "C error in ", func_name)
      return n, z_buf, nil
    else
      return 0, nil, nil
    end
  end
  return lVector( {gen = gen_fn, has_nulls = false, qtype = z_qtype} )
end
return require('Q/q_export').export('mv_mul', mv_mul)
