-- NO_OP
-- data for add operation
-- data field contains inputs in table 'a' and table 'b'
-- and output in table 'z'
local qtype = require 'Q/OPERATORS/F1F2OPF3/test/testcases/c_testing/output_qtype'
return { 
  data = {
    { a = {10,20,30,40}, b = {10,20,30,40}, z = {20,40,60,80} }, -- simple values
    -- only F4 and F8 type will be run for the below data
    { a = {10.1,20.2,30.2}, b = {10.5,20.3,30.3}, z = {20.6,40.5,60.5}, qtype = {"F4", "F8"}, precision = 1 },
    { a = {10.10,20.22,30.21}, b = {10.5,20.33,30.3}, z = {20.6,40.55,60.51}, qtype = {"F4", "F8"}, precision = 2 },
  },
  output_qtype = qtype["promote"]
}
