-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local c_to_txt = require 'Q/UTILS/lua/C_to_txt'
local qconsts = require 'Q/UTILS/lua/q_consts'
local utils = require 'Q/UTILS/lua/utils'
local plpath  = require 'pl.path'
local plfile  = require 'pl.file'
local Scalar = require 'libsclr'
local path_to_here = os.getenv("Q_SRC_ROOT") .. "/OPERATORS/UNIQUE/test/"
assert(plpath.isdir(path_to_here))

local chunk_size = qconsts.chunk_size

-- validating unique operator to return unique values from input vector
-- FUNCTIONAL
-- where num_elements are less than chunk_size
local tests = {}
tests.t1 = function ()
  local src_lnk_tbl = {10,10,10,10,20,20,30}
  local src_fld_tbl = {1,2,2,1,3,2,1}
  local dst_lnk_tbl = {10,20,30}
  local src_lnk = Q.mk_col(src_lnk_tbl, "I8")
  local src_fld = Q.mk_col(src_fld_tbl, "I8")
  local dst_lnk = Q.mk_col(dst_lnk_tbl, "I8")
  local c = Q.join(src_lnk, src_fld, dst_lnk, "sum")
  c:eval()
  Q.print_csv(c)

--  for i = 1, c:length() do
--    local value = c_to_txt(c, i)
--    assert(value == out_table[i])

--    value = c_to_txt(d, i)
--    assert(value == cnt_table[i])
--  end
  -- local opt_args = { opfile = "" }
  -- Q.print_csv(c, opt_args)
  print("Test t1 succeeded")
end

-- test for num_elements > chunk_size
tests.t2 = function ()
  local src_lnk_tbl = {}
  local src_fld_tbl = {}
  for i = 1, qconsts.chunk_size do
    if i%2 == 0 then
      src_lnk_tbl[#src_lnk_tbl+1] = 10
      src_fld_tbl[#src_fld_tbl+1] = 1
    else
      src_lnk_tbl[#src_lnk_tbl+1] = 20
      src_fld_tbl[#src_fld_tbl+1] = 2
    end
  end
  for i = qconsts.chunk_size+1, (qconsts.chunk_size + (qconsts.chunk_size/2)) do
    if i%2 == 0 then
      src_lnk_tbl[#src_lnk_tbl+1] = 20
      src_fld_tbl[#src_fld_tbl+1] = 2
    else
      src_lnk_tbl[#src_lnk_tbl+1] = 30
      src_fld_tbl[#src_fld_tbl+1] = 3
    end
  end
  local dst_lnk_tbl = {10,20}
  local src_lnk = Q.mk_col(src_lnk_tbl, "I4")
  local src_fld = Q.mk_col(src_fld_tbl, "I4")
  local dst_lnk = Q.mk_col(dst_lnk_tbl, "I4")
  Q.sort(src_lnk, "asc"):eval()
  Q.sort(src_fld, "asc"):eval()
  Q.sort(dst_lnk, "asc"):eval()
  local c = Q.join(src_lnk, src_fld, dst_lnk, "max_idx")
  c:eval()
  Q.print_csv(c)
  print(c:fldtype())
  print(c:length())
  local unq, cnt = Q.unique(src_lnk)
  unq:eval()
  Q.print_csv({unq, cnt})
--  for i = 1, c:length() do
--    local value = c_to_txt(c, i)
--    assert(value == out_table[i])

--    value = c_to_txt(d, i)
--    assert(value == cnt_table[i])
--  end
  -- local opt_args = { opfile = "" }
  -- Q.print_csv(c, opt_args)
  print("Test t2 succeeded")
end


tests.t3 = function ()
  local src_lnk_tbl = {10,10,10,10,20,20,30}
  local src_fld_tbl = {1,21,12,11,3,-1,23}
  local dst_lnk_tbl = {10,20,30,40}
  local src_lnk = Q.mk_col(src_lnk_tbl, "I1")
  local src_fld = Q.mk_col(src_fld_tbl, "I1")
  local dst_lnk = Q.mk_col(dst_lnk_tbl, "I1")
  local c = Q.join(src_lnk, src_fld, dst_lnk, "any")
  c:eval()
  Q.print_csv(c)

--  for i = 1, c:length() do
--    local value = c_to_txt(c, i)
--    assert(value == out_table[i])

--    value = c_to_txt(d, i)
--    assert(value == cnt_table[i])
--  end
  -- local opt_args = { opfile = "" }
  -- Q.print_csv(c, opt_args)
  print("Test t3 succeeded")
end

tests.t4 = function ()
  local src_lnk_tbl = {10,20,30,50,60}
  local src_fld_tbl = {1,21,12,7,9}
  local dst_lnk_tbl = {10,20,30,40}
  local src_lnk = Q.mk_col(src_lnk_tbl, "I2")
  local src_fld = Q.mk_col(src_fld_tbl, "I1")
  local dst_lnk = Q.mk_col(dst_lnk_tbl, "I2")
  local c = Q.join(src_lnk, src_fld, dst_lnk, "any")
  c:eval()
  Q.print_csv(c)

--  for i = 1, c:length() do
--    local value = c_to_txt(c, i)
--    assert(value == out_table[i])

--    value = c_to_txt(d, i)
--    assert(value == cnt_table[i])
--  end
  -- local opt_args = { opfile = "" }
  -- Q.print_csv(c, opt_args)
  print("Test t4 succeeded")
end

-- testcase for checking num_elements > chunk_size
tests.t5 =  function()
  local len = qconsts.chunk_size + 10
  local src_lnk = Q.period({ len = len, start = 1, by = 1, period = qconsts.chunk_size, qtype = "I4"}):eval()
  local src_fld = Q.period({ len = len, start = 1, by = 1, period = qconsts.chunk_size, qtype = "I4"}):eval()
  local dst_lnk = Q.period({ len = len, start = 1, by = 1, period = len, qtype = "I4"}):eval()
  Q.sort(src_lnk, "asc")
  Q.sort(src_fld, "asc")
  Q.sort(dst_lnk, "asc")
  local dst_fld = Q.join(src_lnk, src_fld, dst_lnk, "sum"):eval()
  -- dst_fld and dst_lnk must be of same length
  assert(dst_lnk:length() == dst_fld:length(), "dst_fld and dst_lnk length not same")
  -- validating the values
  for i = 1, len do
    if i <= 10 then
      --print(dst_fld:get_one(i-1):to_num(), i*2)
      assert(dst_fld:get_one(i-1):to_num() == i*2)
    elseif i <= qconsts.chunk_size then
      --print(dst_fld:get_one(i-1):to_num(), i)
      assert(dst_fld:get_one(i-1):to_num() == i)
    else
      --print(dst_fld:get_one(i-1):to_num(), 0)
      assert(dst_fld:get_one(i-1):to_num() == 0)
    end
  end
  print("Successfully completed t5")
end


tests.t6 = function ()
  local src_lnk_tbl = {10,10,20,20,30,30}
  local src_fld_tbl = {1,1,1,1,1,1}
  local dst_lnk_tbl = {10,20,30,10}
  local src_lnk = Q.mk_col(src_lnk_tbl, "I4")
  local src_fld = Q.mk_col(src_fld_tbl, "I4")
  local dst_lnk = Q.mk_col(dst_lnk_tbl, "I4")
  Q.sort(src_lnk, "asc")
  Q.sort(src_fld, "asc")
  Q.sort(dst_lnk, "asc")
  local c = Q.join(src_lnk, src_fld, dst_lnk, "sum"):eval()
  assert(dst_lnk:length() == c:length())
  Q.print_csv(c)

  print("Test t6 succeeded")
end

-- passing optargs.default_val as type 'number'
tests.t7 = function ()
  local src_lnk_tbl = {10,20,30,50,60}
  local src_fld_tbl = {1,21,12,7,9}
  local dst_lnk_tbl = {10,20,30,40}
  local src_lnk = Q.mk_col(src_lnk_tbl, "I2")
  local src_fld = Q.mk_col(src_fld_tbl, "I1")
  local dst_lnk = Q.mk_col(dst_lnk_tbl, "I2")
  local optargs = {}
  optargs.default_val = -1
  local c = Q.join(src_lnk, src_fld, dst_lnk, "any", optargs)
  c:eval()
  local val, _ = c:get_one(c:length()-1)
  assert(val:to_num() == optargs.default_val)
  Q.print_csv(c)

--  for i = 1, c:length() do
--    local value = c_to_txt(c, i)
--    assert(value == out_table[i])

--    value = c_to_txt(d, i)
--    assert(value == cnt_table[i])
--  end
  -- local opt_args = { opfile = "" }
  -- Q.print_csv(c, opt_args)
  print("Test t7 succeeded")
end

-- passing optargs.default_val as type 'Scalar'
tests.t8 = function ()
  local src_lnk_tbl = {10,20,30,50,60}
  local src_fld_tbl = {1,21,12,7,9}
  local dst_lnk_tbl = {10,20,30,40}
  local src_lnk = Q.mk_col(src_lnk_tbl, "I2")
  local src_fld = Q.mk_col(src_fld_tbl, "I1")
  local dst_lnk = Q.mk_col(dst_lnk_tbl, "I2")
  local optargs = {}
  optargs.default_val = Scalar.new(100, "I1")
  local c = Q.join(src_lnk, src_fld, dst_lnk, "any", optargs)
  c:eval()
  local val, _ = c:get_one(c:length()-1)
  assert(val:to_num() == optargs.default_val)
  Q.print_csv(c)

--  for i = 1, c:length() do
--    local value = c_to_txt(c, i)
--    assert(value == out_table[i])

--    value = c_to_txt(d, i)
--    assert(value == cnt_table[i])
--  end
  -- local opt_args = { opfile = "" }
  -- Q.print_csv(c, opt_args)
  print("Test t8 succeeded")
end

-- passing non sorted vectors as input
tests.t9 = function ()
  local src_lnk_tbl = {60,50,40,30,20,10}
  local src_fld_tbl = {1,21,12,15,7,9}
  local dst_lnk_tbl = {10,20,30,40,50}
  local src_lnk = Q.mk_col(src_lnk_tbl, "I2")
  local src_fld = Q.mk_col(src_fld_tbl, "I1")
  local dst_lnk = Q.mk_col(dst_lnk_tbl, "I2")
  local c = Q.join(src_lnk, src_fld, dst_lnk, "any")
  c:eval()
  Q.print_csv(c)

--  for i = 1, c:length() do
--    local value = c_to_txt(c, i)
--    assert(value == out_table[i])

--    value = c_to_txt(d, i)
--    assert(value == cnt_table[i])
--  end
  -- local opt_args = { opfile = "" }
  -- Q.print_csv(c, opt_args)
  print("Test t8 succeeded")
end

-- checking for num_elements > chunk_size
tests.t10 = function()
  local num_elements = qconsts.chunk_size + 3
  local src_lnk = Q.const( { val = 3, qtype = "I4", len = num_elements }):eval()
  local src_fld = Q.seq( { start = 1, by = 1, qtype = "I4", len = num_elements }):eval()
  local dst_lnk = Q.mk_col({ 3 }, "I4")
  local dst_fld = Q.join(src_lnk, src_fld, dst_lnk, "sum")
  dst_fld:eval()
  local sum = Q.sum(src_fld):eval()
  for i = 1, dst_fld:length() do
    local value = c_to_txt(dst_fld, i)
    assert(sum:to_num() == value)
  end
end

-- checking for num_elements > chunk_size
-- and same dst_fld value occuring twice 
-- should not calculate the output twice for same dst_fld value
-- instead should just copy it for second same value. for eg below: (value 4) 
tests.t11 = function()
  local num_elements = qconsts.chunk_size
  local src_lnk = Q.period( { len = num_elements, start = 3, by = 1, period = 2, qtype = "I4"}):eval()
  local src_fld = Q.period( { len = num_elements, start = 10, by = 10, period = 2, qtype = "I4"}):eval()
  local dst_lnk = Q.mk_col({ 3, 4, 4, 5 }, "I4")
  local expected_dst_fld = {(qconsts.chunk_size/2)*10, qconsts.chunk_size*10, qconsts.chunk_size*10, 0}
  local dst_fld = Q.join(src_lnk, src_fld, dst_lnk, "sum")
  dst_fld:eval()
  local sum = Q.sum(src_fld):eval()
  for i = 1, dst_fld:length() do
    local value = c_to_txt(dst_fld, i)
    print(value, expected_dst_fld[i])
    assert(value == expected_dst_fld[i])
  end
end

return tests
