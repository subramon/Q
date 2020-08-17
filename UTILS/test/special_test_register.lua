--[[
--The reason we call this a special test is that you need to 
--make sure that vssub is not registered in f1s1opf2.lua
----]]
--
Scalar = require 'libsclr'
cVector = require 'libvctr'
Q = require 'Q'
c1 = Q.const({val = 1, len = 10, qtype = "I4"})
s1 = Scalar.new(3)
cplus = Q.vsadd(c1, s1)
cminus = Q.vssub(cplus, s1)
assert(cminus == nil)
local x = Q.register("Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2", "vssub")
assert(type(x) == "function")
cminus = Q.vssub(cplus, s1)
assert(type(cminus) == "lVector")
local n1, n2 = Q.sum(Q.vveq(c1, cminus)):eval()
print(n1, n2)
