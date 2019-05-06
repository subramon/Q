-- STRESS
-- TODO WHAT THE HECK IS THIS TEST TRYING TO DO?
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local ffi = require 'Q/UTILS/lua/q_ffi'
local plpath = require 'pl.path'
local c_to_txt = require 'Q/UTILS/lua/C_to_txt'
local qconsts = require 'Q/UTILS/lua/q_consts'

local tests = {}
tests.t1 = function()
  local X = {}
  for i = 1,9 do
    X[#X + 1] = 31
  end
  for i = 1,333 do
    X[#X + 1] = 32
  end
  for i = 1,55 do
    X[#X + 1] = 33
  end
  for i = 1,64 do
    X[#X + 1] = 34
  end
  for i = 1,35 do
    X[#X + 1] = 35
  end
  for i = 1,85 do
    X[#X + 1] = 36
  end
  for i = 1,22 do
    X[#X + 1] = 37
  end
  for i = 1,32 do
    X[#X + 1] = 38
  end
  local ysubp = Q.const({ val = 0.5, len = #X, qtype = 'F8' })
  X = Q.mk_col(X, 'F8')
  ysubp:eval()

  local b = Q.sum(Q.vvmul(X, ysubp))
  b = b:eval()
  for i = 1,100000 do
    local btmp = Q.sum(Q.vvmul(X, ysubp)):eval()
    print("Iteration ", i)
    assert(btmp == b, "original result: "..b:to_num()..", different result: "..btmp:to_num())
  end
  -- Now that there are enough files lets try the test
  local Q = require 'Q'
  local c1 = Q.const( {val = 65535, qtype = "I4", len = 8 })
  c1:eval()
  local val, nn_val = c_to_txt(c1, 1)
  --local val, nn_val = c1:get_element(0)
  -- print(val, nn_val)
  --assert(ffi.cast("int *", val)[0] == 65535)
  assert(val == 65535)
  -- now lets remove all the files in the data folder
  local data_dir = qconsts.Q_DATA_DIR
  os.execute(string.format("find %s -type f -delete", data_dir))
end

return tests
