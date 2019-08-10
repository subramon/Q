-- FUNCTIONAL 
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local qconsts = require 'Q/UTILS/lua/q_consts'

-- testcases for checking Q.min and Q.max returning correct index
local tests = {}

-- Q.min(), min value at index 0
tests.t1 = function()
  local mk_col_table = {}
  for i = 1, 65536 do
    mk_col_table[#mk_col_table+1] = ( i * 10 ) % qconsts.qtypes['I4'].max
  end
  -- placing min number at index 0
  local expected_min_value = 1
  local expected_min_idx = 1
  mk_col_table[expected_min_idx] = expected_min_value
  
  local c1 = Q.mk_col( mk_col_table, "I8")
  local value = Q.min(c1)
  value:eval()
  local min_value, no_of_trav, min_idx = value:value()
  assert(min_value:to_num() == expected_min_value)
  -- as indexing starts with 0, so idx-1
  assert(min_idx:to_num() == expected_min_idx-1 )
  print("Successfully completed test t1")
end

-- Q.min(), min value at chunk_size index
tests.t2 = function()
  local mk_col_table = {}
  for i = 1, 65536 do
    mk_col_table[#mk_col_table+1] = ( i * 10 ) % qconsts.qtypes['I4'].max
  end
  -- placing min number at index 65536
  local expected_min_value = 1
  local expected_min_idx = 65536
  mk_col_table[expected_min_idx] = expected_min_value
  
  local c1 = Q.mk_col( mk_col_table, "I8")
  local value = Q.min(c1)
  value:eval()
  local min_value, no_of_trav, min_idx = value:value()
  assert(min_value:to_num() == expected_min_value)
  -- as indexing starts with 0, so idx-1
  print(min_idx:to_num() , expected_min_idx-1)
  assert(min_idx:to_num() == expected_min_idx-1)
  print("Successfully completed test t2")
end

-- Q.min(), min value at chunk_size+1 index
tests.t3 = function()
  local mk_col_table = {}
  for i = 1, 65540 do
    mk_col_table[#mk_col_table+1] = ( i * 10 ) % qconsts.qtypes['I4'].max
  end
  -- placing min number at chunk_size+1 index
  local expected_min_value = 1
  local expected_min_idx = 65537
  mk_col_table[expected_min_idx] = expected_min_value
  
  local c1 = Q.mk_col( mk_col_table, "I8")
  local value = Q.min(c1)
  value:eval()
  local min_value, no_of_trav, min_idx = value:value()
  assert(min_value:to_num() == expected_min_value)
  -- as indexing starts with 0, so idx-1
  assert(min_idx:to_num() == expected_min_idx-1)
  print("Successfully completed test t3")
end

-- Q.min(), min value at chunk_size*2 index
tests.t4 = function()
  local mk_col_table = {}
  for i = 1, 65536*2 do
    mk_col_table[#mk_col_table+1] = ( i * 10 ) % qconsts.qtypes['I4'].max
  end
  -- placing min number at chunk_size+1 index
  local expected_min_value = 1
  local expected_min_idx = 65536*2
  mk_col_table[expected_min_idx] = expected_min_value
  
  local c1 = Q.mk_col( mk_col_table, "I8")
  local value = Q.min(c1)
  value:eval()
  local min_value, no_of_trav, min_idx = value:value()
  assert(min_value:to_num() == expected_min_value)
  -- as indexing starts with 0, so idx-1
  assert(min_idx:to_num() == expected_min_idx-1)
  print("Successfully completed test t4")
end


-- Q.max(), max value at index 0
tests.t5 = function()
  local mk_col_table = {}
  for i = 1, 65536 do
    mk_col_table[#mk_col_table+1] = ( i * 10 ) % qconsts.qtypes['I4'].max
  end
  -- placing max number at index 0
  local expected_max_value = 10000000
  local expected_max_idx = 1
  mk_col_table[expected_max_idx] = expected_max_value
  
  local c1 = Q.mk_col( mk_col_table, "I8")
  local value = Q.max(c1)
  value:eval()
  local max_value, no_of_trav, max_idx = value:value()
  assert(max_value:to_num() == expected_max_value)
  -- as indexing starts with 0, so idx-1
  assert(max_idx:to_num() == expected_max_idx-1 )
  print("Successfully completed test t5")
end

-- Q.max(), max value at chunk_size index
tests.t6 = function()
  local mk_col_table = {}
  local n = 2*qconsts.chunk_size + 109
  for i = 1, n do
    mk_col_table[#mk_col_table+1] = i
  end
  -- placing max number at chunk_size index
  local expected_max_value = 2*n + 1
  local expected_max_idx = n+1
  mk_col_table[n+1] = expected_max_value
  
  local c1 = Q.mk_col( mk_col_table, "I8")
  Q.print_csv(c1, { opfile = "_xx"})
  local max_value, no_of_trav, max_idx = Q.max(c1):eval()
  assert(max_value)
  assert(no_of_trav)
  assert(max_idx)
  print(max_value:to_num(), expected_max_value)
  assert(max_value:to_num() == expected_max_value)
  -- as indexing starts with 0, so idx-1
  print(max_idx:to_num(), expected_max_idx-1 )
  assert(max_idx:to_num() == expected_max_idx-1 )
  print("Successfully completed test t6")
end

-- Q.max(), max value at chunk_size+1 index
tests.t7 = function()
  local mk_col_table = {}
  for i = 1, 65540 do
    mk_col_table[#mk_col_table+1] = ( i * 10 ) % qconsts.qtypes['I4'].max
  end
  -- placing max number at chunk_size+1 index
  local expected_max_value = 10000000
  local expected_max_idx = 65537
  mk_col_table[expected_max_idx] = expected_max_value
  
  local c1 = Q.mk_col( mk_col_table, "I8")
  local value = Q.max(c1)
  value:eval()
  local max_value, no_of_trav, max_idx = value:value()
  assert(max_value:to_num() == expected_max_value)
  -- as indexing starts with 0, so idx-1
  assert(max_idx:to_num() == expected_max_idx-1 )
  print("Successfully completed test t7")
end

-- Q.max(), max value at chunk_size*2 index
tests.t8 = function()
  local mk_col_table = {}
  for i = 1, 65536*2 do
    mk_col_table[#mk_col_table+1] = ( i * 10 ) % qconsts.qtypes['I4'].max
  end
  -- placing max number at chunk_size*2 index
  local expected_max_value = 10000000
  local expected_max_idx = 65536*2
  mk_col_table[expected_max_idx] = expected_max_value
  
  local c1 = Q.mk_col( mk_col_table, "I8")
  local value = Q.max(c1)
  value:eval()
  local max_value, no_of_trav, max_idx = value:value()
  assert(max_value:to_num() == expected_max_value)
  -- as indexing starts with 0, so idx-1
  assert(max_idx:to_num() == expected_max_idx-1 )
  print("Successfully completed test t8")
end

-- occurence of max value is twice, should return first occurence index
tests.t9 = function()
  local mk_col_table = {100, 20, 30, 40, 50, 60, 70, 80, 90, 100}
  local expected_max_value = 100
  local expected_max_idx = 1
  
  local c1 = Q.mk_col( mk_col_table, "I4")
  local value = Q.max(c1)
  value:eval()
  local max_value, no_of_trav, max_idx = value:value()
  assert(max_value:to_num() == expected_max_value)
  -- as indexing starts with 0, so idx-1
  print(max_idx:to_num(), expected_max_idx-1)
  assert(max_idx:to_num() == expected_max_idx-1 )
  print("Successfully completed test t9")
end

-- occurence of max value is twice, should return first occurence index
tests.t10 = function()
  local mk_col_table = {100, 20, 30, 40, 50, 60, 70, 100, 90, 80}
  local expected_max_value = 100
  local expected_max_idx = 1

  local c1 = Q.mk_col( mk_col_table, "I4")
  local value = Q.max(c1)
  value:eval()
  local max_value, no_of_trav, max_idx = value:value()
  assert(max_value:to_num() == expected_max_value)
  -- as indexing starts with 0, so idx-1
  print(max_idx:to_num(), expected_max_idx-1)
  assert(max_idx:to_num() == expected_max_idx-1 )
  print("Successfully completed test t10")
end

return tests
