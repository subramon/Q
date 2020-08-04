local do_subs = require 'Q/UTILS/lua/do_subs'
local tmpl = "f1f2opf3_specialize.tmpl"
local a_chk_f1f2 = [[
assert(is_basetype[f1_qtype]); assert(is_basetype[f2_qtype]); 
]]
local b_chk_f1f2 = [[
assert(is_inttype[f1_qtype]); assert(is_inttype[f2_qtype]); 
]]

local set_f3_qtype_3 = [[
local f3_qtype 
  local sz1 = qconsts.qtypes[f1_qtype].width
  local sz2 = qconsts.qtypes[f2_qtype].width
  if ( sz1 < sz2 ) then 
    f3_qtype = f1_qtype
  else
    f3_qtype = f2_qtype
  end
  if ( optargs ) then
    assert(type(optargs) == "table")
    f3_qtype = optargs.f3_qtype or f3_qtype
  end
  assert(is_inttype[f3_qtype])
  ]]
local set_f3_qtype_1 = [[
local f3_qtype = "I1" 
  ]]
local set_f3_qtype_2 = [[
local f3_qtype = promote(f1_qtype, f2_qtype)
  if ( optargs ) then
    assert(type(optargs) == "table")
    f3_qtype = optargs.f3_qtype or f3_qtype
  end
  assert(is_basetype[f3_qtype])
  ]]

  do_subs(tmpl, "vveq_specialize.lua",
    { __operator__ =  "vveq", __mathsymbol__ = "==", 
    __set_f3_qtype__ = set_f3_qtype_1, __chk_f1f2__ = a_chk_f1f2})
  do_subs(tmpl, "vvneq_specialize.lua",
    { __operator__ =  "vvneq", __mathsymbol__ = "!=",
    __set_f3_qtype__ = set_f3_qtype_1, __chk_f1f2__ = a_chk_f1f2})
  do_subs(tmpl, "vvleq_specialize.lua",
    { __operator__ =  "vvleq", __mathsymbol__ = "<=",
    __set_f3_qtype__ = set_f3_qtype_1, __chk_f1f2__ = a_chk_f1f2})
  do_subs(tmpl, "vvgeq_specialize.lua",
    { __operator__ =  "vvgeq", __mathsymbol__ = ">=",
    __set_f3_qtype__ = set_f3_qtype_1, __chk_f1f2__ = a_chk_f1f2})
  do_subs(tmpl, "vvlt_specialize.lua",
    { __operator__ =  "vvlt",  __mathsymbol__ = "<",
    __set_f3_qtype__ = set_f3_qtype_1, __chk_f1f2__ = a_chk_f1f2})
  do_subs(tmpl, "vvgt_specialize.lua",
    { __operator__ =  "vvgt",  __mathsymbol__ = ">",
    __set_f3_qtype__ = set_f3_qtype_1, __chk_f1f2__ = a_chk_f1f2})
--=======================

  do_subs(tmpl, "vvadd_specialize.lua",
    { __operator__ = "vvadd", __mathsymbol__ = "+",
      __set_f3_qtype__ = set_f3_qtype_2, __chk_f1f2__ = a_chk_f1f2})
  do_subs(tmpl, "vvsub_specialize.lua",
    { __operator__ = "vvsub", __mathsymbol__ = "-",
      __set_f3_qtype__ = set_f3_qtype_2, __chk_f1f2__ = a_chk_f1f2})
  do_subs(tmpl, "vvmul_specialize.lua",
    { __operator__ = "vvmul", __mathsymbol__ = "*",
      __set_f3_qtype__ = set_f3_qtype_2, __chk_f1f2__ = a_chk_f1f2})
  do_subs(tmpl, "vvdiv_specialize.lua",
    { __operator__ = "vvdiv", __mathsymbol__ = "/",
      __set_f3_qtype__ = set_f3_qtype_2, __chk_f1f2__ = a_chk_f1f2})
--=======================
  do_subs(tmpl, "vvrem_specialize.lua",
    { __operator__ = "vvrem", __mathsymbol__ = " % ",
      __set_f3_qtype__ = set_f3_qtype_3, __chk_f1f2__ = b_chk_f1f2})
--=======================
  do_subs(tmpl, "vvand_specialize.lua",
    { __operator__ = "vvand", __mathsymbol__ = " & ",
      __set_f3_qtype__ = set_f3_qtype_3, __chk_f1f2__ = b_chk_f1f2})
  do_subs(tmpl, "vvor_specialize.lua",
    { __operator__ = "vvor", __mathsymbol__ = " | ",
      __set_f3_qtype__ = set_f3_qtype_3, __chk_f1f2__ = b_chk_f1f2})
  do_subs(tmpl, "vvxor_specialize.lua",
    { __operator__ = "vvxor", __mathsymbol__ = " & ",
      __set_f3_qtype__ = set_f3_qtype_3, __chk_f1f2__ = b_chk_f1f2})
  do_subs(tmpl, "vvandnot_specialize.lua",
    { __operator__ = "vvandnot", __mathsymbol__ = " & ~ ",
      __set_f3_qtype__ = set_f3_qtype_3, __chk_f1f2__ = b_chk_f1f2})

print("ALL DONE")
