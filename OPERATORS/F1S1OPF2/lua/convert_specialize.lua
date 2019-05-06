local is_base_qtype = require 'Q/UTILS/lua/is_base_qtype'
local qconsts       = require 'Q/UTILS/lua/q_consts'

return function (
  in_qtype,
  out_qtype,
  optargs
  )
  assert( in_qtype ~= out_qtype, 
    "handled by expander before control comes here")
  local is_safe = false
  if ( optargs ) then 
    assert(type(optargs) == "table" )
    if ( optargs.is_safe ) then 
      assert(type(is_safe) == "boolean")
      is_safe = optargs.is_safe
    end
  end
  assert(in_qtype ~= out_qtype)
  assert(is_base_qtype(out_qtype) or ( out_qtype == "B1" ) )
  assert(is_base_qtype(in_qtype) or ( in_qtype == "B1" ) )
  local out_ctype = assert(qconsts.qtypes[out_qtype].ctype, out_qtype)
  local in_ctype  = assert(qconsts.qtypes[in_qtype].ctype, in_qtype)

  local out_min_val = assert(qconsts.qtypes[out_qtype].min)
  local out_max_val = assert(qconsts.qtypes[out_qtype].max)
  local tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/F1S1OPF2/lua/f1opf2.tmpl"
  local subs = {};
  local out_smaller_than_in = false
  if ( in_qtype == "F8" ) then
    if ( out_qtype == "F4" ) then
      out_smaller_than_in = true
    end
  elseif ( in_qtype == "I8" ) then
    if ( ( out_qtype == "I4" ) or ( out_qtype == "I2" ) or 
         ( out_qtype == "I1" ) ) then 
      out_smaller_than_in = true
    end
  elseif ( in_qtype == "I4" ) then
    if ( ( out_qtype == "I2" ) or ( out_qtype == "I1" ) ) then 
      out_smaller_than_in = true
    end
  elseif ( in_qtype == "I2" ) then
    if ( out_qtype == "I1" ) then 
      out_smaller_than_in = true
    end
  end

  subs.fn = "convert_" .. in_qtype .. "_" .. out_qtype
  subs.c_code_for_operator = "c = (" .. out_ctype .. ") a; "
  subs.in_qtype = in_qtype
  subs.out_qtype = out_qtype
  subs.in_ctype = in_ctype
  subs.out_ctype = out_ctype
  -- TODO We should not need to do this. Will delete when fixed in q_consts
  if ( in_qtype  == "B1" ) then subs.in_ctype = "uint64_t" end
  if ( out_qtype == "B1" ) then subs.out_ctype = "uint64_t" end
  
  if out_qtype == "B1" then
    tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/F1S1OPF2/lua/convert_to_B1.tmpl"
    subs.out_ctype = "uint64_t"
  elseif in_qtype == "B1" then 
    tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/F1S1OPF2/lua/convert_from_B1.tmpl"
    subs.in_ctype = "uint64_t"
  elseif is_safe then
    tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/F1S1OPF2/lua/safe_convert.tmpl"
    subs.fn = "safe_convert_" .. in_qtype .. "_" .. out_qtype
    subs.in_qtype = in_qtype
    subs.out_qtype = out_qtype
    if ( out_smaller_than_in ) then 
      local T = {}
      T[1] = " ( in[i] < " 
      T[2] = out_min_val
      T[3] = " ) || ( in[i] > "
      T[4] = out_max_val
      T[5] = " ) "
      subs.cond = table.concat(T)
    else
      subs.cond = " 0 "
    end
    subs.is_safe = is_safe
  else
    tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/F1S1OPF2/lua/convert.tmpl"
  end    
  return subs, tmpl
end
