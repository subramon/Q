-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local cVector = require 'libvctr'
local qconsts = require 'Q/UTILS/lua/q_consts'

local q_src_root = os.getenv("Q_SRC_ROOT")
local so_dir_path = q_src_root .. "/OPERATORS/SORT2/src/"
local chunk_size = cVector.chunk_size()

local tests = {}

-- lua test to check the working of SORT2 in asc order
tests.t1 = function ()
  local expected_drag_result = {40, 30, 20, 10, 50 ,60, 70, 80, 90, 100}
  local expected_input_col = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
  
  local qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  for _, qtype in ipairs(qtypes) do 
    local qtype = "I4"
    local input_col = Q.mk_col({10, 9, 8, 7, 6, 5, 4, 3, 2, 1}, "I4")
    local input_drag_col = Q.mk_col({100, 90, 80, 70, 60, 50, 10, 20, 30, 40}, "F4")
  
    local status = Q.sort2(input_col, input_drag_col, "asc")
    -- Q.print_csv({input_col, input_drag_col}, { impl = 'C' })
  
    -- Validate the result
    for i = 1, input_drag_col:length() do
      -- print(input_col:get1(i-1):to_num(), input_drag_col:get1(i-1):to_num())
      assert(input_drag_col:get1(i-1):to_num() == expected_drag_result[i])
      assert(input_col:get1(i-1):to_num() == expected_input_col[i])
    end
  end
  
  print("Test t1 succeeded")
end

-- lua test to check the working of SORT2 in dsc order
tests.t2 = function ()
  local expected_drag_result = {30, 40, 20, 10, 60 , 50, 80, 70, 90, 100}
  local expected_input_col = {10, 9, 8, 7, 6, 5, 4, 3, 2, 1}

  local qtype = "I4"
  local input_col = Q.mk_col({1, 2, 4, 3, 6, 5, 7, 8, 10, 9}, "I4")
  local input_drag_col = Q.mk_col({100, 90, 80, 70, 60, 50, 10, 20, 30, 40}, "I4")

  local status = Q.sort2(input_col, input_drag_col, "dsc")

  -- Validate the result
  for i = 1, input_drag_col:length() do
    print(input_col:get1(i-1):to_num(), input_drag_col:get1(i-1):to_num())
    assert(input_drag_col:get1(i-1):to_num() == expected_drag_result[i])
    assert(input_col:get1(i-1):to_num() == expected_input_col[i])
  end

  print("Test t2 succeeded")
end


-- lua test to check the working of SORT2 in asc order
tests.t3 = function ()
  local expected_drag_result = {40, 30, 20, 10, 50, 60, 70, 80, 90, 100}
  local expected_input_col = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}

  local input_col = Q.mk_col({10, 9, 8, 7, 6, 5, 4, 3, 2, 1}, "I1")
  local input_drag_col = Q.mk_col({100, 90, 80, 70, 60, 50, 10, 20, 30, 40}, "I4")

  local status = Q.sort2(input_col, input_drag_col, "asc")
  assert(input_col:qtype() == "I1")
  assert(input_drag_col:qtype() == "I4")
  -- Validate the result
  for i = 1, input_drag_col:length() do
    print(input_col:get1(i-1):to_num(), input_drag_col:get1(i-1):to_num())
    assert(input_col:get1(i-1):to_num() == expected_input_col[i])
    assert(input_drag_col:get1(i-1):to_num() == expected_drag_result[i])
  end

  print("Test t3 succeeded")
end

-- following testcases are:
-- different qtype of input1 and input2 should work for sort2

-- lua test to check the working of SORT2 in dsc order
-- test for num_elements > chunk_size 
tests.t4 = function ()
  
  local input_tbl_1 = {}
  local input_tbl_2 = {}
  for i = 1, chunk_size + 100 do
    input_tbl_1[#input_tbl_1 +1] = i
    input_tbl_2[#input_tbl_2 +1] = i + 7
  end
  
  local input_col = Q.mk_col(input_tbl_1, "I4")
  local input_drag_col = Q.mk_col(input_tbl_2, "I8")

  local status = Q.sort2(input_col, input_drag_col, "dsc")
  assert(input_col:qtype() == "I4" and input_drag_col:qtype() == "I8")
  -- Validate the result
  for i = 1, input_drag_col:length() do
    --print(input_col:get1(i-1):to_num(), input_drag_col:get1(i-1):to_num())
    assert(input_drag_col:get1(i-1):to_num() == input_col:get1(i-1):to_num() +7 )
  end
  
  print("Test t4 succeeded")
end

-- lua test to check the working of SORT2 in dsc order
-- test for num_elements < chunk_size 
tests.t5 = function ()
  
  local input_tbl_1 = {}
  local input_tbl_2 = {}
  for i = 1, chunk_size - 100 do
    input_tbl_1[#input_tbl_1 +1] = i
    input_tbl_2[#input_tbl_2 +1] = i + 7
  end
  
  local input_col = Q.mk_col(input_tbl_1, "I8")
  local input_drag_col = Q.mk_col(input_tbl_2, "I4")

  local status = Q.sort2(input_col, input_drag_col, "dsc")
  assert(input_col:qtype() == "I8" and input_drag_col:qtype() == "I4")
  -- Validate the result
  for i = 1, input_drag_col:length() do
    --print(input_col:get1(i-1):to_num(), input_drag_col:get1(i-1):to_num())
    assert(input_drag_col:get1(i-1):to_num() == input_col:get1(i-1):to_num() +7 )
  end
  
  print("Test t5 succeeded")
end

-- lua test to check the working of SORT2 in dsc order
-- test for num_elements == chunk_size 
tests.t6 = function ()
  
  local input_tbl_1 = {}
  local input_tbl_2 = {}
  for i = 1, chunk_size do
    input_tbl_1[#input_tbl_1 +1] = i
    input_tbl_2[#input_tbl_2 +1] = i + 7
  end
  
  local input_col = Q.mk_col(input_tbl_1, "I8")
  local input_drag_col = Q.mk_col(input_tbl_2, "F8")

  local status = Q.sort2(input_col, input_drag_col, "dsc")
  assert(input_col:qtype() == "I8" and input_drag_col:qtype() == "F8")
  -- Validate the result
  for i = 1, input_drag_col:length() do
    --print(input_col:get1(i-1):to_num(), input_drag_col:get1(i-1):to_num())
    assert(input_drag_col:get1(i-1):to_num() == input_col:get1(i-1):to_num() +7 )
  end
  
  print("Test t6 succeeded")
end
return tests
-- tests.t1()
