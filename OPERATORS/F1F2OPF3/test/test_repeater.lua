-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q       = require 'Q'
local cVector = require 'libvctr'

local tests = {}
assert(type(Q.seq) == "function")
assert(type(Q.repeater) == "function")
tests.t1 = function()
  local max_num_in_chunk = 16  -- must be multiple of 64 for B1
  local len = max_num_in_chunk

  local vals = {}
  for i = 1, len do vals[i] = (i+1)*10 end
  local v = Q.mk_col(vals, "I4", { max_num_in_chunk = max_num_in_chunk, } )

  local repeats = {}
  for i = 1, len do repeats[i] = i-1 end 
  local r = Q.mk_col(repeats, "I8", { max_num_in_chunk = max_num_in_chunk, } )

  local num_in_s = 0 
  for i = 1, len do num_in_s = num_in_s + repeats[i] end 
  v:eval()
  r:eval()
  local s = Q.repeater(v, r) 
  assert(type(s) == "lVector")
  assert(s:qtype() == "I4")
  s:eval()
  assert(s:num_elements() == num_in_s)
  print("Test t1 succeeded")
end

tests.t1()
-- return tests