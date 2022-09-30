-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local vshift = require 'Q/OPERATORS/F1S1OPF2/lua/vshift'
local mk_col = require 'Q/OPERATORS/MK_COL/lua/mk_col'
local Scalar = require 'libsclr'
local qcfg   = require 'Q/UTILS/lua/qcfg'

local max_num_in_chunk = 8 
local qtypes = { "I1", "I2", "I4", "I8", "F4", "F8" }
local qtypes = { "I4" } 
local tests = {}
local optargs = { max_num_in_chunk = max_num_in_chunk } 
tests.t1 = function()
  for _, qtype in ipairs(qtypes) do 
    local tbl = {}
    local n = 2 * max_num_in_chunk + 3
    print("n = ", n)
    for i = 1, n do 
      tbl[#tbl+1] = i
    end
    local c1 = mk_col(tbl,  qtype, optargs)
    assert(c1:max_num_in_chunk() == max_num_in_chunk)
    local c2 = vshift(c1, 1, Scalar.new(0, qtype))
    c2:eval()
    c2:pr()
  end
  print("test t1 passed")
end
-- return tests
tests.t1()
