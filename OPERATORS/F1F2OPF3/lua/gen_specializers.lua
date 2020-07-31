nargs = #arg
do_all = false
do_arith = false
do_cmp = false
do_bop = false
assert(nargs < 2 )
if nargs == 0 then do_all = true end 
if nargs == 1 then
  for i = 1, nargs do
    if arg[i] == "arith" then do_arith = true end 
    if arg[i] == "cmp"   then do_cmp   = true end 
    if arg[i] == "bop"   then do_bop   = true end 
    if arg[i] == "all"   then do_all   = true end 
  end
end

local do_subs = require 'Q/UTILS/lua/do_subs'

if do_cmp or do_all then 
  do_subs("cmp_specialize.tmpl", "vveq_specialize.lua",
    { __operator__ =  "vveq", __comparator__ = "=="})
  do_subs("cmp_specialize.tmpl", "vvneq_specialize.lua",
    { __operator__ =  "vvneq", __comparator__ = "!="})
  do_subs("cmp_specialize.tmpl", "vvleq_specialize.lua",
    { __operator__ =  "vvleq", __comparator__ = "<="})
  do_subs("cmp_specialize.tmpl", "vvgeq_specialize.lua",
    { __operator__ =  "vvgeq", __comparator__ = ">="})
  do_subs("cmp_specialize.tmpl", "vvlt_specialize.lua",
    { __operator__ =  "vvlt",  __comparator__ = "<"})
  do_subs("cmp_specialize.tmpl", "vvgt_specialize.lua",
    { __operator__ =  "vvgt",  __comparator__ = ">"})
end
--+++++++++++++++++++++++++
if do_arith or do_all then 
  do_subs("arith_specialize.tmpl", "vvadd_specialize.lua",
    { __operator__ = "vvadd", __mathsymbol__ = "+"})
  do_subs("arith_specialize.tmpl", "vvsub_specialize.lua",
    { __operator__ = "vvsub", __mathsymbol__ = "-"})
  do_subs("arith_specialize.tmpl", "vvmul_specialize.lua",
    { __operator__ = "vvmul", __mathsymbol__ = "*"})
  do_subs("arith_specialize.tmpl", "vvdiv_specialize.lua",
    { __operator__ = "vvdiv", __mathsymbol__ = "/"})
end
--=======================
--+++++++++++++++++++++++++
if do_bop or do_all then 
  do_subs("bop_specialize.tmpl", "vvand_specialize.lua", 
    { __operator__ = "vvand", __mathsymbol = "&"})
  
  y = string.gsub(x, "<<operator>>", "vvand")
  y = string.gsub(y, "<<mathsymbol>>", "&")
  plfile.write("vvand_specialize.lua", y)
  --=======================
  y = string.gsub(x, "<<operator>>", "vvor")
  y = string.gsub(y, "<<mathsymbol>>", "|")
  plfile.write("vvor_specialize.lua", y)
  --=======================
  y = string.gsub(x, "<<operator>>", "vvxor")
  y = string.gsub(y, "<<mathsymbol>>", "^")
  plfile.write("vvxor_specialize.lua", y)
  --=======================
  y = string.gsub(x, "<<operator>>", "vvandnot")
  y = string.gsub(y, "<<mathsymbol>>", "& ~")
  plfile.write("vvandnot_specialize.lua", y)
end
--=======================

print("ALL DONE")
