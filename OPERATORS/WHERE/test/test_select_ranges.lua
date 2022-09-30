-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local mk_col   = require 'Q/OPERATORS/MK_COL/mk_col'
local select_ranges   = require 'Q/OPERATORS/WHERE/select_ranges'
local cVector  = require 'libvctr'
local lVector  = require 'Q/RUNTIME/VCTRS/lua/lVector'

local tests = {}
tests.t1 = function ()
  local max_num_in_chunk = 64 
  local optargs = { max_num_in_chunk = max_num_in_chunk }
  local tbl = {}
  local n = max_num_in_chunk + 1 
  for i = 1, n do tbl[#tbl+1] = i end 
  for _, qtype in ipairs({"I1", "I2", "I4", "I8", "F4", "F8" }) do 
    local a = Q.mk_col(tbl, qtype, optargs)
    local tlb = { 0, 8, 16, 32, 40, 48, 56, 64}
    local tub = {}
    for k, v in ipairs(tlb) do tub[k] = v + 4 end 
    local lb = Q.mk_col(tlb, "I4") 
    local ub = Q.mk_col(tub, "I8")
    local c = Q.select_ranges(a, lb, ub)
    -- TODO Checks on C 
  end
  cVector:check_all(true, true)
  print("Test t1 succeeded")
end
tests.t1()
-- return tests
