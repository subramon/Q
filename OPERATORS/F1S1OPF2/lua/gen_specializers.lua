local do_subs = require 'Q/UTILS/lua/do_subs'
local tmpl = "f1s1opf2_specialize.tmpl"
-- check valid qtypes for f1 
local a_chk_f1_qtype = [[
assert(is_basetype[f1_qtype]); 
]]
local b_chk_f1_qtype = [[
assert(is_inttype[f1_qtype]); 
]]
local c_chk_f1_qtype = [[
assert(f1_qtype == "I1")
]]
local d_chk_f1_qtype = [[
assert( ( f1_qtype == "F4") or ( f1_qtype == "F8") )
]]
--================
-- set qtypes for f2
local a_set_f2_qtype = [[
f2_qtype = f1_qtype
]]
local b_set_f2_qtype = [[
f2_qtype = "I1"
]]
local c_set_f2_qtype = [[
if ( f1_qtype == "F4" ) then 
  f2_qtype = "F4" 
else
  f2_qtype = "F8" 
end
]]
--================
-- where ctype of f2 not directly from qtype of f2 
local a_set_f2_ctype = [[
local f2_ctype = qconsts.qtypes[f2_qtype].ctype
]]
local b_set_f2_ctype = [[
local f2_qtype = "u" .. qconsts.qtypes[f2_qtype].ctype
]]
--================
-- handle case where scalar provided; else, unary operator 
local a_set_s1_qtype = [[
assert(type(s1) == "Scalar")
  local s1_qtype = s1:qtype()
]]
local b_set_s1_qtype = ""
--================
-- checks on scalar if needed
local a_chk_s1 = " assert( ( s1 > 0 ) and ( s1 <= 32 ) ) "
local b_chk_s1 = ""

-- handle math operators +, -, *, /, % 
do_subs(tmpl, "vsadd_specialize.lua", 
{ __operator__ = "vsadd", 
  __code__ = "c = a + b", 
  __chk_f1_qtype__ = a_chk_f1_qtype, 
  __set_f2_qtype__ = a_set_f2_qtype,
  __set_s1_qtype__ = a_set_s1_qtype, 
  __chk_s1__ = b_chk_s1,
  __set_f2_ctype__ = a_set_f2_ctype})
do_subs(tmpl, "vssub_specialize.lua", 
{ __operator__ = "vssub", 
  __code__ = "c = a - b", 
  __chk_f1_qtype__ = a_chk_f1_qtype, 
  __set_f2_qtype__ = a_set_f2_qtype,
  __set_s1_qtype__ = a_set_s1_qtype, 
  __chk_s1__ = b_chk_s1,
  __set_f2_ctype__ = a_set_f2_ctype})
do_subs(tmpl, "vsmul_specialize.lua", 
{ __operator__ = "vsmul", 
  __code__ = "c = a * b", 
  __chk_f1_qtype__ = a_chk_f1_qtype, 
  __set_f2_qtype__ = a_set_f2_qtype,
  __set_s1_qtype__ = a_set_s1_qtype, 
  __chk_s1__ = b_chk_s1,
  __set_f2_ctype__ = a_set_f2_ctype})
do_subs(tmpl, "vsdiv_specialize.lua", 
{ __operator__ = "vsdiv", 
  __code__ = "c = a / b", 
  __chk_f1_qtype__ = a_chk_f1_qtype, 
  __set_f2_qtype__ = a_set_f2_qtype,
  __set_s1_qtype__ = a_set_s1_qtype, 
  __chk_s1__ = b_chk_s1,
  __set_f2_ctype__ = a_set_f2_ctype})
do_subs(tmpl, "vsrem_specialize.lua", 
{ __operator__ = "vsrem", 
  __code__ = "c = a % b", 
  __chk_f1_qtype__ = b_chk_f1_qtype, 
  __set_f2_qtype__ = a_set_f2_qtype,
  __set_s1_qtype__ = a_set_s1_qtype, 
  __chk_s1__ = b_chk_s1,
  __set_f2_ctype__ = a_set_f2_ctype})
--=======================
-- handle logical operators and, or, xor 
do_subs(tmpl, "vsand_specialize.lua", 
{ __operator__ = "vsand", 
  __code__ = "c = a & b", 
  __chk_f1_qtype__ = b_chk_f1_qtype, 
  __set_f2_qtype__ = a_set_f2_qtype,
  __set_s1_qtype__ = a_set_s1_qtype, 
  __chk_s1__ = b_chk_s1,
  __set_f2_ctype__ = a_set_f2_ctype})
do_subs(tmpl, "vsor_specialize.lua", 
{ __operator__ = "vsor", 
  __code__ = "c = a | b", 
  __chk_f1_qtype__ = b_chk_f1_qtype, 
  __set_f2_qtype__ = a_set_f2_qtype,
  __set_s1_qtype__ = a_set_s1_qtype, 
  __chk_s1__ = b_chk_s1,
  __set_f2_ctype__ = a_set_f2_ctype})
do_subs(tmpl, "vsxor_specialize.lua", 
{ __operator__ = "vsxor", 
  __code__ = "c = a ^ b", 
  __chk_f1_qtype__ = b_chk_f1_qtype, 
  __set_f2_qtype__ = a_set_f2_qtype,
  __set_s1_qtype__ = a_set_s1_qtype, 
  __chk_s1__ = b_chk_s1,
  __set_f2_ctype__ = a_set_f2_ctype})
--==============================
-- handle comparison operators ==, !=, >=, <=, >, <
do_subs(tmpl, "vseq_specialize.lua", 
{ __operator__ = "vseq", 
  __code__ = "c = a == b", 
  __chk_f1_qtype__ = a_chk_f1_qtype, 
  __set_f2_qtype_ = b_set_f2_qtype,
  __set_s1_qtype__ = a_set_s1_qtype, 
  __chk_s1__ = b_chk_s1,
  __set_f2_ctype__ = a_set_f2_ctype})
do_subs(tmpl, "vsneq_specialize.lua", 
{ __operator__ = "vsneq", 
  __code__ = "c = a != b", 
  __chk_f1_qtype__ = a_chk_f1_qtype, 
  __set_f2_qtype__ = b_set_f2_qtype,
  __set_s1_qtype__ = a_set_s1_qtype, 
  __chk_s1__ = b_chk_s1,
  __set_f2_ctype__ = a_set_f2_ctype})
do_subs(tmpl, "vsgeq_specialize.lua", 
{ __operator__ = "vsgeq", 
  __code__ = "c = a >= b", 
  __chk_f1_qtype__ = a_chk_f1_qtype, 
  __set_f2_qtype__ = b_set_f2_qtype,
  __set_s1_qtype__ = a_set_s1_qtype, 
  __chk_s1__ = b_chk_s1,
  __set_f2_ctype__ = a_set_f2_ctype})
do_subs(tmpl, "vsleq_specialize.lua", 
{ __operator__ = "vsleq", 
  __code__ = "c = a <= b", 
  __chk_f1_qtype__ = a_chk_f1_qtype, 
  __set_f2_qtype__ = b_set_f2_qtype,
  __set_s1_qtype__ = a_set_s1_qtype, 
  __chk_s1__ = b_chk_s1,
  __set_f2_ctype__ = a_set_f2_ctype})
do_subs(tmpl, "vsgt_specialize.lua", 
{ __operator__ = "vsgt", 
  __code__ = "c = a > b", 
  __chk_f1_qtype__ = a_chk_f1_qtype, 
  __set_f2_qtype__ = b_set_f2_qtype,
  __set_s1_qtype__ = a_set_s1_qtype, 
  __chk_s1__ = b_chk_s1,
  __set_f2_ctype__ = a_set_f2_ctype})
do_subs(tmpl, "vslt_specialize.lua", 
{ __operator__ = "vslt", 
  __code__ = "c = a < b", 
  __chk_f1_qtype__ = a_chk_f1_qtype, 
  __set_f2_qtype__ = b_set_f2_qtype,
  __set_s1_qtype__ = a_set_s1_qtype, 
  __chk_s1__ = b_chk_s1,
  __set_f2_ctype__ = a_set_f2_ctype})
--=======================
-- handle shift operators 
do_subs(tmpl, "shift_left_specialize.lua", 
{ __operator__ = "shift_left", 
  __code__ = "c = (uint64_t)a << (uint8_t)b", 
  __chk_f1_qtype__ = a_chk_f1_qtype, 
  __set_f2_qtype__ = a_set_f2_qtype,
  __set_s1_qtype__ = a_set_s1_qtype, 
  __chk_s1__ = a_chk_s1, -- note 
  __set_f2_ctype__ = b_set_f2_ctype})
do_subs(tmpl, "shift_right_specialize.lua", 
{ __operator__ = "shift_right", 
  __code__ = "c = (uint64_t)a >> (uint8_t)b", 
  __chk_f1_qtype__ = a_chk_f1_qtype, 
  __set_f2_qtype__ = a_set_f2_qtype,
  __set_s1_qtype__ = a_set_s1_qtype, 
  __chk_s1__ = a_chk_s1, -- note 
  __set_f2_ctype__ = b_set_f2_ctype})
--=======================
-- handle unary operators
do_subs(tmpl, "incr_specialize.lua", 
{ __operator__ = "incr", 
  __code__ = "c = a++ ",
  __chk_f1_qtype__ = a_chk_f1_qtype, 
  __set_f2_qtype__ = a_set_f2_qtype,
  __set_s1_qtype__ = b_set_s1_qtype, 
  __chk_s1__ = b_chk_s1,
  __set_f2_ctype__ = a_set_f2_ctype})
do_subs(tmpl, "decr_specialize.lua", 
{ __operator__ = "decr", 
  __code__ = "c = a-- ",
  __chk_f1_qtype__ = a_chk_f1_qtype, 
  __set_f2_qtype__ = a_set_f2_qtype,
  __set_s1_qtype__ = b_set_s1_qtype, 
  __chk_s1__ = b_chk_s1,
  __set_f2_ctype__ = a_set_f2_ctype})

do_subs(tmpl, "log_specialize.lua", 
{ __operator__ = "log", 
  __code__ = "c = log(a)",
  __chk_f1_qtype__ = a_chk_f1_qtype, 
  __set_f2_qtype__ = a_set_f2_qtype,
  __set_s1_qtype__ = b_set_s1_qtype, 
  __chk_s1__ = b_chk_s1,
  __set_f2_ctype__ = a_set_f2_ctype})
do_subs(tmpl, "exp_specialize.lua", 
{ __operator__ = "exp", 
  __code__ = "c = exp(a) ",
  __chk_f1_qtype__ = a_chk_f1_qtype, 
  __set_f2_qtype__ = a_set_f2_qtype,
  __set_s1_qtype__ = b_set_s1_qtype, 
  __chk_s1__ = b_chk_s1,
  __set_f2_ctype__ = a_set_f2_ctype})

do_subs(tmpl, "sqr_specialize.lua", 
{ __operator__ = "sqr", 
  __code__ = "c = a*a ",
  __chk_f1_qtype__ = a_chk_f1_qtype, 
  __set_f2_qtype__ = a_set_f2_qtype,
  __set_s1_qtype__ = b_set_s1_qtype, 
  __chk_s1__ = b_chk_s1,
  __set_f2_ctype__ = a_set_f2_ctype})

do_subs(tmpl, "sqrt_specialize.lua", 
{ __operator__ = "sqrt", 
  __code__ = "c = sqrt(a)",
  __chk_f1_qtype__ = a_chk_f1_qtype, 
  __set_f2_qtype__ = a_set_f2_qtype,
  __set_s1_qtype__ = b_set_s1_qtype, 
  __chk_s1__ = b_chk_s1,
  __set_f2_ctype__ = a_set_f2_ctype})

do_subs(tmpl, "reciprocal_specialize.lua", 
{ __operator__ = "reciprocal", 
  __code__ = "c = 1.0 / a ", 
  __chk_f1_qtype__ = a_chk_f1_qtype, 
  __set_f2_qtype__ = c_set_f2_qtype, -- note 
  __set_s1_qtype__ = b_set_s1_qtype, 
  __chk_s1__ = b_chk_s1,
  __set_f2_ctype__ = a_set_f2_ctype})

do_subs(tmpl, "vnot_specialize.lua", 
{ __operator__ = "vabs", 
  __code__ = " TODO",
  __chk_f1_qtype__ = a_chk_f1_qtype, 
  __set_f2_qtype__ = c_set_f2_qtype, -- note 
  __set_s1_qtype__ = b_set_s1_qtype, 
  __chk_s1__ = b_chk_s1,
  __set_f2_ctype__ = a_set_f2_ctype})
do_subs(tmpl, "vabs_specialize.lua", 
{ __operator__ = "vabs", 
  __code__ = " TODO",
  __chk_f1_qtype__ = a_chk_f1_qtype, 
  __set_f2_qtype__ = c_set_f2_qtype, -- note 
  __set_s1_qtype__ = b_set_s1_qtype, 
  __chk_s1__ = b_chk_s1,
  __set_f2_ctype__ = a_set_f2_ctype})
do_subs(tmpl, "vnegate_specialize.lua", 
{ __operator__ = "vnegate", 
  __code__ = " if ( a == 0 ) { c = 1; } else { c = 0; } ", 
  __chk_f1_qtype__ = c_chk_f1_qtype, -- note 
  __set_f2_qtype__ = a_set_f2_qtype, 
  __set_s1_qtype__ = b_set_s1_qtype, 
  __chk_s1__ = b_chk_s1,
  __set_f2_ctype__ = a_set_f2_ctype})

do_subs(tmpl, "logit_specialize.lua", 
{ __operator__ = "logit", 
  __code__ = " c = 1.0 / ( 1.0 + exp(-1.0 * a ) ) ",
  __chk_f1_qtype__ = d_chk_f1_qtype, -- note
  __set_f2_qtype__ = a_set_f2_qtype, 
  __set_s1_qtype__ = b_set_s1_qtype, 
  __chk_s1__ = b_chk_s1,
  __set_f2_ctype__ = a_set_f2_ctype})
do_subs(tmpl, "logit2_specialize.lua", 
{ __operator__ = "logit2", 
  __code__ = " double tmp = (1.0 + exp(-1.0 * a)); c = 1.0 / ( tmp * tmp) ",
  __chk_f1_qtype__ = d_chk_f1_qtype, -- note
  __set_f2_qtype__ = a_set_f2_qtype, 
  __set_s1_qtype__ = b_set_s1_qtype, 
  __chk_s1__ = b_chk_s1,
  __set_f2_ctype__ = a_set_f2_ctype})
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
