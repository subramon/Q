require 'Q/UTILS/lua/strict'
local Q       = require 'Q'
local lgutils = require 'liblgutils'

local tests = {}

tests.t1 = function()
  collectgarbage("stop")
  local pre = lgutils.mem_used()
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
    out_val:delete()
    out_cnt:delete()
    res:delete()
    print("Test t1 completed for " .. tostring(bval))
  end
  -- cleanup
  val:delete()
  grp:delete()

  local post = lgutils.mem_used()
  assert(pre == post)
  collectgarbage("restart")
  print("Test t1 completed")
end

tests.t2 = function()
  collectgarbage("stop")
  local pre = lgutils.mem_used()
  -- sumby test in safe mode ( default is safe mode )
  -- group by column exceeds limit
  local val = Q.mk_col({1, 2, 4, 5, 6, 7, 8, 9}, "I4")
  local grp = Q.mk_col({0, 1, 4, 1, 1, 2, 0, 2}, "I2")
  local n_grp = 3
  print(">>> START DELIBERATE ERROR")
  local res = Q.sumby(val, grp, n_grp)
  local status, x, y = pcall(res.eval, res)
  print("<<< START DELIBERATE ERROR")
  assert(status == false)
  local post = lgutils.mem_used()
  val:delete()
  grp:delete()
  res:delete()
  -- TODO assert(pre == post)
  collectgarbage("restart")
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
  local nC = 256
  local len = 2*nC + math.floor(nC/2) + 1 
  local n_grp = 3

  local val = Q.seq( {start = 1, by = 1, qtype = "I4", len = len,
max_num_in_chunk = nC } )
  local grp = Q.period({ len = len, start = 0, by = 1, period = n_grp, qtype = "I4",
max_num_in_chunk = nC })
  local exp_val = { 279599787, 279613440, 279627093, }

  local optargs = {}
  for _, bval in ipairs{true, false} do 
    optargs.is_safe = bval 
    local rdcr = Q.sumby(val, grp, n_grp, nil, optargs)
    assert(type(rdcr) == "Reducer")
    local res, cnt = rdcr:eval()
    assert(res:num_elements() == 3)
    assert(cnt:num_elements() == 3)

    local exp_res = Q.mk_col({ 68587, 68801, 68373, }, "I8",
      { max_num_in_chunk = res:max_num_in_chunk()} )
    local exp_cnt = Q.mk_col({ 214, 214, 213, }, "I8",
      { max_num_in_chunk = cnt:max_num_in_chunk()} )
  
    print(res:num_elements())
    print(exp_res:max_num_in_chunk())
    local n1, n2 = Q.sum(Q.vveq(res, exp_res)):eval()
    res:pr()
    exp_res:pr()
    cnt:pr()
    exp_cnt:pr()
    assert(n1 == n2)
  
    local n1, n2 = Q.sum(Q.vveq(cnt, exp_cnt)):eval()
    assert(n1 == n2)
  end

  print("Test t4 completed")
end
-- testing with condition field 
tests.t5 = function()
  collectgarbage("stop")
  local pre = lgutils.mem_used()
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
    out_val:delete()
    out_cnt:delete()
    res:delete()
    print("Test t5 completed for " .. tostring(bval))
  end
  val:delete()
  grp:delete()
  cnd:delete()
  local post = lgutils.mem_used()
  assert(pre == post)
  collectgarbage("restart")
  print("Test t5 completed")
end
-- testing for multi-threaded case 
tests.t6 = function()
  collectgarbage("stop")
  local pre = lgutils.mem_used()

  local nC = 65536
  local len = 2*nC + math.floor(nC/2) + 1 
  local n_grp = 3

  local val = Q.const( {val = 2, qtype = "I4", len = len, 
    max_num_in_chunk = nC } )
  local grp = Q.period({ len = len, start = 0, by = 1, 
    period = n_grp, qtype = "I4", max_num_in_chunk = nC })
  local exp_val = { 109228, 109228, 109226, }
  local exp_cnt = { 54614, 54614, 54613, }

  local res = Q.sumby(val, grp, n_grp)
  assert(type(res) == "Reducer")
  local out_val, out_cnt = res:eval()


  assert(type(out_val) == "lVector")
  assert(type(out_cnt) == "lVector")
  assert(out_val:num_elements() == n_grp)
  assert(out_cnt:num_elements() == n_grp)
  Q.print_csv({out_val, out_cnt})

  local r1 = Q.sum(out_val)
  local n1, n2 = r1:eval()
  assert(n1:to_num() == 2 * len)
  r1:delete()

  local r2 = Q.sum(out_cnt)
  local n1, n2 = r2:eval()
  assert(n1:to_num() == len)
  r2:delete()

  for i = 1, n_grp do 
    local chk_val = out_val:get1(i-1)
    local chk_cnt = out_cnt:get1(i-1)
    assert(chk_val:to_num() == exp_val[i])
    assert(chk_cnt:to_num() == exp_cnt[i])
  end

  out_val:delete()
  out_cnt:delete()
  res:delete()
  val:delete()
  grp:delete()
  local post = lgutils.mem_used()
  assert(pre == post)
  collectgarbage("restart")
  print("Test t6 completed")
end


-- WORKS tests.t1()
-- WORKS tests.t2()
-- WORKS tests.t3()
-- WORKS tests.t4()
-- WORKS tests.t5()
tests.t6()

-- return tests
