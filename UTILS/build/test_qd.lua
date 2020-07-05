-- Quick and dirty test
require 'Q/UTILS/lua/strict'
local Scalar  = require 'libsclr'
local lVector = require 'Q/RUNTIME/VCTR/lua/lVector'
local Q       = require 'Q'
--=====================================
local T = {}
for i = 1, 3 do T[#T+1] = i end 
local x = Q.mk_col(T, "I4")
for i = 1, 3 do 
  local x = x:get1(i-1)
  assert(type(x) == "Scalar")
  assert(x == Scalar.new(i, "I4"))
end
--=====================================
local y = Q.const({ val = 1, len = 3, qtype = "F4"}):eval()
Q.print_csv(y)
--=====================================
local y = Q.seq({ start = 10, by = 20, len = 3, qtype = "I2"}):eval()
Q.print_csv(y)
--=====================================
local y = Q.rand({ lb = 0, ub = 1, len = 3, qtype = "F8"}):eval()
Q.print_csv(y)
--=====================================
local y = Q.period({ start = 1, by = 4, period = 2, len = 5, qtype = "I8"}):eval()
Q.print_csv(y)
--=====================================
local n1, n2 = Q.min(y):eval()
print("min ", n1, n2)
local n1, n2 = Q.max(y):eval()
print("max ", n1, n2)
local n1, n2 = Q.sum(y):eval()
print("sum ", n1, n2)


print("Success")
os.exit()
