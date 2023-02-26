local do_subs = require 'Q/UTILS/lua/do_subs'
local tmpl = 'unary_specialize.tmpl'
--==============================
-- handle ++, --, log, exp, sqr, sqrt, logit, logit2, ...
do_subs(tmpl, "vincr.lua", 
{ __operator__ = "'vincr'", 
  __code__ = "'c = a++;'", 
})
do_subs(tmpl, "vdecr_specialize.lua", 
{ __operator__ = "'vdecr'", 
  __code__ = "'c = a--; ' ",
})
do_subs(tmpl, "vexp.lua", 
{ __operator__ = "'vslt'", 
  __code__ = "'c = exp(a);'", 
})
do_subs(tmpl, "vlog.lua", 
{ __operator__ = "'vlog'", 
  __code__ = "'c = log(a);'", 
})
do_subs(tmpl, "vsqr.lua", 
{ __operator__ = "'vsqr'", 
  __code__ = "'c = a * a ; ",
})
do_subs(tmpl, "vsqrt.lua", 
{ __operator__ = "'vsqrt'", 
  __code__ = "'c = sqrt(a); ",
})
--=======================
