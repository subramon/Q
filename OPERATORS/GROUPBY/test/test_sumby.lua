require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local get_max_num_in_chunk = require 'Q/UTILS/lua/get_max_num_in_chunk'

local tests = {}

tests.t1 = function()
  local val = Q.mk_col({1, 2, 4, 5, 6, 7, 8, 9}, "I8")
  local grp = Q.mk_col({0, 1, 2, 1, 1, 2, 0, 2}, "I2")
  local exp_val = {9, 13, 20}
  local exp_cnt = {2, 3, 3}
  local n_grp = 3
  local cnd = nil
  local optargs = {}
  for _, bval in ipairs{true, false} do 
    optargs.is_safe = bval 
    local res = Q.sumby(val, grp, n_grp, cnd, optargs)
    assert(type(res) == "Reducer")
    local out_val, out_cnt = res:eval()
    assert(type(out_val) == "lVector")
    assert(type(out_cnt) == "lVector")
    assert(out_val:num_elements() == n_grp)
    assert(out_cnt:num_elements() == n_grp)
    for i = 1, n_grp do 
      local chk_val = out_val:get1(i-1)
      local chk_cnt = out_cnt:get1(i-1)
      assert(chk_val:to_num() == exp_val[i])
      assert(chk_cnt:to_num() == exp_cnt[i])
    end
    print("Test t1 completed for " .. tostring(bval))
  end
  print("Test t1 completed")
end

tests.t2 = function()
  -- sumby test in safe mode ( default is safe mode )
  -- group by column exceeds limit
  local val = Q.mk_col({1, 2, 4, 5, 6, 7, 8, 9}, "I4")
  local grp = Q.mk_col({0, 1, 4, 1, 1, 2, 0, 2}, "I2")
  local n_grp = 3
  print(">>> START DELIBERATE ERROR")
  local res = Q.sumby(val, grp, n_grp)
  local status = pcall(res.eval, res)
  print("<<< START DELIBERATE ERROR")
  assert(status == false)
  print("Test t2 completed")
end

tests.t3 = function()
  -- Values of b, not having 0
  local val = Q.mk_col({1, 2, 4, 5, 6, 7, 8, 9}, "F4")
  local grp = Q.mk_col({1, 1, 2, 1, 1, 2, 1, 2}, "I2")
  local exp_val = {0, 22, 20}
  local n_grp = 3
  local res = Q.sumby(val, grp, n_grp):eval()

  -- vefiry
  for i = 1, n_grp do 
    local chk_val = res:get1(i-1)
    assert(chk_val:to_num() == exp_val[i])
  end

  print("Test t3 completed")
end


tests.t4 = function()
  local len = get_max_num_in_chunk() * 2 + (get_max_num_in_chunk()/2-1)
  local n_grp = 3

  local val = Q.seq( {start = 1, by = 1, qtype = "I4", len = len} )
  local grp = Q.period({ len = len, start = 0, by = 1, period = n_grp, qtype = "I4"})
  local exp_val = { 279599787, 279613440, 279627093, }

  local optargs = {}
  for _, bval in ipairs{true, false} do 
    optargs.is_safe = bval 
    local res, cnt = Q.sumby(val, grp, n_grp, nil, optargs):eval()
    -- Q.print_csv({res, cnt})
  
    local n1, n2 = Q.sum(cnt):eval()
    assert(n1:to_num() == len)
  
    -- vefiry
    for i = 1, n_grp do 
      local chk_val = res:get1(i-1)
      assert(chk_val:to_num() == exp_val[i])
    end
  end

  print("Test t4 completed")
end
-- testing with condition field 
tests.t5 = function()
  local val = Q.mk_col({1, 2, 4, 5, 6, 7, 8, 9}, "I8")
  local grp = Q.mk_col({0, 1, 2, 1, 1, 2, 0, 2}, "I2")
  local cnd = Q.mk_col({
    true, false, true, false, true, false, true, false}, "BL")
    Q.print_csv({val,grp})
    Q.print_csv({cnd})
  local exp_val = {9, 6, 4}
  local exp_cnt = {2, 1, 1}
  local n_grp = 3
  local optargs = {}
  for _, bval in ipairs{true, false} do 
    optargs.is_safe = bval 
    local res = Q.sumby(val, grp, n_grp, cnd, optargs)
    assert(type(res) == "Reducer")
    local out_val, out_cnt = res:eval()
    assert(type(out_val) == "lVector")
    assert(type(out_cnt) == "lVector")
    assert(out_val:num_elements() == n_grp)
    assert(out_cnt:num_elements() == n_grp)
    Q.print_csv({out_val, out_cnt})
    for i = 1, n_grp do 
      local chk_val = out_val:get1(i-1)
      local chk_cnt = out_cnt:get1(i-1)
      assert(chk_val:to_num() == exp_val[i])
      assert(chk_cnt:to_num() == exp_cnt[i])
    end
    print("Test t5 completed for " .. tostring(bval))
  end
  print("Test t5 completed")
end

tests.t1()
tests.t2()
tests.t3()
tests.t4()
tests.t5()

-- return tests
