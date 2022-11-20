-- FUNCTIONAL 
require 'Q/UTILS/lua/strict'
local Q       = require 'Q'
local Scalar  = require 'libsclr'
local qcfg    = require 'Q/UTILS/lua/qcfg'
local max_num_in_chunk = qcfg.max_num_in_chunk
local cVector = require 'libvctr'

local tests = {}
local qtype = "I4"
local len = 2 * max_num_in_chunk + 19
local invals = {}
for i = 1, len do 
  invals[i] = i
end
local c1 = Q.mk_col(invals,  qtype)
assert(type(c1) == "lVector")
assert(c1:num_elements() == len)
local n = len

tests.t_sum = function ()
  local z = Q.sum(c1)
  assert(type(z) == "Reducer")
  local status = true repeat status = z:next() until not status
  local val, num = z:value()
  assert(type(val) == "Scalar")
  local exp_val = Scalar.new( ((n*(n+1))/2), "I8")
  assert(val == exp_val)
  assert(type(num) == "Scalar")
  assert(num == Scalar.new(len, "I8"))
  assert(cVector.check_all())
  print("t_sum succeeded")
end

tests.t_min = function ()
  local z = Q.min(c1)
  assert(type(z) == "Reducer")
  local status = true repeat status = z:next() until not status
  local val, num, idx  = z:value()
  assert(type(val) == "Scalar")
  assert(type(num) == "Scalar")
  assert(type(idx) == "Scalar")
  assert(val == Scalar.new(1, qtype))
  assert(num == Scalar.new(len, "I8"))
  assert(idx == Scalar.new(1-1, "I8"))
  assert(cVector.check_all())
  print("t_min succeeded")
end

tests.t_max = function ()
  local z = Q.max(c1)
  assert(type(z) == "Reducer")
  local status = true repeat status = z:next() until not status
  local val, num, idx = z:value()
  assert(type(val) == "Scalar")
  assert(type(num) == "Scalar")
  assert(type(idx) == "Scalar")
  assert(val == Scalar.new(len, qtype))
  assert(num == Scalar.new(len, "I8"))
  assert(idx == Scalar.new(len-1, "I8"))
  assert(cVector.check_all())
  print("t_max succeeded")
end

-- return tests
tests.t_sum()
tests.t_min()
tests.t_max()
os.exit()

