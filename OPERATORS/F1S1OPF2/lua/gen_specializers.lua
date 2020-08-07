local do_subs = require 'Q/UTILS/lua/do_subs'
local tmpl = "f1s1opf2_specialize.tmpl"
local a_chk_f = [[
assert(is_basetype[f1_qtype]); assert(is_basetype[f2_qtype]); 
]]
local b_chk_f = [[
assert(is_inttype[f1_qtype]); assert(is_inttype[f2_qtype]); 
]]
--================
local a_set_f2_qtype = [[
local f2_qtype = f1_qytpe
]]
local b_set_f2_qtype = [[
local f2_qtype = "I1"
]]
--================
local a_set_f2_ctype = [[
local f2_ctype = qconsts.qtypes[f2_qtype].ctype
]]
local b_set_f2_ctype = [[
local f2_qtype = "u" .. qconsts.qtypes[f2_qtype].ctype
]]
--================
local a_set_s1_qtype = [[
assert(type(s1) == "Scalar")
  local s1_qtype = s1:qtype()
]]
local b_set_s1_qtype = ""

do_subs(tmpl, "vsadd_specialize.lua", 
{ __operator__ = "vsadd", __code__ = "c = a + b", 
  __chk_f__ = a_chk_f, __set_f2_qtype__ = a_set_f2_qtype,
  __set_s1_qtype__ = a_set_s1_qtype, __set_f2_ctype__ = a_set_f2_ctype})
do_subs(tmpl, "vssub_specialize.lua", 
{ __operator__ = "vssub", __code__ = "c = a - b", 
  __chk_f__ = a_chk_f, __set_f2_qtype__ = a_set_f2_qtype,
  __set_s1_qtype__ = a_set_s1_qtype, __set_f2_ctype__ = a_set_f2_ctype})
do_subs(tmpl, "vsmul_specialize.lua", 
{ __operator__ = "vsmul", __code__ = "c = a * b", 
  __chk_f__ = a_chk_f, __set_f2_qtype__ = a_set_f2_qtype,
  __set_s1_qtype__ = a_set_s1_qtype, __set_f2_ctype__ = a_set_f2_ctype})
do_subs(tmpl, "vsdiv_specialize.lua", 
{ __operator__ = "vsdiv", __code__ = "c = a / b", 
  __chk_f__ = a_chk_f, __set_f2_qtype__ = a_set_f2_qtype,
  __set_s1_qtype__ = a_set_s1_qtype, __set_f2_ctype__ = a_set_f2_ctype})
do_subs(tmpl, "vsrem_specialize.lua", 
{ __operator__ = "vsrem", __code__ = "c = a % b", 
  __chk_f__ = b_chk_f, __set_f2_qtype__ = a_set_f2_qtype,
  __set_s1_qtype__ = a_set_s1_qtype, __set_f2_ctype__ = a_set_f2_ctype})
--=======================
do_subs(tmpl, "vsand_specialize.lua", 
{ __operator__ = "vsand", __code__ = "c = a & b", 
  __chk_f__ = b_chk_f, __set_f2_qtype__ = a_set_f2_qtype,
  __set_s1_qtype__ = a_set_s1_qtype, __set_f2_ctype__ = a_set_f2_ctype})
do_subs(tmpl, "vsor_specialize.lua", 
{ __operator__ = "vsor", __code__ = "c = a | b", 
  __chk_f__ = b_chk_f, __set_f2_qtype__ = a_set_f2_qtype,
  __set_s1_qtype__ = a_set_s1_qtype, __set_f2_ctype__ = a_set_f2_ctype})
do_subs(tmpl, "vsxor_specialize.lua", 
{ __operator__ = "vsxor", __code__ = "c = a ^ b", 
  __chk_f__ = b_chk_f, __set_f2_qtype__ = a_set_f2_qtype,
  __set_s1_qtype__ = a_set_s1_qtype, __set_f2_ctype__ = a_set_f2_ctype})
--==============================
do_subs(tmpl, "vseq_specialize.lua", 
{ __operator__ = "vseq", __code__ = "c = a == b", 
  __chk_f__ = a_chk_f, __set_f2_qtype_ = b_set_f2_qtype,
  __set_s1_qtype__ = a_set_s1_qtype, __set_f2_ctype__ = a_set_f2_ctype})
do_subs(tmpl, "vsneq_specialize.lua", 
{ __operator__ = "vsneq", __code__ = "c = a != b", 
  __chk_f__ = a_chk_f, __set_f2_qtype__ = b_set_f2_qtype,
  __set_s1_qtype__ = a_set_s1_qtype, __set_f2_ctype__ = a_set_f2_ctype})
do_subs(tmpl, "vsgeq_specialize.lua", 
{ __operator__ = "vsgeq", __code__ = "c = a >= b", 
  __chk_f__ = a_chk_f, __set_f2_qtype__ = b_set_f2_qtype,
  __set_s1_qtype__ = a_set_s1_qtype, __set_f2_ctype__ = a_set_f2_ctype})
do_subs(tmpl, "vsleq_specialize.lua", 
{ __operator__ = "vsleq", __code__ = "c = a <= b", 
  __chk_f__ = a_chk_f, __set_f2_qtype__ = b_set_f2_qtype,
  __set_s1_qtype__ = a_set_s1_qtype, __set_f2_ctype__ = a_set_f2_ctype})
do_subs(tmpl, "vsgt_specialize.lua", 
{ __operator__ = "vsgt", __code__ = "c = a > b", 
  __chk_f__ = a_chk_f, __set_f2_qtype__ = b_set_f2_qtype,
  __set_s1_qtype__ = a_set_s1_qtype, __set_f2_ctype__ = a_set_f2_ctype})
do_subs(tmpl, "vslt_specialize.lua", 
{ __operator__ = "vslt", __code__ = "c = a < b", 
  __chk_f__ = a_chk_f, __set_f2_qtype__ = b_set_f2_qtype,
  __set_s1_qtype__ = a_set_s1_qtype, __set_f2_ctype__ = a_set_f2_ctype})
--=======================
do_subs(tmpl, "shift_left_specialize.lua", 
{ __operator__ = "shift_left", __code__ = "c = (uint64_t)a << (uint8_t)b", 
  __chk_f__ = a_chk_f, __set_f2_qtype__ = a_set_f2_qtype,
  __set_s1_qtype__ = a_set_s1_qtype, __set_f2_ctype__ = b_set_f2_ctype})
do_subs(tmpl, "shift_right_specialize.lua", 
{ __operator__ = "shift_right", __code__ = "c = (uint64_t)a >> (uint8_t)b", 
  __chk_f__ = a_chk_f, __set_f2_qtype__ = a_set_f2_qtype,
  __set_s1_qtype__ = a_set_s1_qtype, __set_f2_ctype__ = b_set_f2_ctype})
--=======================
do_subs(tmpl, "incr_specialize.lua", 
{ __operator__ = "incr", __code__ = "c = a++ ",
  __chk_f__ = a_chk_f, __set_f2_qtype__ = a_set_f2_qtype,
  __set_s1_qtype__ = b_set_s1_qtype, __set_f2_ctype__ = a_set_f2_ctype})
--=======================
--[[
y = string.gsub(x, "<<operator>>", "logit2")
y = string.gsub(y, "<<c_code_for_operator>>", 
" c = 1.0 / mcr_sqr ( ( 1.0 + exp(-1.0 *a) ) ); " )
y = string.gsub(y, "<<out_qtype>>", '"F8"')
plfile.write("logit2_specialize.lua", y)
--]]
--=======================
----]]
print("Generated specializers")
