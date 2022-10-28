local qcfg = require 'Q/UTILS/lua/qcfg'
local n1 = qcfg.num_in_chunk
assert(type(n1) == "number")
assert(n1 > 0)
--===
qcfg._modify("num_in_chunk", n1+1)

local n2 = qcfg.num_in_chunk
assert(type(n2) == "number")
assert(n2 == n1+1)
print("Test test_qcfg succeeded")
