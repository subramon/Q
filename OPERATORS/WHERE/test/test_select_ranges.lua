-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local mk_col          = require 'Q/OPERATORS/MK_COL/lua/mk_col'
local T   = require 'Q/OPERATORS/WHERE/lua/select_ranges'
assert(type(T) == "table")
local select_ranges = T.select_ranges
assert(type(select_ranges) == "function")
local cVector = require 'libvctr'
local Scalar  = require 'libsclr'
local lVector = require 'Q/RUNTIME/VCTRS/lua/lVector'
local lgutils = require 'liblgutils'

local tests = {}
tests.t1 = function ()
  assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
  local max_num_in_chunk = 64   -- Normally should be multiple of 64
  local optargs = { max_num_in_chunk = max_num_in_chunk }
  local tbl = {}
  local n = max_num_in_chunk +  7
  for i = 1, n do tbl[#tbl+1] = i end 
  local qtypes =  {"I1", "I2", "I4", "I8", "F4", "F8" } 
  for _, qtype in ipairs(qtypes) do 
    local a = mk_col(tbl, qtype, optargs):set_name("a")
    local tlb = { 0,  8, 16, 32, 40, 64, }
    local tub = { 1, 10, 19, 36, 56, 65, }
    local lb = mk_col(tlb, "I4") 
    local ub = mk_col(tub, "I8")
    local c  = select_ranges(a, lb, ub, optargs):set_name("c")
    c:eval()
    local tbl = { 1, 9, 10, 17, 18, 19, 33, 34, 35, 36, 41, 42, 43, 44, 
45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 65, }
    local good_c = mk_col(tbl, qtype, optargs)
    assert(c:num_elements() == good_c:num_elements())
    for i = 1, c:num_elements() do 
      assert(c:get1(i-1) == good_c:get1(i-1))
    end
    cVector:check_all(true, true)
    a:delete()
    c:delete()
    good_c:delete()
    lb:delete()
    ub:delete()
    assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
  end
  cVector:check_all(true, true)
  print("Test t1 succeeded")
end
--[[ TODO nn not implemented
  -- testing select_ranges with nulls
tests.t2 = function ()
  local max_num_in_chunk = 64 
  local optargs = { max_num_in_chunk = max_num_in_chunk }
  local n = max_num_in_chunk + 1 

  -- make data for nn column
  local nn_tbl = {}
  for i = 1, n do 
    if ( ( i % 2 ) == 0 ) then nn_tbl[i] = true else nn_tbl[i] = false end
  end
  -- make data for actual column 
  local tbl = {}
  for i = 1, n do tbl[#tbl+1] = i+1 end
  -- make data for output column
  local good_tbl = { 0, 0, 11, 0, 19, 0, 0, 35, 0, 37, 0, 43, 0, 45, 0,
  47, 0, 49, 0, 51, 0, 53, 0, 55, 0, 57, 0, }
  -- make data for output nn column
  local good_nn_tbl = { false, false, true, false, true, false, false, 
    true, false, true, false, true, false, true, false, true, false, 
    true, false, true, false, true, false, true, false, true, false, }
  assert(#good_nn_tbl == #good_tbl)

  for _, qtype in ipairs({"I1", "I2", "I4", "I8", "F4", "F8" }) do 
    local num_in_c = 0
    optargs.name = "a"
    local a = mk_col(tbl, qtype, optargs, nn_tbl)
    optargs.name = nil
    assert(a:name() == "a")
    assert(a:has_nulls())
    local tlb = { 0,  8, 16, 32, 40, 64, }
    local tub = { 1, 10, 19, 36, 56, 65, }
    for i = 1, #tlb do 
      num_in_c = num_in_c + (tub[i] - tlb[i])
    end
    local lb = mk_col(tlb, "I4"):set_name("lb")
    local ub = mk_col(tub, "I8"):set_name("ub")
    local c  = select_ranges(a, lb, ub):eval()
    assert(c:num_elements() == num_in_c)
    for i = 1, num_in_c do 
      local v, nn_v = c:get1(i-1)
      assert(type(v) == "Scalar")
      assert(type(nn_v) == "Scalar")
      assert(v:qtype() == qtype)
      assert(nn_v:qtype() == "BL")
      local chk_nn_v = Scalar.new(good_nn_tbl[i], "BL")
      assert(nn_v == chk_nn_v) 
      if ( nn_v == Scalar.new(true, "BL") ) then 
        assert(v:to_num() == good_tbl[i])
      end
    end
    a:delete()
    c:delete()
    lb:delete()
    ub:delete()
  end
  cVector:check_all(true, true)
  print("Test t2 succeeded")
end
--]]
-- t3 tests for case when we input vector size exceeds 1 chunk
tests.t3 = function ()
  assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
  local max_num_in_chunk = 64   -- Normally should be multiple of 64
  local optargs = { max_num_in_chunk = max_num_in_chunk }
  local tbl = {}
  local n = max_num_in_chunk +  7
  for i = 1, n do tbl[#tbl+1] = i end 
  local qtypes =  {"I1", "I2", "I4", "I8", "F4", "F8" } -- TODO 
  local qtypes =  {"I4", }
  for _, qtype in ipairs(qtypes) do 
    local a = mk_col(tbl, qtype, optargs):set_name("a")
    local tlb = { 0,  0, 0, 64, 64, 0, }
    local tub = { 16, 16, 16, 67, 67, 16, }
    local lb = mk_col(tlb, "I4") 
    local ub = mk_col(tub, "I8")
    local c  = select_ranges(a, lb, ub, optargs):set_name("c")
    local chk_nc = 0
    for k, v in ipairs(tlb) do
      chk_nc = chk_nc + (tub[k] - tlb[k])
    end
    c:eval()
    assert(c:num_elements() == chk_nc)
    cVector:check_all(true, true)
    a:delete()
    c:delete()
    lb:delete()
    ub:delete()
    assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
  end
  cVector:check_all(true, true)
  print("Test t3 succeeded")
end
tests.t1()
-- TODO tests.t2()
tests.t3()
collectgarbage()
-- return tests
