-- FUNCTIONAL
local Q       = require 'Q'
local cmem    = require 'libcmem'
local Vector  = require 'libvec'
local lVector = require 'Q/RUNTIME/VCTR/lua/lVector'
local qconsts = require 'Q/UTILS/lua/q_consts'
local plfile  = require 'pl.file'
require 'Q/UTILS/lua/strict'

local tests = {}

tests.t1 = function ()
  local in_col = Q.mk_col({ "abc", "def", "ghi", "xxx"}, "SC"):set_name("incol")
  local dict = { }
  dict["abc"] = 1
  dict["def"] = 2
  dict["ghi"] = 3
  dict["jkl"] = 4
  local filename = "/tmp/_XXXXX"
  local qtypes = { "I1", "I2", "I4", "I8"}
  for _, qtype in pairs(qtypes) do 
    local optargs = { qtype = qtype }
    local outv = Q.SC_to_I4(in_col, dict, optargs):eval()
    local chk_outv = Q.mk_col({1,2,3,0}, qtype)
    assert(chk_outv:fldtype() == qtype)
    local n1, n2 = Q.sum(Q.vveq(outv, chk_outv)):eval()
    assert(n1 == n2)
  end
  print("Test t1 succeeded")
end
tests.t2 = function ()
  local buf = cmem.new(4096, "SC", "string buffer")
  local str_val = "ABCD123"
  local width = #str_val + 1 -- +1 for nullc
  buf:set(str_val)
  local y = assert(Vector.new('SC:8', qconsts.Q_DATA_DIR))
  local len  = 2*qconsts.chunk_size + 17
  for j = 1, len do 
    assert(y:put1(buf))
  end
  y:eov()
  y:persist()
  local file_size = y:file_size()
  local file_name = y:file_name()
  local in_col = lVector({file_name = file_name, qtype = "SC",
    width = width})



  for i = 1, 2 do 
    local dict = {}
    local chk_outv
    if ( i == 1 ) then 
      dict[str_val] = 1
      chk_outv = Q.const({val = 1, len = len, qtype = "I4"})
    elseif ( i == 2 ) then 
      chk_outv = Q.const({val = 0, len = len, qtype = "I4"})
      dict["XXXXXXXX"] = 1
    else
      assert(nil)
    end
    local outv = Q.SC_to_I4(in_col, dict):eval()
    assert(chk_outv:fldtype() == "I4") -- default output qtype
    local n1, n2 = Q.sum(Q.vveq(outv, chk_outv)):eval()
    assert(n1 == n2)
  end
  
  print("Test t2 succeeded")
end
return tests
