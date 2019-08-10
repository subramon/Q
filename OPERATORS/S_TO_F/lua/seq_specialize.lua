local Scalar = require 'libsclr'
local to_scalar = require 'Q/UTILS/lua/to_scalar'
local is_base_qtype = assert(require 'Q/UTILS/lua/is_base_qtype')
local qconsts = require "Q/UTILS/lua/q_consts"
local tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/S_TO_F/lua/seq.tmpl"

return function (
  args
  )
  --====================================
  assert(type(args) == "table")
  local start = assert(args.start)
  local qtype = assert(args.qtype)
  local len   = assert(args.len)
  local by    = args.by
  local ctype = assert(qconsts.qtypes[qtype].ctype)

  assert(is_base_qtype(qtype))
  if not by then by = 1 end
  by = assert(to_scalar(by, qtype))
  start = assert(to_scalar(start, qtype))
  if ( type(len) == "Scalar" ) then len = len:to_num() end
  assert(type(len) == "number")
  assert(len > 0, "vector length must be positive")

  local subs = {};
  --========================
  subs.by	    = by
  subs.start	    = start
  subs.len	    = len
  subs.out_qtype    = qtype
  subs.out_ctype    = qconsts.qtypes[qtype].ctype
  subs.fn	    = "seq_" .. qtype
  subs.tmpl         = tmpl
  return subs
end
