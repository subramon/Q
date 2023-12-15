local lgutils = require 'liblgutils'
local Q = require 'Q'
local qcfg = require 'Q/UTILS/lua/qcfg'
local qtypes = { "I4", "I8", "F4", "F8", }
local tests = {}
tests.t1 = function() 
  assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
  local len = 2 * qcfg.max_num_in_chunk + 17 
  for _, qtype in ipairs(qtypes) do 
    local x = Q.seq({start = 1, by = 1, qtype = qtype, len = len}):eval()
    x:set_meta("sort_order", "asc")
    -- search for something too small 
    local pos = Q.find(x, 0)
    assert(pos == -1) 
    -- search for something too big
    local pos = Q.find(x, len+2)
    assert(pos == -1) 
    -- search for something just right 
    local pos = Q.find(x, math.floor(len/2))
    assert((pos >= 0)  and ( pos < len))
    x:delete()
    print("Test t1 completed successfull for qtype = ", qtype)
  end
  assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
  print("Test t1 completed successfully")
end
tests.t1()
-- return tests
