--[[
-- Demo for dynamic compilation. 
-- Remember to unregister enorm in f1f2opf3.lua
----]]
--
Q = require 'Q'
qtype = "F4"
len = 20
c3 = Q.const({val = 3, len = len, qtype = qtype})
c4 = Q.const({val = 4, len = len, qtype = qtype})
c5 = Q.const({val = 5, len = len, qtype = qtype})
cplus = Q.vvadd(c3, c4)
--======== break1
Q.head(cplus)
--======== break2
v_enorm = Q.enorm(c3, c4)
--======== break3
assert(l_enorm == nil)
f_enorm = 
  Q.register("Q/OPERATORS/F1F2OPF3/lua/expander_f1f2opf3", "f_enorm")
assert(type(f_enorm) == "function")
--======== break4
v_enorm = Q.f_enorm(c3, c4)
assert(type(v_enorm) == "lVector")
n1, n2 = Q.sum(Q.vveq(v_enorm, c5)):eval()
Q.head(v_enorm)
assert(n1 == n2)
print("All done")
