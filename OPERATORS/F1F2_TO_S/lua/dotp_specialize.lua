local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi = require 'ffi'
local Scalar  = require 'libsclr'
local cmem    = require 'libcmem'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local rev_lkp = require 'Q/UTILS/lua/rev_lkp'
local good_qtypes = { "F4", "F8" }
return function (
  xtype,
  ytype
  )
  local subs = {}
  if (not good_qtypes[xtype]) then return subs end 
  if (not good_qtypes[ytype]) then return subs end 
  subs.useful = true
  subs.tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/F1F2_TO_S/lua/dotp.tmpl"

  subs.qtype = xtype
  subs.ctype = qconsts.qtypes[subs.qtype].ctype
  subs.args_ctype = "DOTP_F_ARGS"
  local args = assert(cmem.new(ffi.sizeof(args_ctype)))
  args:zero()
  subs.args = ffi.cast(subs.args_ctype .. " *", args)
  --==============================
  subs.getter = function (x)
    return Scalar.new(cst_args[0].val, subs.qtype), 
         Scalar.new(tonumber(cst_args[0].num), "I8")
  end
  --==============================
  return subs, tmpl
end
