-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q       = require 'Q'
local cVector = require 'libvctr'

local tests = {}
assert(type(Q.seq) == "function")
assert(type(Q.concat) == "function")
tests.t1 = function()
  local max_num_in_chunk = 64  -- must be multiple of 64 for B1
  local len = max_num_in_chunk + 17 
  local optargs = { max_num_in_chunk = max_num_in_chunk }
  local c1 = Q.seq( {len = len, start = 1, by = 1, qtype = "I4", 
    max_num_in_chunk = max_num_in_chunk})
  c1:set_name("c1")
  assert(c1:max_num_in_chunk() == max_num_in_chunk)
  local c2 = Q.concat(c1, c1, { f3_qtype = "I8", shift_by = 32})
  assert(c2:max_num_in_chunk() == max_num_in_chunk)
  assert(c2:qtype() == "I8")
  c2:set_name("c2")
  c2:eval()
  assert(c2:num_elements() == c1:num_elements())
  -- c2:pr()

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
  137438953504, 
  141733920801, 
  146028888098, 
  150323855395, 
  154618822692, 
  158913789989, 
  163208757286, 
  167503724583, 
  171798691880, 
  176093659177, 
  180388626474, 
  184683593771, 
  188978561068, 
  193273528365, 
  197568495662, 
  201863462959, 
  206158430256, 
  210453397553, 
  214748364850, 
  219043332147, 
  223338299444, 
  227633266741, 
  231928234038, 
  236223201335, 
  240518168632, 
  244813135929, 
  249108103226, 
  253403070523, 
  257698037820, 
  261993005117, 
  266287972414, 
  270582939711, 
  274877907008, 
  279172874305, 
  283467841602, 
  287762808899, 
  292057776196, 
  296352743493, 
  300647710790, 
  304942678087, 
  309237645384, 
  313532612681, 
  317827579978, 
  322122547275, 
  326417514572, 
  330712481869, 
  335007449166, 
  339302416463, 
  343597383760, 
  347892351057, 
  }, "I8", optargs)
  assert(c3:is_eov())
  c3:set_name("c3")
  assert(c3:num_elements() == c2:num_elements())
  assert(c2:max_num_in_chunk() == c3:max_num_in_chunk())
  local c4 = Q.vveq(c2, c3):set_name("c4"):eval()
  assert(c4:num_elements() == c2:num_elements())
  -- c4:pr()

  local n1, n2 = Q.sum(Q.vveq(c2, c3):set_name("tmp")): eval()
  assert(n1:to_num() == c2:num_elements())
  assert(n2:to_num() == c2:num_elements())
  -- Q.print_csv({c1, c2, c3})
  -- Q.print_csv({c1, c2, c3}, { impl = "C" })
  assert(c3:qtype() == "I8")
  for i = 1, c3:num_elements() do 
    assert(c3:get1(i-1) == c2:get1(i-1))
  end
  print("Test t1 succeeded")
end

tests.t1()
os.exit()
-- return tests
