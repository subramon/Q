
local is_base_qtype  = require 'Q/UTILS/lua/is_base_qtype'
return function (
  src_val_qtype, -- 
  dst_val_qtype, -- 
  optargs
  )
  local to_scalar = require 'Q/UTILS/lua/to_scalar'
  local qconsts = require 'Q/UTILS/lua/q_consts'

  assert(optargs)
  assert(type(optargs) == "table")
  local nR2 = assert(optargs.nR2)
  assert(type(nR2) == "number")
  assert(nR2 > 0)
  assert(is_base_qtype(src_val_qtype))
  assert(is_base_qtype(dst_val_qtype))
  -- following assert is stricter than it needs to be
  assert(src_val_qtype == dst_val_qtype)

  -- out_qtype is an integer field that is no bigger than it needs to be
  -- unless over-ridden by ask_out_qtype in optargs
  local out_qtype
  local ask_out_qtype = optargs.out_qtype
  if ( nR2 <= 127 ) then 
    out_qtype = "I1"
    if ( ( ask_out_qtype == "I2" ) or 
         ( ask_out_qtype == "I4" ) or 
         ( ask_out_qtype == "I8" ) ) then
      out_qtype = ask_out_qtype
    end
  elseif ( nR2 <= 32767 ) then 
    out_qtype = "I2"
    if ( ( ask_out_qtype == "I4" ) or ( ask_out_qtype == "I8" ) ) then
      out_qtype = ask_out_qtype
    end
  elseif ( nR2 <= 2147483647 ) then 
    out_qtype = "I4"
    if ( ask_out_qtype == "I8" ) then
      out_qtype = ask_out_qtype
    end
  else
    out_qtype = "I8"
  end

  local subs = {}
  local tmpl
  tmpl = 'get_idx_by_val.tmpl'
  subs.fn = "get_idx_" .. out_qtype .. "_by_val_" .. src_val_qtype 

  subs.in_qtype = src_val_qtype
  subs.in_ctype = qconsts.qtypes[src_val_qtype].ctype

  subs.out_qtype = out_qtype
  subs.out_ctype = qconsts.qtypes[out_qtype].ctype

  return subs, tmpl
end
