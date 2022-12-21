local do_subs = require 'Q/UTILS/lua/do_subs'
local tmpl = 'cmp_specialize.tmpl'
--==============================
-- handle comparison operators ==, !=, >=, <=, >, <
do_subs(tmpl, "vseq_specialize.lua", 
{ __operator__ = "'vseq'", 
  __code__ = "'c = a == b;'", 
  __good_f1_types__ = '{ "I1", "I2", "I4", "I8", "F4", "F8" }', 
  __good_s1_types__ = '{ "I1", "I2", "I4", "I8", "F4", "F8" }', 
})
do_subs(tmpl, "vsneq_specialize.lua", 
{ __operator__ = "'vsneq'", 
  __code__ = "'c = a != b;'", 
  __good_f1_types__ = '{ "I1", "I2", "I4", "I8", "F4", "F8" }', 
  __good_s1_types__ = '{ "I1", "I2", "I4", "I8", "F4", "F8" }', 
})
do_subs(tmpl, "vsgeq_specialize.lua", 
{ __operator__ = "'vsgeq'", 
  __code__ = "'c = a >= b;'", 
  __good_f1_types__ = '{ "I1", "I2", "I4", "I8", "F4", "F8" }', 
  __good_s1_types__ = '{ "I1", "I2", "I4", "I8", "F4", "F8" }', 
})
do_subs(tmpl, "vsleq_specialize.lua", 
{ __operator__ = "'vsleq'", 
  __code__ = "'c = a <= b;'", 
  __good_f1_types__ = '{ "I1", "I2", "I4", "I8", "F4", "F8" }', 
  __good_s1_types__ = '{ "I1", "I2", "I4", "I8", "F4", "F8" }', 
})
do_subs(tmpl, "vsgt_specialize.lua", 
{ __operator__ = "'vsgt'", 
  __code__ = "'c = a > b;'", 
  __good_f1_types__ = '{ "I1", "I2", "I4", "I8", "F4", "F8" }', 
  __good_s1_types__ = '{ "I1", "I2", "I4", "I8", "F4", "F8" }', 
})
do_subs(tmpl, "vslt_specialize.lua", 
{ __operator__ = "'vslt'", 
  __code__ = "'c = a < b;'", 
  __good_f1_types__ = '{ "I1", "I2", "I4", "I8", "F4", "F8" }', 
  __good_s1_types__ = '{ "I1", "I2", "I4", "I8", "F4", "F8" }', 
})
--=======================
do_subs(tmpl, "shift_left_specialize.lua", 
{ __operator__ = "'shift_left'", 
  __code__ = "'c = a < b;'", 
  __good_f1_types__ = '{ "I1", "I2", "I4", "I8", }', 
  __good_s1_types__ = '{ "I1", "I2", "I4", "I8", }', 
})
do_subs(tmpl, "shift_right.lua", 
{ __operator__ = "'shift_right'", 
  __code__ = "'c = a < b;'", 
  __good_f1_types__ = '{ "I1", "I2", "I4", "I8", }', 
  __good_s1_types__ = '{ "I1", "I2", "I4", "I8", }', 
})
--=======================
