-- matrix vector multiplication z := X \times y

local promote = require 'Q/UTILS/lua/promote'
local qconsts = require 'Q/UTILS/lua/q_consts'
return function (
  X,
  y,
  optargs
  )
  -- START: verify inputs
  assert(type(X) == "table", "X must be a table of lVectors")
  local m, x_qtype, y_qtype, z_qtype
  local ok_types = { F4 = true, F8 = true }

  --== Decide which C function to use 
  local mode = "simple"
  if ( optargs ) then 
    assert(type(optargs) == "table")
    if ( optargs.mode ) then
      assert((( optargs.mode == "opt" ) or ( optargs.mode == "simple" )))
      mode = optargs.mode
    end
  end
  --======================================
  for k, x in ipairs(X) do 
    assert(type(x) == "lVector", "each element of X must be a lVector")
    if ( not x_qtype ) then 
      x_qtype  = x:qtype()
    else
      assert(x_qtype == x:qtype())
    end
    assert(ok_types[x_qtype], "qtype not F4 or F8 for column " .. k)
  end
  --===========================
  assert(type(y) == "lVector", "Y must be a lVector ")
  local k = #X
  y_qtype = y:qtype()
  assert(ok_types[y_qtype], "qtype not F4 or F8 for goal")

  z_qtype = promote(x_qtype, y_qtype)
  if ( optargs ) then 
    assert(type(optargs) == "table")
    if ( optargs.z_qtype ) then
      assert((( optargs.z_qtype == "F4" ) or( optargs.z_qtype == "F8" )))
      z_qtype = optargs.z_qtype
    end
  end


  local subs = {}; 
  local tmpl
  if ( mode == "simple" ) then 
    tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/MM/lua/mv_mul_simple.tmpl"
    subs.fn = "mv_mul_simple_" .. x_qtype .. "_" .. y_qtype .. "_" .. z_qtype
  elseif ( mode == "opt" ) then 
    tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/MM/lua/mv_mul_opt.tmpl"
    subs.fn = "mv_mul_opt_" .. x_qtype .. "_" .. y_qtype .. "_" .. z_qtype
  else
    assert(nil)
  end
  subs.x_ctype = qconsts.qtypes[x_qtype].ctype
  subs.y_ctype = qconsts.qtypes[y_qtype].ctype
  subs.z_ctype = qconsts.qtypes[z_qtype].ctype

  subs.x_qtype = x_qtype
  subs.y_qtype = y_qtype
  subs.z_qtype = z_qtype
  return subs, tmpl
end
-- test
