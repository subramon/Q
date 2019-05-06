local Q = require 'Q'
local x = Q.mk_col({1,2,3}, "I4")
Q.print_csv(x)
print("ALL DONE")
