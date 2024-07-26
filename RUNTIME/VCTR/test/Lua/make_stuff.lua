local Q = require 'Q'
local qcfg = require 'Q/UTILS/lua/qcfg'
x = Q.const({len = 16385, val = 1, qtype = "I4", }):eval()
Q.save()
print("Completed make_stuff.lua")
