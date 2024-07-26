local Q = require 'Q'
assert(type(x) == "lVector")
assert(x:num_elements() == 16385)
assert(x:qtype() == "I4")
local n1, n2 = Q.sum(x):eval()
assert(n1:to_num() == 16385)
print("Completed restore_stuff.lua")
