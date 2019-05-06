-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local c_to_txt = require 'Q/UTILS/lua/C_to_txt'
local qconsts = require 'Q/UTILS/lua/q_consts'
local utils = require 'Q/UTILS/lua/utils'
local plpath  = require 'pl.path'
local plfile  = require 'pl.file'
local path_to_here = os.getenv("Q_SRC_ROOT") .. "/OPERATORS/UNIQUE/test/"
assert(plpath.isdir(path_to_here))

local chunk_size = qconsts.chunk_size

-- validating unique operator to return unique values from input vector
-- FUNCTIONAL
-- where num_elements are less than chunk_size
local tests = {}
tests.t1 = function ()
  local out_table = {1, 2, 3, 4, 5}
  local cnt_table = {1, 2, 4, 1, 1}
  local a = Q.mk_col({1, 2, 2, 3, 3, 3, 3, 4, 5}, "I4")
  local c, d = Q.unique(a)
  c:eval()
  assert(d:is_eov() == true)
  assert(c:length() == #out_table)
  assert(d:length() == #cnt_table)

  for i = 1, c:length() do
    local value = c_to_txt(c, i)
    assert(value == out_table[i])

    value = c_to_txt(d, i)
    assert(value == cnt_table[i])
  end
  -- local opt_args = { opfile = "" }
  -- Q.print_csv(c, opt_args)
  print("Test t1 succeeded")
end

-- validating unique to return unique values from input vector
-- where num_elements are greater than chunk_size 
tests.t2 = function ()
  local out_table = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
  local period = 10
  local cnt_1 = math.ceil((chunk_size*4+2)/period)
  local cnt_2 = math.floor((chunk_size*4+2)/period)
  local cnt_1_occurance = ((chunk_size*4+2) % period)
  local cnt_table = {}
  for i = 1, cnt_1_occurance do
    cnt_table[#cnt_table+1] = cnt_1
  end
  for i = 1, (period-cnt_1_occurance) do
    cnt_table[#cnt_table+1] = cnt_2
  end
  local input = Q.period({ len = chunk_size*4+2, start = 1, by = 1, period = period, qtype = "I4"}):persist(true):eval()
   
  local input_col = Q.sort(input, "asc")
  -- Q.print_csv(input_col, {opfile = path_to_here .. "input_file_t2.csv"})
  local c, d = Q.unique(input_col)
  c:eval()
  for i = 1, c:length() do
    local value = c_to_txt(c, i)
    -- print(value, out_table[i])
    assert(value == out_table[i])
    value = c_to_txt(d, i)
    assert(value == cnt_table[i])
  end
  print("Test t2 succeeded")
end

-- validating unique to return unique values from input vector
-- where num_elements are greater than chunk_size
-- [ 1 ... chunk_size ] [ chunk_size+1 ... chunk_size*2 ]
-- [ 1, 1, .. 2, 2, 3 ] [ 3, 3, 3, 3, 3, 3, 3, 3, ... 3 ]
tests.t3 = function ()
  local expected_values = {1, 2, 3}
  local cnt_1 = (qconsts.chunk_size/2)-1
  local cnt_2 = qconsts.chunk_size/2
  local cnt_table = {cnt_1, cnt_2, qconsts.chunk_size+1}
  local chunk_size = qconsts.chunk_size
  
  local input_tbl = {}
  for i = 1, chunk_size-1 do
    if i % 2 == 0 then
      input_tbl[i] = 1
    else
      input_tbl[i] = 2
    end
  end

  for i = chunk_size+1, chunk_size*2 do
    input_tbl[i] = 3
  end
  input_tbl[chunk_size] = 3
  local input_col = Q.mk_col(input_tbl, "I1")
  input_col = Q.sort(input_col, "asc"):eval()
  Q.print_csv(input_col, {opfile = path_to_here .. "input_file_t3.csv"})
  local c, d = Q.unique(input_col)
  c:eval()
  assert(c:length() == #expected_values)
  for i = 1, c:length() do
    local value = c_to_txt(c, i)
    -- print(value, expected_values[i])
    assert(value == expected_values[i])
    value = c_to_txt(d, i)
    assert(value == cnt_table[i])
  end
  Q.print_csv(c)
  plfile.delete(path_to_here .. "/input_file_t3.csv") 
  print("Test t3 succeeded")
end

-- validating unique to return unique values from input vector
-- where num_elements are greater than chunk_size 
-- [ 1 ... chunk_size ] [ chunk_size+1 ... (chunk_size*2-chunk_size/2) ]
-- [ 1, 1, .. 2, 2, 3 ] [ 3, 3 ... 3 (half the length of second chunk)]
tests.t4 = function ()
  local expected_values = {1, 2, 3}
  local cnt_1 = qconsts.chunk_size/2
  local cnt_table = {cnt_1-1 , cnt_1, cnt_1+1}
  local chunk_size = qconsts.chunk_size
  
  local input_tbl = {}
  for i = 1, chunk_size-1 do
    if i % 2 == 0 then
      input_tbl[i] = 1
    else
      input_tbl[i] = 2
    end
  end

  for i = chunk_size+1, (chunk_size*2)-(chunk_size/2) do
    input_tbl[i] = 3
  end
  input_tbl[chunk_size] = 3
  local input_col = Q.mk_col(input_tbl, "I1")
  input_col = Q.sort(input_col, "asc"):eval()
  Q.print_csv(input_col, {opfile = path_to_here .. "input_file_t4.csv"})
  local c, d = Q.unique(input_col)
  c:eval()
  assert(c:length() == #expected_values)
  for i = 1, c:length() do
    local value = c_to_txt(c, i)
    -- print(value, expected_values[i])
    assert(value == expected_values[i])
    value = c_to_txt(d, i)
    assert(value == cnt_table[i])
  end
  Q.print_csv(c)
  plfile.delete(path_to_here .. "/input_file_t4.csv") 
  print("Test t4 succeeded")
end
 
-- validating unique to return unique values from input vector
-- where num_elements are greater than chunk_size
-- [ 1 ... chunk_size ] [ chunk_size+1 ... chunk_size*2 ]
-- [ 1, 1, .. 2, 2, 3 ] [ 3, 3, 4, 4, ... 5, 5 ]
tests.t5 = function ()
  local expected_values = {1, 2, 3, 4, 5}
  local chunk_size = qconsts.chunk_size
  local cnt_table = {(chunk_size/2)-1, chunk_size/2, 3, (chunk_size/2)-1, (chunk_size/2)-1}
  
  local input_tbl = {}
  for i = 1, chunk_size-1 do
    if i % 2 == 0 then
      input_tbl[i] = 1
    else
      input_tbl[i] = 2
    end
  end
  input_tbl[chunk_size]   = 3
  input_tbl[chunk_size+1] = 3
  input_tbl[chunk_size+2] = 3
  
  for i = chunk_size+3, chunk_size*2 do
    if i % 2 == 0 then
      input_tbl[i] = 4
    else
      input_tbl[i] = 5
    end
  end

  local input_col = Q.mk_col(input_tbl, "I1")
  input_col = Q.sort(input_col, "asc"):eval()
  Q.print_csv(input_col, {opfile = path_to_here .. "input_file_t5.csv"})
  local c, d = Q.unique(input_col)
  c:eval()
  assert(c:length() == #expected_values)
  for i = 1, c:length() do
    local value = c_to_txt(c, i)
    -- print(value, expected_values[i])
    assert(value == expected_values[i])
    value = c_to_txt(d, i)
    assert(value == cnt_table[i])
  end
  Q.print_csv(c)
  plfile.delete(path_to_here .. "/input_file_t5.csv") 
  print("Test t5 succeeded")
end

-- validating unique to return unique values from input vector
-- where num_elements are greater than chunk_size
-- [ 1, 1, .. 2, 2, 3 ] [ 3, 3, 3, 3 ... 3 ] [ 3, 3, 4, 4, ... 5, 5 ]
tests.t6 = function ()
  local expected_values = {1, 2, 3, 4, 5}
  local cnt_1 = (qconsts.chunk_size/2)-1
  local cnt_2 = (qconsts.chunk_size/2)
  local cnt_3 = qconsts.chunk_size+3
  local cnt_table = {cnt_1, cnt_2, cnt_3, cnt_1, cnt_1}
  local chunk_size = qconsts.chunk_size
  
  local input_tbl = {}
  for i = 1, chunk_size-1 do
    if i % 2 == 0 then
      input_tbl[i] = 1
    else
      input_tbl[i] = 2
    end
  end
  
  input_tbl[chunk_size]   = 3
  
  for i = chunk_size+1, chunk_size*2 do
    input_tbl[i] = 3
  end
  
  input_tbl[chunk_size*2+1]   = 3
  input_tbl[chunk_size*2+2]   = 3
  
  for i = (chunk_size*2)+3, chunk_size*3 do
    if i % 2 == 0 then
      input_tbl[i] = 4
    else
      input_tbl[i] = 5
    end
  end

  local input_col = Q.mk_col(input_tbl, "I1")
  input_col = Q.sort(input_col, "asc"):eval()
  Q.print_csv(input_col, {opfile = path_to_here .. "input_file_t6.csv"})
  local c,d = Q.unique(input_col)
  c:eval()
  assert(c:length() == #expected_values)
  for i = 1, c:length() do
    local value = c_to_txt(c, i)
    -- print(value, expected_values[i])
    assert(value == expected_values[i])
    value = c_to_txt(d, i)
    assert(value == cnt_table[i])
  end
  Q.print_csv(c)
  plfile.delete(path_to_here .. "/input_file_t6.csv") 
  print("Test t6 succeeded")
end

-- validating unique to return unique values from input vector
-- where num_elements > chunk_size and
-- no_of_unique values > chunk_size
-- [ 1, 2, ... 65534, 65535, 65536 ] [ 65536, 65536, 65537, 65537 ... 65537 ] 
tests.t7 = function ()
  local cnt_table = {}
  
  local no_of_unq_values = chunk_size + 1
  local chunk_size = qconsts.chunk_size
  
  local input_tbl = {}
  for i = 1, chunk_size do
    input_tbl[i] = i
    cnt_table[i] = 1
  end
  cnt_table[chunk_size] = 3
  for i = chunk_size+1, chunk_size*2 do
    if i == chunk_size+1 or i == chunk_size+2 then
      input_tbl[i] = chunk_size
    else
      input_tbl[i] = chunk_size + 1
    end
  end
  cnt_table[chunk_size + 1] = chunk_size - 2
  local input_col = Q.mk_col(input_tbl, "I4")
  local c,d = Q.unique(input_col)
  c:eval()
  assert(c:length() == no_of_unq_values)
  for i = 1, no_of_unq_values do
    local value = c_to_txt(c, i)
    -- print(value)
    assert(value == i)
    value = c_to_txt(d, i)
    assert(value, cnt_table[i])
  end
  Q.print_csv(c, { opfile = path_to_here .. "output_t7.csv"} )
  plfile.delete(path_to_here .. "/output_t7.csv") 
  print("Test t7 succeeded")
end

-- validating unique to return unique values from input vector
-- where num_elements > chunk_size and
-- no_of_unique values > chunk_size
-- [ 1, 2, ... 65534, 65535, 65536 ] [ 65536, ... 65536, 65536 ] ..
-- [ 65536, 65536, 65537, 65537 ... 65537 ] 
tests.t8 = function ()
  local cnt_table = {}
  local no_of_unq_values = chunk_size + 1
  local chunk_size = qconsts.chunk_size
  
  local input_tbl = {}
  for i = 1, chunk_size do
    input_tbl[i] = i
    cnt_table[i] = 1
  end
  cnt_table[chunk_size] = chunk_size + 3
  for i = chunk_size+1, chunk_size*2 do
    input_tbl[i] = chunk_size
  end
  
  for i = chunk_size*2+1, chunk_size*3 do
    if i == chunk_size*2+1 or i == chunk_size*2+2 then
      input_tbl[i] = chunk_size
    else
      input_tbl[i] = chunk_size + 1
    end
  end
  cnt_table[chunk_size+1] = chunk_size - 2
  local input_col = Q.mk_col(input_tbl, "I4")
  local c, d = Q.unique(input_col)
  c:eval()
  assert(c:length() == no_of_unq_values)
  for i = 1, no_of_unq_values do
    local value = c_to_txt(c, i)
      -- print(value)
      assert(value == i)
      value = c_to_txt(d, i)
      assert(value == cnt_table[i])
  end
  Q.print_csv(c, { opfile = path_to_here .. "output_t8.csv"} )
  plfile.delete(path_to_here .. "/output_t8.csv") 
  print("Test t8 succeeded")
end

-- validating unique to return unique values from input vector
-- where num_elements are greater than chunk_size
-- all elements are unique
tests.t9 = function ()
  local cnt_table = {}
  local num_elements = qconsts.chunk_size + 100
  for i = 1, num_elements do
    cnt_table[i] = 1
  end
  local input_col = Q.seq( {start = 1, by = 1, qtype = "I4", len = num_elements} ):eval()
  Q.print_csv(input_col, {opfile = path_to_here .. "input_file_t9.csv"})
  local c, d = Q.unique(input_col)
  c:eval()
  assert(c:length() == num_elements)
  for i = 1, c:length() do
    local value = c_to_txt(c, i)
    -- print(value, i)
    assert(value == i)
    value = c_to_txt(d, i)
    assert(value, cnt_table[i])
  end
  -- Q.print_csv(c)
  plfile.delete(path_to_here .. "/input_file_t9.csv") 
  print("Test t9 succeeded")
end

-- validating unique to return unique values from input vector
-- where num_elements are greater than chunk_size
-- all elements are same
tests.t10 = function ()
  local num_elements = qconsts.chunk_size + 100
  local input_col = Q.const({ val = 1, len = num_elements, qtype = "I4"}):eval()
  Q.print_csv(input_col, {opfile = path_to_here .. "input_file_t10.csv"})
  local c, d = Q.unique(input_col)
  c:eval()
  assert(c:length() == 1)
  for i = 1, c:length() do
    local value = c_to_txt(c, i)
    -- print(value, i)
    assert(value == i)
    value = c_to_txt(d, i)
  end
  -- Q.print_csv(c)
  plfile.delete(path_to_here .. "/input_file_t10.csv") 
  print("Test t10 succeeded")
end

-- validating unique to return unique values from input vector
-- where num_elements are greater than chunk_size
-- random value n on n(some collisions not too many)
-- as sorting 'asc' so validating using is_next(geq)
tests.t11 = function ()
  local num_elements = qconsts.chunk_size * 2
  local input_col = Q.rand( { lb = 1, ub = 80000, qtype = "I4", len = num_elements }):eval()
  input_col =  Q.sort(input_col, "asc")
  Q.print_csv(input_col, {opfile = path_to_here .. "input_file_t11.csv"})
  local c = Q.unique(input_col):eval()
  print(c:length())
  assert(c:length())
  local z = Q.is_next(c, "geq")
  assert(type(z) == "Reducer")
  local a, b = z:eval()
  assert(type(a) == "boolean")
  assert(type(b) == "number")
  assert(a == true)
  -- Q.print_csv(c)
  plfile.delete(path_to_here .. "/input_file_t11.csv") 
  print("Test t11 succeeded")
end

-- validating unique to return unique values from input vector
-- internally should set 'sort_order' metadata as 'desc'
tests.t12 = function ()
  local expected_output = { 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 }
  local cnt_table = { 2, 3, 1, 2, 3, 1, 1, 1, 1, 1}
  local input_col = Q.mk_col( { 10, 10, 9, 9, 9, 8, 7, 7, 6, 6, 6, 5, 4, 3, 2, 1}, "I1")
  local c, d = Q.unique(input_col)
  c:eval()
  assert(c:length() == #expected_output )
  for i = 1, #expected_output do
    local value = c_to_txt(c, i)
    -- print(value, expected_output[i])
    assert(value == expected_output[i])
    value = c_to_txt(d, i)
    assert(value, cnt_table[i])
  end
  -- Q.print_csv(c)
  print("Test t12 succeeded")
end

-- validating unique
-- input vector is nort sorted
-- internally should sort(by creating a clone of input vector) 
-- and should set 'sort_order' metadata to default as 'asc'
tests.t13 = function ()
  local expected_output = { 1,2,3,4,5,6,7,8,9,10 }
  local cnt_table = { 1,1,1,1,1,1,1,1,1,1 }
  local input_col = Q.mk_col( { 10, 9, 5, 2, 7, 6, 8, 4, 1, 3}, "I1")
  local c, d = Q.unique(input_col)
  c:eval()
  assert(c:length() == #expected_output )
  assert(d:length() == #cnt_table)
  for i = 1, #expected_output do
    local value = c_to_txt(c, i)
    -- print(value, expected_output[i])
    assert(value == expected_output[i])
    value = c_to_txt(d, i)
    assert(value == cnt_table[i])
  end
  Q.print_csv(c)
  -- Q.print_csv(input_col)
  print("Test t13 succeeded")
end

-- Q.unique() returns 2 vectors (unique_vec and count_vec)
-- testing: a call to count_vec:eval() should also evaluate unique_vec
tests.t14 = function()
  local expected_output = { 1,2,3,4,5 }
  local cnt_table = { 1,2,3,4,5 }
  local input_col = Q.mk_col( { 1,2,2,3,3,3,4,4,4,4,5,5,5,5,5 }, "I1")
  local unique_vec, count_vec = Q.unique(input_col)
  -- calling eval() for count_vec
  count_vec:eval()
  -- checking, unique_vec should also be evaluated
  assert(unique_vec:num_elements() == #expected_output)
  assert(unique_vec:is_eov() == true)
  for i = 1, #expected_output do
    local value = c_to_txt(unique_vec, i)
    -- print(value, expected_output[i])
    assert(value == expected_output[i])
    value = c_to_txt(count_vec, i)
    assert(value == cnt_table[i])
  end
  Q.print_csv(unique_vec)
  print("Test t14 succeeded")
end

tests.t15 = function ()
  local out_table = {10, 20, 30}
  local cnt_table = {4, 2, 3}
  local sum_table = {2, 1, 3}
  local a = Q.mk_col({10, 10, 10, 10, 20, 20, 30, 30, 30}, "I4")
  local a_B1 = Q.mk_col({1, 0, 1, 0, 1, 0, 1, 1, 1}, "B1")
  local c, d, e = Q.unique(a, a_B1)
  c:eval()
  assert(d:is_eov() == true)
  assert(c:length() == #out_table)
  assert(d:length() == #cnt_table)
  Q.print_csv({c, d, e})
  for i = 1, c:length() do
    local value = c_to_txt(c, i)
    assert(value == out_table[i])

    value = c_to_txt(d, i)
    assert(value == cnt_table[i])

    value = c_to_txt(e, i)
    assert(value == sum_table[i])
  end
  -- local opt_args = { opfile = "" }
  -- Q.print_csv(c, opt_args)
  print("Test t15 succeeded")
end

tests.t16 = function()
  local num_elements = qconsts.chunk_size * 2 + 105
  -- generating value vector
  local input_col = Q.period( { start = 0, by = 1, period = 5, qtype = "I4", len = num_elements }):eval()
  -- sorting value vector for serving it to unique operator
  input_col =  Q.sort(input_col, "asc")
  local B1_tbl = {}
  for i = 1, num_elements do
    B1_tbl[#B1_tbl + 1] = i % 2
  end
  local B1_vec = Q.mk_col(B1_tbl, "B1")
  -- calling unique(value_vec, B1_vec) returns 3 vectors(unq_vec, cnt_vec, sum_vec)
  local unq, cnt, sum = Q.unique(input_col, B1_vec)
  unq:eval()
  -- checking for valid length returned
  assert(unq:length() == 5 and cnt:length() == 5 and sum:length() == 5)
  
  -- storing the index of each unique value
  local index_tbl = {}
  for i = 1, unq:length() do
    index_tbl[#index_tbl + 1] = Q.index(input_col, i)
  end
  
  -- getting sum of 1's for each unique value
  local sum_values = 0
  local sum_of_1 = {}
  for i = 1, num_elements do
    if utils.table_find(index_tbl, i-1) then
      sum_of_1[#sum_of_1 +1] = sum_values
      sum_values = 0
    end
    sum_values = sum_values + B1_vec:get_one(i-1):to_num()
  end
  sum_of_1[#sum_of_1 +1] = sum_values
  
  -- validating sum_vec returned by Q.unique()
  for i=1, unq:length() do
    assert(sum:get_one(i-1):to_num() == sum_of_1[i])
  end
  Q.print_csv({unq, cnt, sum})
  print("Test t16 succeeded")
end

return tests
