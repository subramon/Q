--[[
-- Demo for dynamic compilation. 
-- Remember to unregister radius in f1f2opf3.lua
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
cradius = Q.radius(c3, c4)
--======== break3
assert(cradius == nil)
radius = 
  Q.register("Q/OPERATORS/F1F2OPF3/lua/expander_f1f2opf3", "radius")
assert(type(radius) == "function")
--======== break4
cradius = Q.radius(c3, c4)
assert(type(cradius) == "lVector")
n1, n2 = Q.sum(Q.vveq(cradius, c5)):eval()
Q.head(cradius)
assert(n1 == n2)
print("All done")
