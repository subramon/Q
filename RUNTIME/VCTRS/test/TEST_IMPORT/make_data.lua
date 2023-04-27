local Q = require 'Q'
local qcfg = require 'Q/UTILS/lua/qcfg'
local n = qcfg.max_num_in_chunk
local largs = { len = len, qtype = "I4", val = 123}
largs.max_num_in_chunk = 64 
local len = (2 * largs.max_num_in_chunk) + 3
x = Q.const({ len = len, qtype = "I4", val = 123})
x:set_name("original_x")
x:eval()
Q.save()
