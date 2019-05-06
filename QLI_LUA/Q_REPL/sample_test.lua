local Q = require 'Q'
require 'Q/UTILS/lua/strict'
local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi = require 'Q/UTILS/lua/q_ffi'
local c_to_txt = require 'Q/UTILS/lua/C_to_txt'

-- COLUMN TEST
local input_table = {1, 2, 3}
local col = Q.mk_col(input_table, "I4")
assert(type(col) == "lVector", " Output of mk_col is not Column")
for i = 1, col:length() do
  local result = c_to_txt(col, i)
  assert(result == input_table[i], "Value mismatch")
  print(result)
end
print("MK_COL Test DONE !!")
print("------------------------------------------")


-- PRINT TEST
Q.print_csv(col, nil, "")
print("PRINT Test DONE !!")
print("------------------------------------------")


-- LOAD CSV TEST
meta = {
 { name = "empid", has_nulls = true, qtype = "I4", is_load = true },
 { name = "yoj", has_nulls = false, qtype ="I2", is_load = true }
}
local result = Q.load_csv("test.csv", meta)
assert(type(result) == "table")
for i, v in pairs(result) do
  assert(type(result[i]) == "lVector")
  Q.print_csv(result[i], nil, "")
  print("##########")
end
print("LOAD CSV Test DONE !!")
print("------------------------------------------")

require('Q/UTILS/lua/cleanup')()
--os.exit()
