--[[
-- Demo for dynamic compilation. 
-- Remember to unregister radius in f1f2opf3.lua
----]]
--
local cVector = require 'libvctr'
local Q = require 'Q'
local qtype = "F4"
local len = 20
c3 = Q.const({val = 3, len = len, qtype = qtype})
c4 = Q.const({val = 4, len = len, qtype = qtype})
c5 = Q.const({val = 5, len = len, qtype = qtype})
cplus = Q.vvadd(c3, c4)
Q.head(cplus)
cradius = Q.radius(c3, c4)
assert(cradius == nil)
local radius = 
  Q.register("Q/OPERATORS/F1F2OPF3/lua/expander_f1f2opf3", "radius")
assert(type(radius) == "function")
cradius = Q.radius(c3, c4)
assert(type(cradius) == "lVector")
local n1, n2 = Q.sum(Q.vveq(cradius, c5)):eval()
Q.head(cradius)
assert(n1 == n2)
print("All done")
