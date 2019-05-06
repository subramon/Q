-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local c_to_txt = require 'Q/UTILS/lua/C_to_txt'

local tests = {}

-- Q.indices() to return indices of all 1's from B1 input vector
tests.t1 = function ()
  local tbl = {1, 0, 0, 1, 0, 1, 0, 0}
  local b = Q.mk_col(tbl, "B1")
  local out_table = {0, 3, 5}
  local c = Q.index(b):eval()
  assert(c:length() == Q.sum(b):eval():to_num(), "Length Mismatch")
  assert(c:length() == #out_table)
  for i = 1, c:length() do
    local value = c_to_txt(c, i)
    assert(value == out_table[i])
  end
  print("Test t1 succeeded")
end

-- checking indices() operator for num_elements > chunk_size
tests.t2 = function ()
  local tbl = {}
  for i=1, 65536*5 do
    if i%2 == 0 then
      tbl[#tbl+1] = 0 
    else
      tbl[#tbl+1] = 1
    end
  end
  local b = Q.mk_col(tbl, "B1")
  local c = Q.index(b):eval()
  assert(c:length() == Q.sum(b):eval():to_num(), "Length Mismatch")
  for i = 1, c:length() do
    local value = c_to_txt(c, i)
    assert(value == (i-1)*2 )
  end
  -- Q.print_csv(c, { filter = { lb = 163838, ub =163840 } })
  print("Test t2 succeeded")
end

---- Q.indices() to return indices of all 1's from B1 input vector
--tests.t3 = function ()
--  local tbl = {0, 0, 0, 0, 0, 0, 0, 0}
--  local b = Q.mk_col(tbl, "B1")
--  local out_table = {}
--  local c = Q.indices(b):eval()
--  print(type(c))
--  assert(c:length() == Q.sum(b):eval():to_num(), "Length Mismatch")
--  assert(c:length() == #out_table)
--  for i = 1, c:length() do
--    local value = c_to_txt(c, i)
--    assert(value == out_table[i])
--  end
--  print("Test t3 succeeded")
--end

return tests