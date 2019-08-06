local ffi = require 'ffi'
local lVector = require 'Q/RUNTIME/lua/lVector'
local qconsts = require 'Q/UTILS/lua/q_consts'
local qc      = require "Q/UTILS/lua/q_core"


local approx_quantile = function(x, args)
  assert(type(x) == "lVector")
  local qtype = x:fldtype()
  local func_name = "approx_quantile_" .. qtype 

  local sp_fn = assert(require("Q/OPERATORS/APPROX/QUANTILE/lua/aq_specialize"))

  local status, subs, tmpl = pcall(sp_fn, x:fldtype())

  -- START: Dynamic compilation
  if ( not qc[func_name] ) then
    print("Dynamic compilation kicking in... ")
    -- TODO : here tmpl is table of operator tmpls
    qc.q_add(subs, tmpl, func_name)
  end
  -- STOP : Dynamic compilation

  -- START: verify inputs
  -- Check the vector x for eval(), if not then call eval()
  if not x:is_eov() then
    x:eval()
  end
  local size = x:length()
  local is_base_qtype = assert(require 'Q/UTILS/lua/is_base_qtype')
  assert(is_base_qtype(qtype))
  assert(type(size) == "number")
  assert( size > 0, "vector length must be positive")
  
  assert(type(args) == "table")
  local num_quantiles = assert(args.num_quantiles, "num quantiles is a required argument")
  num_quantiles = assert(tonumber(num_quantiles), "num quantiles must be a number")
  assert(num_quantiles > 1, "num quantiles must be positive and greater than 1")
  assert( num_quantiles < size, "cannot have more quantiles than numbers")
  
  local err = args.err
  if ( err == nil ) then
    err = 0.01
  else 
    err = assert(tonumber(err), "error rate must be a number")
    assert( err >= 0 and err <= 1, "error must be a decimal")
  end
  
  local cfld = args.where
  if ( cfld ) then 
    assert(type(cfld) == "lVector")
    assert(cfld:fldtype() == "B1")
    assert(nil, "TODO NOT IMPLEMENTED") -- TODO FIX THIS
  end
  -- STOP: verify inputs
  
  local ptr_est_is_good = assert(ffi.malloc(ffi.sizeof("int")), "malloc failed")
  ptr_est_is_good = ffi.cast("int *", ptr_est_is_good)

  local ctype = qconsts.qtypes[qtype].ctype
  local qptr = assert(ffi.malloc(num_quantiles*ffi.sizeof(ctype)), "malloc failed")
  
  local x_len, xptr, nn_xptr = x:get_all()
  assert(nn_xptr == nil, "Not set up for null values")

  local status
  status = qc[func_name](xptr, cfld, size, num_quantiles, err, qptr, ptr_est_is_good)
--[[approx_quantile(
		ctype * x,
		char * cfld,
		uint64_t siz, 
		uint64_t num_quantiles, TODO uint32_t ???
		double eps,
		ctype *y,
		int *ptr_estimate_is_good)
                --]]
  assert(status == 0, "Failure in C code of " .. func_name)
  local is_estimate_good = ptr_est_is_good[0]
  assert( ( is_estimate_good == 1 ) or 
          ( is_estimate_good == -1 ) or 
          ( is_estimate_good == -2 ) )
  
  local qcol = lVector({qtype = qtype, gen = true, has_nulls = false})
  qcol:put_chunk(qptr, nil, num_quantiles)
  qcol:eov()
  return qcol, is_estimate_good

end

return require('Q/q_export').export('approx_quantile', approx_quantile)
