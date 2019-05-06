local qconsts = require 'Q/UTILS/lua/q_consts'
local to_scalar = require 'Q/UTILS/lua/to_scalar'

return function (
  args
  )
  local is_base_qtype = assert(require 'Q/UTILS/lua/is_base_qtype')
  --============================
  assert(type(args) == "table")
  local start = assert(args.start)
  local period = assert(args.period)
  local qtype = assert(args.qtype)
  local len   = assert(args.len)
  local by    = args.by
  if ( not by ) then by = 1 end
  assert(is_base_qtype(qtype))
  assert(type(len) == "number")
  assert(len > 0, "vector length must be positive")

  local out_ctype = qconsts.qtypes[qtype].ctype
  start   = assert(to_scalar(start, qtype))
  by	  = assert(to_scalar(by, qtype))
  period  = assert(to_scalar(period, qtype))
  assert(period:to_num() > 1, "length of period must be > 1")

  local tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/S_TO_F/lua/period.tmpl"
  local subs = {};
  subs.fn          = "period_" .. qtype
  subs.out_ctype   = out_ctype
  subs.len         = len
  subs.out_qtype   = qtype
  subs.start       = start
  subs.by          = by
  subs.period      = period

  return subs, tmpl
end
