-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local cutils  = require 'libcutils'
local cVector = require 'libvctr'
local plpath  = require 'pl.path'
local plfile  = require 'pl.file'
local qcfg    = require 'Q/UTILS/lua/qcfg'

local max_num_in_chunk = qcfg.max_num_in_chunk

-- validating unique operator to return unique values from input vector
-- FUNCTIONAL
-- where num_elements are less than max_num_in_chunk
local tests = {}
local qtypes = { 
  "I1", "I2", "I4", "I8", "UI1", "UI2", "UI4", "UI8", "F4", "F8", }
tests.t1 = function ()
  for _, qtype in ipairs(qtypes) do 
    local sl = Q.mk_col(
      {1, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 4,4, 5 }, qtype)
    local sv = Q.vsmul(sl, 10)
    local dl = Q.mk_col(
      {1, 2, 2, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 5}, qtype)
    local T = Q.join(sv, sl, dl)
    assert(type(T) == "table")
    local dv_val = assert(T.val)
    assert(type(dv_val) == "lVector")
    assert(dv_val:qtype() == qtype)
    assert(dv_val:has_nulls())
    assert(dv_val:max_num_in_chunk() == sv:max_num_in_chunk())

    dv_val:eval()
    assert(dv_val:check())
    -- dv_val:pr()
    assert(sl:check())
    assert(sv:check())
    assert(dl:check())
    assert(dv_val:check())
    sl:delete()
    sv:delete()
    dl:delete()
    dv_val:delete()
    cVector.check_all()
    print("Test t1 succeeded for qtype .. ", qtype)
    -- error("PREMATURE")
  end
  print("Test t1 succeeded")
end
tests.t2 = function()
  -- we repeat this test twice, swapping source and destination 2nd time 
  local M = {}
  local O = { is_hdr = true, max_num_in_chunk = 64  }
  M[#M+1] = { name = "id", qtype = "I4", has_nulls = false, }
  M[#M+1] = { name = "lnk", qtype = "I4", has_nulls = false, }
  M[#M+1] = { name = "val", qtype = "I4", has_nulls = false, }
  for _, iter in ipairs({2, 1}) do 
    print("TEST Iteration " .. iter)
    -- load source data 
    local datafile 
    if ( iter == 1 ) then 
      datafile = qcfg.q_src_root ..  "/OPERATORS/JOIN/test/join_src_1.csv"
    else
      datafile = qcfg.q_src_root ..  "/OPERATORS/JOIN/test/join_dst_1.csv"
    end
    assert(plpath.isfile(datafile))
    local Tsrc = Q.load_csv(datafile, M, O)
    assert(Tsrc.id:max_num_in_chunk() == 64)
    -- load destination data 
    if ( iter == 1 ) then  
      datafile = qcfg.q_src_root ..  "/OPERATORS/JOIN/test/join_dst_1.csv"
    else
      datafile = qcfg.q_src_root ..  "/OPERATORS/JOIN/test/join_src_1.csv"
    end
    assert(plpath.isfile(datafile))
    local Tdst = Q.load_csv(datafile, M, O)
    assert(Tdst.id:max_num_in_chunk() == 64)
    --========================================
    local T = Q.join(Tsrc.val, Tsrc.lnk, Tdst.lnk)
    assert(type(T) == "table")
    local dv_val = assert(T.val)
    assert(type(dv_val) == "lVector")
    assert(dv_val:qtype() == Tsrc.val:qtype())
    assert(dv_val:has_nulls())
    assert(dv_val:max_num_in_chunk() == Tsrc.val:max_num_in_chunk())
  
    dv_val:eval()
    assert(dv_val:check())
    assert(Tsrc.lnk:check())
    assert(Tsrc.val:check())
    assert(Tdst.lnk:check())
    assert(dv_val:check())
    assert(dv_val:has_nulls())
  
    -- check contents of dv_val 
  
    dv_val:drop_nulls() -- needed for vveq to work 
    if ( iter == 1 ) then 
      local n1, n2 = Q.sum(Q.vveq(dv_val, Tdst.val)):eval()
      assert(n1 == n2)
    else
      local chk_dv_val = Q.mk_col({10, 20, 30, 40, 50, 0, }, "I4",
        { name = "chk_dv_val", max_num_in_chunk = 64}, 
        { true, true, true, true, true, false, })
      chk_dv_val:drop_nulls() -- needed for vveq to work 
      local n1, n2 = Q.sum(Q.vveq(dv_val, chk_dv_val)):eval()
      -- dv_val:pr()
      -- print(n1, n2)
      assert(n1 == n2)
    end
  
    Tsrc.lnk:delete()
    Tsrc.val:delete()
    Tdst.lnk:delete()
    dv_val:delete()
    cVector.check_all()
  
    print("Test t2 succeeded for iteration " .. iter )
  end
  print("Test t2 succeeded")
end
tests.t3_sum = function ()
  for _, qtype in ipairs(qtypes) do 
    local sl = Q.mk_col(
      {1, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 4,4, 5 }, qtype)
    local sv = Q.vsmul(sl, 10)
    local dl = Q.mk_col(
      {1, 2, 2, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 5}, qtype)
    local T = Q.join(sv, sl, dl, { "sum" })
    assert(type(T) == "table")
    local dv_sum = assert(T.sum)
    assert(type(dv_sum) == "lVector")
    local dv_qtype = dv_sum:qtype()
    --============================
    if ( ( qtype == "I1" ) or ( qtype == "I2" ) or 
         ( qtype == "I4" ) or ( qtype == "I8" ) ) then 
      assert(dv_qtype == "I8")
    elseif ( ( qtype == "UI1" ) or ( qtype == "UI2" ) or 
         ( qtype == "UI4" ) or ( qtype == "UI8" ) ) then 
      assert(dv_qtype == "UI8")
    else
      assert(dv_qtype == "F8")
    end
    --============================
    assert(dv_sum:has_nulls())
    assert(dv_sum:max_num_in_chunk() == sv:max_num_in_chunk())
    dv_sum:set_name("dv_sum")

    dv_sum:eval()
    Q.print_csv({sv,sl}, {header = "sv,sl",  opfile = "_src.csv"})
    dv_sum:drop_nulls() -- for print to work 
    Q.print_csv({dl,dv_sum}, {header = "dl,dv",  opfile = "_dst.csv"})
    -- dv_sum:pr()
    assert(sl:check())
    assert(sv:check())
    assert(dl:check())
    assert(dv_sum:check())
    sl:delete()
    sv:delete()
    dl:delete()
    dv_sum:delete()
    cVector.check_all()
    print("Test t3_sum succeeded for qtype .. ", qtype)
    -- error("PREMATURE")
  end
  print("Test t3_sum succeeded")
end
tests.t3_cnt = function ()
  for _, qtype in ipairs(qtypes) do 
    local sl = Q.mk_col(
      {1, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 4,4, 5 }, qtype)
    local sv = Q.vsmul(sl, 10)
    local dl = Q.mk_col(
      {1, 2, 2, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 5}, qtype)
    local T = Q.join(sv, sl, dl, { "cnt" })
    assert(type(T) == "table")
    local dv_cnt = assert(T.cnt)
    assert(type(dv_cnt) == "lVector")
    local dv_qtype = dv_cnt:qtype()
    assert(dv_qtype == "I8")
    assert(not dv_cnt:has_nulls())
    assert(dv_cnt:max_num_in_chunk() == sv:max_num_in_chunk())
    dv_cnt:set_name("dv_cnt")

    dv_cnt:eval()
    Q.print_csv({sv,sl}, {header = "sv,sl",  opfile = "_src.csv"})
    dv_cnt:drop_nulls() -- for print to work 
    Q.print_csv({dl,dv_cnt}, {header = "dl,dv",  opfile = "_dst.csv"})
    -- dv_cnt:pr()
    assert(sl:check())
    assert(sv:check())
    assert(dl:check())
    assert(dv_cnt:check())
    sl:delete()
    sv:delete()
    dl:delete()
    dv_cnt:delete()
    cVector.check_all()
    print("Test t3_cnt succeeded for qtype .. ", qtype)
    -- error("PREMATURE")
  end
  print("Test t3_sum succeeded")
end
-- WORKS tests.t1()
-- WORKS tests.t2()
-- WORKS tests.t3_sum()
tests.t3_cnt()
-- return tests
