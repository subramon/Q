require 'Q/UTILS/lua/strict'
local cVector = require 'libvctr'
local Scalar  = require 'libsclr'
local Q       = require 'Q'
local csz = cVector.chunk_size()

local tests = {}

tests.t1 = function()
  local len = csz + 17
  local in_table = {}
  local exp_table = {}
  for i = 1, len do
    if i % 2 == 0 then
      in_table[i] = 1
      exp_table[i] = 0
    else
      in_table[i] = 0
      exp_table[i] = 1
    end
  end
  for _, qtype in ipairs({ "B1", "I1", "I2", "I4", "I8", }) do
    local col = Q.mk_col(in_table, qtype)
    local n_col = Q.vnot(col):eval()
    local nn_col = Q.vnot(n_col):eval()
    local val, nn_val
    if ( qtype == "B1" ) then 
      for i = 1, n_col:length() do
        val, nn_val = n_col:get1(i-1)
        assert(val:to_num() == exp_table[i])
      end
      --[[ TODO 
      local n1, n2 = Q.sum(Q.vveq(col, n_col)):eval()
      print(n1, n2)
      assert(n1 == Scalar.new(32264, "I4"))
      --]]
    end
    local n1, n2 = Q.sum(Q.vveq(col, nn_col)):eval()
    assert(n1 == n2)
  end

  print("Completed test t1")
end

tests.t2 = function()
  local len = 66
  local in_table = {}
  local exp_table = {}
  for i = 1, len do
    in_table[i] = 0
    exp_table[i] = 1
  end
  local col = Q.mk_col(in_table, "B1")
  local n_col = Q.vnot(col)
  n_col:eval()
  local n_sum = Q.sum(n_col):eval()
  
  -- TODO: below assert fails, this is because of vec_add_B1 method, 
  -- it copies extra bits from last byte if len is not multiple of 8, discuss with Ramesh
  assert(n_sum:to_num() == len)

  local val, nn_val
  for i = 1, n_col:length() do
    val, nn_val = n_col:get1(i-1)
    assert(val:to_num() == exp_table[i])
  end
  print("Completed test t2")
end
-- tests.t1()
return tests
