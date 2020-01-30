local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi       = require 'ffi'
local cmem      = require 'libcmem'
local Scalar    = require 'libsclr'
local cVector   = require 'libvctr'
local to_scalar = require 'Q/UTILS/lua/to_scalar'
local is_in     = require 'Q/UTILS/lua/is_in'
local get_ptr   = require 'Q/UTILS/lua/get_ptr'
local qconsts   = require 'Q/UTILS/lua/q_consts'
local tmpl      = qconsts.Q_SRC_ROOT .. "/OPERATORS/F_TO_S/lua/minmax.tmpl"

return function (qtype, operator)
  assert(is_in(qtype, { "I1", "I2", "I4", "I8", "F4", "F8"}))
  --====================
  local subs = {}
  subs.fn = operator ..  "_" .. qtype 
  subs.in_ctype = qconsts.qtypes[qtype].ctype
  if ( operator == "min" ) then 
    subs.comparator     = " < "
    subs.alt_comparator = " <= "
  elseif ( operator == "max" ) then 
    subs.comparator     = " > "
    subs.alt_comparator = " >= "
  else
    error(operator)
  end
  subs.tmpl       = tmpl
  --=====================================
  -- set up args for C code
  subs.args_ctype = "MINMAX_" .. qtype .. "_ARGS";
  local args = cmem.new({size = ffi.sizeof(subs.args_ctype)})
  args:zero()
  subs.args = ffi.cast(subs.args_ctype .. " *", get_ptr(args))
  --==========
  return subs
end
