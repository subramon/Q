-- FUNCTIONA
require 'Q/UTILS/lua/strict'
local Q       = require 'Q'
local cVector = require 'libvctr'

local tests = {}
assert(type(Q.seq) == "function")
assert(type(Q.concat) == "function")
tests.t1 = function()
  local max_num_in_chunk = 64 
  local len = max_num_in_chunk + 13
  local optargs = { max_num_in_chunk = max_num_in_chunk }

  local xin = Q.seq( {len = len, start = 1, by = 1, qtype = "I4", 
    max_num_in_chunk = max_num_in_chunk})
  assert(xin:max_num_in_chunk() == max_num_in_chunk)

  local yin = Q.seq( {len = len, start = 0, by = 1, qtype = "I4", 
    max_num_in_chunk = max_num_in_chunk})

  local xout = Q.vvsub(xin, yin)
  assert(xout:max_num_in_chunk() == max_num_in_chunk)
  assert(xout:qtype() == "I4")
  assert(xout:num_elements() == xin:num_elements())
  xout:eval()

  -- check values in xout
  local good_vals = {}
  for i = 1, len do good_vals[i] = 1 end 
  local good_xout = Q.mk_col(good_vals, "I4"):eval()

  for i = 1, xout:num_elements() do 
    assert(xout:get1(i-1) == good_xout:get1(i-1))
  end
  -- xout:pr()
  print("Test t1 succeeded")
end

tests.t1()
os.exit()
-- return tests
