local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local Scalar  = require 'libsclr'
local cmem    = require 'libcmem'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
return function (
  x_qtype,
  y_qtype
  )
  local hdr = [[
  typedef struct _dotp_<<qtype>>_args {
    <<ctype>> val;
    uint64_t num; // number of non-null elements inspected
  } DOTP_<<qtype>>_ARGS;
  ]]
  local tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/F1F2_TO_S/lua/dotp.tmpl"
  if ( ( ( x_qtype == "F4" ) or ( x_qtype == "F8" ) ) and 
       ( ( y_qtype == "F4" ) or ( y_qtype == "F8" ) ) and 
         ( x_qtype == y_qtype) ) then
         -- all is well
  else
    return "ok_to_fail"
  end

  subs.qtype = x_qtype
  subs.ctype = qconsts.qtypes[subs.qtype].ctype
  subs.args_type = "DOTP_" .. qtype .. "_ARGS *"
  -- Set c_mem 
  --TODO: is it required to introduce mem_initialize?
  hdr = string.gsub(hdr,"<<qtype>>", qtype)
  hdr = string.gsub(hdr,"<<ctype>>",  subs.ctype)
  pcall(ffi.cdef, hdr)
  local arg_sz = ffi.sizeof("DOTP_" .. qtype .. "_ARGS")
  local args = assert(cmem.new(arg_sz), "malloc failed")
  local cst_args = ffi.cast(subs.args_type, get_ptr(args))
  cst_args[0].val  = 0
  cst_args[0].num = 0
  subs.args = args
  --==============================
  subs.getter = function (x)
    return Scalar.new(cst_args[0].val, subs.qtype), 
         Scalar.new(tonumber(cst_args[0].num), "I8")
  end
  --==============================
  return subs, tmpl
end
