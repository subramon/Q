local qconsts = require 'Q/UTILS/lua/q_consts'
local tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/F1F2OPF3/lua/f1f2opf3.tmpl"
return function (
  in1_qtype, 
  in2_qtype, 
  optargs
  )
    local plfile = require "pl.file"
    local out_qtype 
    if ( optargs ) then
      assert(type(optargs) == "table")
      out_qtype = optargs.out_qtype -- okay for out_qtype to be nil
    end
    local ok_intypes = { I1 = true, I2 = true, I4 = true }
    local ok_out_qtypes = { I2 = true, I4 = true, I8 = true }

    assert(ok_intypes[in1_qtype], "input type " .. in1_qtype .. " not acceptable")
    assert(ok_intypes[in2_qtype], "input type " .. in2_qtype .. " not acceptable")

    local w1   = assert(qconsts.qtypes[in1_qtype].width)
    local w2   = assert(qconsts.qtypes[in2_qtype].width)

    local shift = w2 * 8 -- convert bytes to bits 
    local l_out_qtype = nil
    if ( in1_qtype == "I4" ) then 
      l_out_qtype = "I8"
    elseif( in1_qtype == "I2" ) then 
      if ( in2_qtype == "I4" ) then
        l_out_qtype = "I8"
      elseif( in2_qtype == "I2" ) then
        l_out_qtype = "I4"
      elseif( in2_qtype == "I1" ) then
        l_out_qtype = "I4"
      end
    elseif( in1_qtype == "I1" ) then 
      if ( in2_qtype == "I4" ) then
        l_out_qtype = "I8"
      elseif( in2_qtype == "I2" ) then
        l_out_qtype = "I4"
      elseif( in2_qtype == "I1" ) then
        l_out_qtype = "I2"
      end
    end
    assert(l_out_qtype, "Control should never come here")
    assert(ok_out_qtypes[l_out_qtype], "output type " .. 
    l_out_qtype .. " not acceptable")
    if ( out_qtype ) then 
      assert(ok_out_qtypes[out_qtype], "output type " ..
      out_qtype .. " not acceptable")
      local width_l_out_qtype = assert(qconsts.qtypes[l_out_qtype].width, "ERROR")
      local width_out_qtype   = assert(qconsts.qtypes[out_qtype].width, "ERROR")
      assert( width_out_qtype >= width_l_out_qtype,
      "specfiied outputtype not big enough")
      l_out_qtype = out_qtype
    end
    local subs = {}
    -- This includes is just as a demo. Not really needed
    subs.fn = 
    "concat_" .. in1_qtype .. "_" .. in2_qtype .. "_" .. l_out_qtype 
    subs.in1_ctype = "u" .. qconsts.qtypes[in1_qtype].ctype
    subs.in2_ctype = "u" .. qconsts.qtypes[in2_qtype].ctype
    subs.out_qtype = l_out_qtype
    subs.out_ctype = "u" .. qconsts.qtypes[l_out_qtype].ctype
    -- Note that we are movint int8_t to uint8_t below
    subs.c_code_for_operator = " c = ((" .. subs.out_ctype .. ")a << " .. shift .. " ) | b; "

    subs.tmpl = tmpl
    return subs
end
