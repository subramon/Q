local to_scalar = require 'Q/UTILS/lua/to_scalar'
local is_base_qtype = assert(require 'Q/UTILS/lua/is_base_qtype')

return function (
  args
  )
  local qconsts = require 'Q/UTILS/lua/q_consts'
  --=================================

  local tmpl
  local subs = {}
  local status
  assert(type(args) == "table")
  local qtype = assert(args.qtype)
  if ( qtype == "B1" ) then
    local spfn = require 'Q/OPERATORS/S_TO_F/lua/rand_specialize_B1'
    status, subs, tmpl = pcall(spfn, args)
    if ( not status ) then 
      print(subs) 
      return 
    else 
      return subs, tmpl
    end
  end

  local lb	= assert(args.lb)
  local ub	= assert(args.ub)
  local len	= assert(args.len)
  local seed	= args.seed
  local ctype	= qconsts.qtypes[qtype].ctype

  if ( seed ) then 
    assert(type(seed) == "number")
  else
    seed = 0 
  end
  assert(is_base_qtype(qtype))
  assert(type(len) == "number")
  assert(len > 0, "vector length must be positive")
  lb = assert(to_scalar(lb, qtype))
  ub = assert(to_scalar(ub, qtype))
  assert(ub > lb, "upper bound should be strictly greater than lower bound")
  assert(type(len) == "number")
  assert(len > 0)

  subs.seed = seed
  subs.lb = lb
  subs.ub = ub
  --==============================
  if ( qconsts.iorf[qtype] == "fixed" ) then 
    subs.conv_fn = "floor"
    subs.identity_fn = " /* no identitu function needed */ "
  elseif ( qconsts.iorf[qtype] == "floating_point" ) then 
    subs.conv_fn = "identity"
    subs.identity_fn = " static double identity(double x) { return x; }"
  else
    assert(nil, "Unknown type " .. qtype)
  end
  --=========================
  tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/S_TO_F/lua/rand.tmpl"
  subs.fn = "rand_" .. qtype
  subs.out_ctype = qconsts.qtypes[qtype].ctype
  subs.len = len
  subs.out_qtype = qtype
  return subs, tmpl
end
