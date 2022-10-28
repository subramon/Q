-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q       = require 'Q'
local cVector = require 'libvctr'

local tests = {}
assert(type(Q.seq) == "function")
assert(type(Q.concat) == "function")
tests.t1 = function()
  local max_num_in_chunk = 16  -- must be multiple of 64 for B1
  local len = ( max_num_in_chunk * 2 ) -1 
  local optargs = { max_num_in_chunk = max_num_in_chunk }
  local c1 = Q.seq( {len = len, start = 1, by = 1, qtype = "I4", 
    max_num_in_chunk = max_num_in_chunk})
  assert(c1:max_num_in_chunk() == max_num_in_chunk)
  local c2 = Q.concat(c1, c1, { f3_qtype = "I8", shift_by = 32})
  assert(c2:max_num_in_chunk() == max_num_in_chunk)
  assert(c2:qtype() == "I8")
  c2:eval()
  assert(c2:num_elements() == c1:num_elements())

local c3 = Q.mk_col( {
4294967297,
8589934594,
12884901891,
17179869188,
21474836485,
25769803782,
30064771079,
34359738376,
38654705673,
42949672970,
47244640267,
51539607564,
55834574861,
60129542158,
64424509455,
68719476752,
73014444049,
77309411346,
81604378643,
85899345940,
90194313237,
94489280534,
98784247831,
103079215128,
107374182425,
111669149722,
115964117019,
120259084316,
124554051613,
128849018910,
133143986207,
}, "I8", optargs)
  -- TODO local n1, n2 = Q.sum(Q.vveq(c2, c3)): eval()
  -- TODO assert(n1:to_num() == c2:num_elements())
  -- TODO assert(n2:to_num() == c2:num_elements())
  Q.print_csv({c1, c2, c3})
  Q.print_csv({c1, c2, c3}, { impl = "C" })
  assert(c3:qtype() == "I8")
  assert(c3:num_elements() == c2:num_elements())
  for i = 1, c3:num_elements() do 
    assert(c3:get1(i-1) == c2:get1(i-1))
  end
  print("Test t1 succeeded")
end

tests.t1()
os.exit()
-- return tests
