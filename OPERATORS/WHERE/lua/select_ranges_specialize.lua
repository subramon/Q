local Q       = require 'Q'
local ffi     = require 'ffi'
local is_in   = require 'Q/UTILS/lua/is_in'
local from_scalar   = require 'Q/UTILS/lua/from_scalar'
local cutils  = require 'libcutils'

local good_qtypes = { "I1", "I2", "I4", "I8", "UI1", "UI2", "UI4", "UI8",  }
return function (
  f1,
  lb,
  ub,
  optargs
  )
  local subs = {}
  if ( optargs ) then assert(type(optargs) == "table") end 
  --===========================================
  assert(type(f1) == "lVector")
  subs.max_num_in_chunk = f1:max_num_in_chunk()
  -- can override max num in chunk using optargs
  if ( optargs ) then 
    assert(type(optargs) == "table")
    if ( optargs.max_num_in_chunk ) then 
      print("WARNING!!!!! Untested")
      assert(type(optargs.max_num_in_chunk) == "number")
      assert(optargs.max_num_in_chunk > 0)
      assert( ( ( optargs.max_num_in_chunk / 64 ) * 64 ) == 
        optargs.max_num_in_chunk )
      subs.max_num_in_chunk = optargs.max_num_in_chunk 
    end 
  end 
  subs.in_qtype = f1:qtype()
  subs.has_nulls = f1:has_nulls() 
  if ( subs.has_nulls ) then 
    assert(subs.nn_qtype == "BL") -- TODO P4 support B1 
  end
  --=================================
  -- NOTE: Assumption is that the number of ranges is small 
  local lb_tbl = {}
  local ub_tbl = {}
  if ( type(lb) == "Scalar" ) then 
    assert(type(ub) == "Scalar" )
    lb_tbl = { from_scalar(lb) }
    ub_tbl = { from_scalar(ub) }
  elseif ( type(lb) == "number" ) then 
    assert(type(ub) == "number" )
    lb_tbl = { lb }
    ub_tbl = { ub }
  elseif ( type(lb) == "lVector" ) then 
    assert(type(ub) == "lVector" )

    assert(lb:is_eov())
    assert(ub:is_eov())

    assert(is_in(lb:qtype(), good_qtypes))
    assert(is_in(ub:qtype(), good_qtypes))

    assert(lb:num_elements() == ub:num_elements())
    assert(lb:num_elements() > 0)

    local xlb = Q.mk_tbl(lb) -- mk_tbl is inverse of mk_col
    for k, v in ipairs(xlb) do 
      lb_tbl[k] = from_scalar(v)
      assert(type(lb_tbl[k]) == "number")
      assert(lb_tbl[k] >= 0)
    end

    local xub  = Q.mk_tbl(ub)
    for k, v in ipairs(xub) do 
      ub_tbl[k] = from_scalar(v)
      assert(type(ub_tbl[k]) == "number")
      assert(ub_tbl[k] > lb_tbl[k])
    end
  else
    error("bad types for ranges")
  end
  subs.lb_tbl = lb_tbl
  subs.ub_tbl = ub_tbl
  --==== Now we convert lb_tbl/ub_tbl to a specification as follows
  -- For each output chunk to tbe created, we create a list of 
  -- (chunk, lb, ub). Note that if we sum (ub-lb) for a given output chunk
  -- we will get the size of that chunk. 
  -- The size of each output chunk == subs.max_num_in_chunk except
  -- for the last one which *may* be less than that 

  --=================================
  subs.in_ctype = cutils.str_qtype_to_str_ctype(subs.in_qtype)
  subs.out_qtype = subs.in_qtype
  subs.out_ctype = cutils.str_qtype_to_str_ctype(subs.out_qtype)

  subs.f1_cast_as = subs.in_ctype  .. "*" 
  subs.f2_cast_as = subs.out_ctype .. "*" 
  subs.width = cutils.get_width_qtype(subs.out_qtype)
  subs.bufsz = subs.max_num_in_chunk * subs.width
  return subs
end
