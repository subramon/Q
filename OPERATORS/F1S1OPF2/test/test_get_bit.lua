require 'Q/UTILS/lua/strict'
local Q      = require 'Q'
local qcfg   = require 'Q/UTILS/lua/qcfg'

local function get_nbits(qtype)
  if ( qtype == "I1" ) then
    return 7
  elseif ( qtype == "UI1" ) then
    return 8
  elseif ( qtype == "I2" ) then
    return 15
  elseif ( qtype == "UI2" ) then
    return 16
  elseif ( qtype == "I4" ) then
    return 31
  elseif ( qtype == "UI4" ) then
    return 32
  elseif ( qtype == "I8" ) then
    return 40
  elseif ( qtype == "UI8" ) then
    return 40
  end
  error("XXX")
end

local tests = {}
local qtypes = { "I1", "I2", "I4", "I8", "UI1", "UI2", "UI4", "UI8", }
local out_qtypes = { "BL", "I1", "UI1", }
-- this test is just to make sure the process runs through
-- doesn't really test correctness
tests.t1 = function()
  -- STOP  make data 
  for _, out_qtype in pairs(out_qtypes) do 
    for _, qtype in pairs(qtypes) do 
      local nbits = get_nbits(qtype)
    -- START make data 
      local T = {}
      T[#T+1] = 0
      local x = 1
      for i = 1, nbits do 
        T[#T+1] = x
        x = x * 2
      end
      local  x = Q.mk_col(T, qtype)
      for i  = 0, nbits-1 do
        local y = Q.get_bit(x, i, { out_qtype = out_qtype}):eval()
        assert(y:qtype() == out_qtype)
      end
      print("Test t1 for qtype/out_qtype ", qtype, out_qtype)
    end
  end
  print("Test t1 successfully completed")
end
tests.t2 = function()
  local len = qcfg.max_num_in_chunk * 2 + 17 
  -- when input is 0 vector
  local qtype = "I1"
  local out_qtype = "I1"
  local val = 0
  local x = Q.const({val = val, qtype = qtype, len = len})
  local nbits = get_nbits(qtype)
  for i = 0, nbits-1 do
    local y = Q.get_bit(x, i, { out_qtype = out_qtype})
    local n1, n2 = Q.sum(
      Q.vveq(y, Q.const({val = 0, len = len, qtype = out_qtype}))):eval()
    assert(n1 == n2)
  end
  -- when input is all 1's 
  local qtype = "UI4"
  local out_qtype = "UI1"
  local val = (4096 * 1048576) - 1
  local x = Q.const({val = val, qtype = qtype, len = len})
  local nbits = get_nbits(qtype)
  for i = 0, nbits-1 do
    local y = Q.get_bit(x, i, { out_qtype = out_qtype})
    local n1, n2 = Q.sum(
      Q.vveq(y, Q.const({val = 1, len = len, qtype = out_qtype}))):eval()
    assert(n1 == n2)
  end

end
--return tests
tests.t1()
tests.t2()
