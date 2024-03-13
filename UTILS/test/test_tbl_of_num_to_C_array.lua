local get_ptr   = require 'Q/UTILS/lua/get_ptr'
local tbl_of_num_to_C_array = require 'Q/UTILS/lua/tbl_of_num_to_C_array'
local tests = {}
tests.t1 = function()
  local x = { 10, 20, 30, 40, 50, }
  local qtypes = { 
    "I1", "I2", "I4", "I8", "UI1", "UI2", "UI4", "UI8",  "F4", "F8", }
  for k, qtype in ipairs(qtypes) do 
    local y = tbl_of_num_to_C_array(x, qtype)
    local cptr = get_ptr(y, qtype)
    for j, v in ipairs(x) do
      assert(v == cptr[j-1])
    end
    print("test succeeded for qtype = ", qtype)
  end
  print("test t1 for tbl_of_num_to_C_array succeeded")
end 
tests.t1()
-- return tests
