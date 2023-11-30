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
tests.t1()
-- return tests
