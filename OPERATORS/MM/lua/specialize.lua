local qconsts = require 'Q/UTILS/lua/q_consts'
return function (
  operator,
  in1_qtype, 
  in2_qtype, 
  out_qtype
  )
    local plfile = require "pl.file"
    local ok_types = { F4 = true, F8 = true }

    assert(ok_types[in1_qtype], 
    "input type 1 " .. in1_qtype .. " not acceptable")
    assert(ok_types[in2_qtype], 
    "input type 2 " .. in2_qtype .. " not acceptable")
    if ( out_qtype ) then 
      assert(ok_types[out_qtype], 
      "output type " .. out_qtype .. " not acceptable")
    else
      out_qtype = "F8"
    end
    local tmpl = operator .. ".tmpl"
    local subs = {}
    subs.in1_qtype = in1_qtype
    subs.in1_ctype = qconsts.qtypes[in1_qtype].ctype
    subs.in2_qtype = in2_qtype
    subs.in2_ctype = qconsts.qtypes[in2_qtype].ctype
    subs.out_qtype = out_qtype
    subs.out_ctype = qconsts.qtypes[out_qtype].ctype
    subs.fn = operator .."_" .. in1_qtype .. "_" 
                           .. in2_qtype .. "_" 
                           .. out_qtype
    return subs, tmpl
end
