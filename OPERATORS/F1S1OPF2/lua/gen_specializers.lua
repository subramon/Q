local plfile = require 'pl.file'
local plpath = require 'pl.path'
--=======================
assert(plpath.isfile("arith_specialize.tmpl"), "File not found")
local x = plfile.read("arith_specialize.tmpl")

y = string.gsub(x, "<<operator>>", "vsadd")
y = string.gsub(y, "<<c_code>>", "c = a + b")
plfile.write("vsadd_specialize.lua", y)
--=======================
y = string.gsub(x, "<<operator>>", "pow")
y = string.gsub(y, "<<c_code>>", "c = pow((double)a, (double)b)")
plfile.write("pow_specialize.lua", y)
--=======================
y = string.gsub(x, "<<operator>>", "vssub")
y = string.gsub(y, "<<c_code>>", "c = a - b")
plfile.write("vssub_specialize.lua", y)
--=======================
y = string.gsub(x, "<<operator>>", "vsmul")
y = string.gsub(y, "<<c_code>>", "c = a * b")
plfile.write("vsmul_specialize.lua", y)
--=======================
y = string.gsub(x, "<<operator>>", "vsdiv")
y = string.gsub(y, "<<c_code>>", "c = a / b")
plfile.write("vsdiv_specialize.lua", y)
--=======================
y = string.gsub(x, "<<operator>>", "vsrem")
y = string.gsub(y, "<<c_code>>", 'c = a %% b;')
plfile.write("vsrem_specialize.lua", y)
--=======================
y = string.gsub(x, "<<operator>>", "vsand")
y = string.gsub(y, "<<c_code>>", "c = a & b;")
plfile.write("vsand_specialize.lua", y)
--=======================
y = string.gsub(x, "<<operator>>", "vsor")
y = string.gsub(y, "<<c_code>>", "c = a | b;")
plfile.write("vsor_specialize.lua", y)
--=======================
y = string.gsub(x, "<<operator>>", "vsxor")
y = string.gsub(y, "<<c_code>>", "c = a ^ b;")
plfile.write("vsxor_specialize.lua", y)
--=======================
assert(plpath.isfile("cmp_specialize.tmpl"), "File not found")
local x = plfile.read("cmp_specialize.tmpl")

y = string.gsub(x, "<<operator>>", "vseq")
y = string.gsub(y, "<<comparison>>", " == " )
plfile.write("vseq_specialize.lua", y)
--=======================
y = string.gsub(x, "<<operator>>", "vsneq")
y = string.gsub(y, "<<comparison>>", " != " )
plfile.write("vsneq_specialize.lua", y)
--=======================
y = string.gsub(x, "<<operator>>", "vsleq")
y = string.gsub(y, "<<comparison>>", " <= " )
plfile.write("vsleq_specialize.lua", y)
--=======================
y = string.gsub(x, "<<operator>>", "vsgeq")
y = string.gsub(y, "<<comparison>>", " >= " )
plfile.write("vsgeq_specialize.lua", y)
--=======================
y = string.gsub(x, "<<operator>>", "vsgt")
y = string.gsub(y, "<<comparison>>", " > " )
plfile.write("vsgt_specialize.lua", y)
--=======================
y = string.gsub(x, "<<operator>>", "vslt")
y = string.gsub(y, "<<comparison>>", " < " )
plfile.write("vslt_specialize.lua", y)
--=======================
-- assert(plpath.isfile("cmp2_specialize.tmpl"), "File not found")
-- local x = plfile.read("cmp2_specialize.tmpl")
-- 
-- y = string.gsub(x, "<<operator>>", "vsltorgt")
-- y = string.gsub(y, "<<comparator1>>", " < " )
-- y = string.gsub(y, "<<comparator2>>", " > " )
-- y = string.gsub(y, "<<combiner>>", " || " )
-- plfile.write("vsltorgt_specialize.lua", y)
-- --=======================
-- y = string.gsub(x, "<<operator>>", "vsleqorgeq")
-- y = string.gsub(y, "<<comparator1>>", " <= " )
-- y = string.gsub(y, "<<comparator2>>", " >= " )
-- y = string.gsub(y, "<<combiner>>", " || " )
-- plfile.write("vsleqorgeq_specialize.lua", y)
-- --=======================
-- y = string.gsub(x, "<<operator>>", "vsgtandlt")
-- y = string.gsub(y, "<<comparator1>>", " > " )
-- y = string.gsub(y, "<<comparator2>>", " < " )
-- y = string.gsub(y, "<<combiner>>", " && " )
-- plfile.write("vsgtandlt_specialize.lua", y)
-- --=======================
-- y = string.gsub(x, "<<operator>>", "vsgeqandleq")
-- y = string.gsub(y, "<<comparator1>>", " >= " )
-- y = string.gsub(y, "<<comparator2>>", " <= " )
-- y = string.gsub(y, "<<combiner>>", " && " )
-- plfile.write("vsgeqandleq_specialize.lua", y)
--=======================
assert(plpath.isfile("f1opf2_specialize.tmpl"), "File not found")
local x = plfile.read("f1opf2_specialize.tmpl")

y = string.gsub(x, "<<operator>>", "exp")
y = string.gsub(y, "<<c_code_for_operator>>", "c = exp((double)a);")
y = string.gsub(y, "<<out_qtype>>", '"F8"')
plfile.write("exp_specialize.lua", y)
--=======================
y = string.gsub(x, "<<operator>>", "reciprocal")
y = string.gsub(y, "<<c_code_for_operator>>", "c = 1 / a; ")
y = string.gsub(y, "<<out_qtype>>", 'in_qtype')
plfile.write("reciprocal_specialize.lua", y)
--=======================
y = string.gsub(x, "<<operator>>", "sqrt")
y = string.gsub(y, "<<c_code_for_operator>>", "c = sqrt((double)a);")
y = string.gsub(y, "<<out_qtype>>", 'in_qtype')
plfile.write("sqrt_specialize.lua", y)
--=======================
y = string.gsub(x, "<<operator>>", "sqr")
y = string.gsub(y, "<<c_code_for_operator>>", "c = (a * a);")
y = string.gsub(y, "<<out_qtype>>", 'in_qtype')
plfile.write("sqr_specialize.lua", y)
--=======================
y = string.gsub(x, "<<operator>>", "log")
y = string.gsub(y, "<<c_code_for_operator>>", "c = log((double)a);")
y = string.gsub(y, "<<out_qtype>>", '"F8"')
plfile.write("log_specialize.lua", y)
--=======================
y = string.gsub(x, "<<operator>>", "incr")
y = string.gsub(y, "<<c_code_for_operator>>", "c = a + 1;")
y = string.gsub(y, "<<out_qtype>>", "in_qtype")
plfile.write("incr_specialize.lua", y)
--=======================
y = string.gsub(x, "<<operator>>", "decr")
y = string.gsub(y, "<<c_code_for_operator>>", "c = a - 1;")
y = string.gsub(y, "<<out_qtype>>", "in_qtype")
plfile.write("decr_specialize.lua", y)
--=======================
y = string.gsub(x, "<<operator>>", "logit")
y = string.gsub(y, "<<c_code_for_operator>>", 
  "c = 1.0 / ( 1.0 + exp(-1.0 * a)); ")
y = string.gsub(y, "<<out_qtype>>", '"F8"')
plfile.write("logit_specialize.lua", y)
--=======================
y = string.gsub(x, "<<operator>>", "logit2")
y = string.gsub(y, "<<c_code_for_operator>>", 
" c = 1.0 / mcr_sqr ( ( 1.0 + exp(-1.0 *a) ) ); " )
y = string.gsub(y, "<<out_qtype>>", '"F8"')
plfile.write("logit2_specialize.lua", y)
--=======================
local tbl = 'local funcs = {I1 = "abs", I2 = "abs", I4 = "abs", I8 = "abs", F4 = "fabsf", F8 = "fabs"}\n'
local tbl2 = 'local cast = {I1 = "(int8_t)", I2 = "(int16_t)", I4 = "(int32_t)", I8 = "(int64_t)", F4 = "", F8 = ""}\n'
local z = x
local w = "\n" .. tbl .. tbl2
y = string.gsub(z, "--preamble", w)
y = string.gsub(y, "<<operator>>", "abs")
y = string.gsub(y, "<<c_code_for_operator>>", "c = ".. '".. cast[in_qtype] .. funcs[in_qtype] .."'.."(a);")
y = string.gsub(y, "<<out_qtype>>", "in_qtype")
plfile.write("abs_specialize.lua", y)
--=======================
