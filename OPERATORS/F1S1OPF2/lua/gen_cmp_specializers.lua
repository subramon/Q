local do_subs = require 'Q/UTILS/lua/do_subs'
local tmpl = 'cmp_specialize.tmpl'
--==============================
-- handle comparison operators ==, !=, >=, <=, >, <
do_subs(tmpl, "vseq_specialize.lua", 
{ __operator__ = "'vseq'", 
  __code__ = "'c = a == b;'", 
})
do_subs(tmpl, "vsneq_specialize.lua", 
{ __operator__ = "'vsneq'", 
  __code__ = "'c = a != b;'", 
})
do_subs(tmpl, "vsgeq_specialize.lua", 
{ __operator__ = "'vsgeq'", 
  __code__ = "'c = a >= b;'", 
})
do_subs(tmpl, "vsleq_specialize.lua", 
{ __operator__ = "'vsleq'", 
  __code__ = "'c = a <= b;'", 
})
do_subs(tmpl, "vsgt_specialize.lua", 
{ __operator__ = "'vsgt'", 
  __code__ = "'c = a > b;'", 
})
do_subs(tmpl, "vslt_specialize.lua", 
{ __operator__ = "'vslt'", 
  __code__ = "'c = a < b;'", 
})
--=======================
