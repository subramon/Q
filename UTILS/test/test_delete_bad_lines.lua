local dbl = require 'Q/UTILS/lua/delete_bad_lines'
local diff = require 'Q/UTILS/lua/diff'
local tests = {}

local Q_SRC_ROOT = os.getenv("Q_SRC_ROOT")
local script_dir = Q_SRC_ROOT .. "/UTILS/test/"

tests.t1 = function()
  local regexs = {
    "[a-zA-Z]*",
    "[0-9]+"
  }
  dbl(script_dir .. "dbl_in1.csv", script_dir .. "_dbl_out1.csv", regexs)
  assert(diff(script_dir .. "dbl_out1.csv", script_dir .. "_dbl_out1.csv"), "Test failed")
  --===========================
  local regexs = { '[0-9-a-f]*' }
  dbl(script_dir .. "dbl_in2.csv", script_dir .. "_dbl_out2.csv", regexs)
  assert(diff(script_dir .. "dbl_out2.csv", script_dir .. "_dbl_out2.csv"), "Test failed")
  --===========================
  print("Test t1 succeeded")
end

return tests
