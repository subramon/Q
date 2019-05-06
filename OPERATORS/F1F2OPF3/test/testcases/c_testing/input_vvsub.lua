-- NO_OP
-- data for sub operation
-- data field contains inputs in table 'a' and table 'b'
-- and output in table 'z'
local qtype = require 'Q/OPERATORS/F1F2OPF3/test/testcases/c_testing/output_qtype'
return { 
  data = {
    { a = {20,40,30,100}, b = {10,20,10,10}, z = {10,20,20,90} }, -- simple values
    -- only F4 and F8 type will be run for the below data
    { a = {10.5,20.8,30.2}, b = {5.3,10.3,20.1}, z = {5.2,10.5,10.1}, qtype = {"F4", "F8"}, precision = 1 }, 
    { a = {80.50,100.80,30.15}, b = {10.25,10.25,20.9}, z = {70.25,90.55,9.25}, qtype = {"F4", "F8"}, precision = 2 }, 
  },
  output_qtype = qtype["promote"]
}
