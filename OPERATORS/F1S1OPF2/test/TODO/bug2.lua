--  FUNCTIONAL 
local Q = require 'Q'
require 'Q/UTILS/lua/strict'
local Scalar = require 'libsclr'

local val = 127
local len = 65537
local old_qtype = "I1"

local x = Q.const({ len = len, qtype = old_qtype, val = Scalar.new(val, old_qtype)})
-- x:eval()
local chksum = Q.sum(x):eval():to_num()
print(chksum,  len  * val)
assert(chksum == len  * val)
print("so far so good")
--==================================
local x = Q.const({ len = len, qtype = old_qtype, val = Scalar.new(val, old_qtype)})
x:eval()
local chksum = Q.sum(x):eval():to_num()
print(chksum,  len  * val)
assert(chksum == len  * val)
print("Success")
--=====================
