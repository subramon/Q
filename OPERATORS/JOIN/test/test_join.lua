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
tests.t1()
tests.t2()
-- return tests
