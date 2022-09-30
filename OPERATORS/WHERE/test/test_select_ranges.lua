-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local mk_col          = require 'Q/OPERATORS/MK_COL/lua/mk_col'
local select_ranges   = require 'Q/OPERATORS/WHERE/lua/select_ranges'
local cVector = require 'libvctr'
local lVector = require 'Q/RUNTIME/VCTRS/lua/lVector'

local tests = {}
tests.t1 = function ()
  local max_num_in_chunk = 8   -- Normally should be multiple of 64
  local optargs = { max_num_in_chunk = max_num_in_chunk }
  local tbl = {}
  local n = 8*max_num_in_chunk + 1 
  for i = 1, n do tbl[#tbl+1] = i end 
  for _, qtype in ipairs({"I1", "I2", "I4", "I8", "F4", "F8" }) do 
    local a = mk_col(tbl, qtype, optargs)
    local tlb = { 0,  8, 16, 32, 40, 64, }
    local tub = { 1, 10, 19, 36, 56, 65, }
    local lb = mk_col(tlb, "I4") 
    local ub = mk_col(tub, "I8")
    local c  = select_ranges(a, lb, ub)
    c:eval()
    local tbl = { 1, 9, 10, 17, 18, 19, 33, 34, 35, 36, 41, 42, 43, 44, 
45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 65, }
    local good_c = mk_col(tbl, qtype, optargs)
    assert(c:num_elements() == good_c:num_elements())
    for i = 1, c:num_elements() do 
      assert(c:get1(i-1) == good_c:get1(i-1))
    end
  end
  cVector:check_all(true, true)
  print("Test t1 succeeded")
end
tests.t1()
-- return tests
