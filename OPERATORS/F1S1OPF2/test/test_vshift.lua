-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local vshift = require 'Q/OPERATORS/F1S1OPF2/lua/vshift'
local mk_col = require 'Q/OPERATORS/MK_COL/lua/mk_col'
local Scalar = require 'libsclr'
local lgutils = require 'liblgutils'

local max_num_in_chunk = 64
local qtypes = { "I1", "I2", "I4", "I8", "F4", "F8" }
local qtypes = { "I1", }
local tests = {}
local optargs = { max_num_in_chunk = max_num_in_chunk } 
tests.t1 = function()
  for _, qtype in ipairs(qtypes) do 
    local tbl = {}
    local n =  max_num_in_chunk + 17
    for i = 1, n do 
      tbl[#tbl+1] = i
    end
    print("A MEM", lgutils.mem_used())
    optargs.name = "c1"
    local c1 = mk_col(tbl,  qtype, optargs):set_name("c1")
    assert(c1:max_num_in_chunk() == max_num_in_chunk)
    print("B MEM", lgutils.mem_used())
    local c2 = vshift(c1, 1, Scalar.new(0, qtype)):set_name("c2")
    print("C MEM", lgutils.mem_used())
    c2:eval()
    print("D MEM", lgutils.mem_used())
    --[[
    assert(c2:check())
    for i = 1, c1:num_elements() - 1 do 
      assert(c2:get1(i-1) == c1:get1(i))
    end
    assert(c1:num_elements() == c2:num_elements())
    c1:delete()
    print("E MEM", lgutils.mem_used())
    c2:delete()
    print("F MEM", lgutils.mem_used())
    --]]
    c1:delete()
    c2:delete()
    collectgarbage()
    print("test t1 passed for qtype " ..  qtype)
  end
  print("test t1 passed")
end
-- return tests
tests.t1()
collectgarbage()
print("MEM", lgutils.mem_used())
print("DSK", lgutils.dsk_used())
assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
