return function (x, out_qtype)
  local qconsts = require 'Q/UTILS/lua/q_consts'
  local qc = require 'Q/UTILS/lua/q_core'
  local ffi = require 'Q/UTILS/lua/q_ffi'

  assert(type(out_qtype) == "string")
  local out_ctype = assert(qconsts.qtypes[out_qtype].ctype)
  assert(x)
  local y = ffi.cast(out_ctype .. " *", x)
  return y[0]
end
