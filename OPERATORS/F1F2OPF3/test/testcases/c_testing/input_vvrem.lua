-- NO_OP
-- data for rem operation
-- data field contains inputs in table 'a' and table 'b'
-- and output in table 'z'
local qtype = require 'Q/OPERATORS/F1F2OPF3/test/testcases/c_testing/output_qtype'
return { 
  data = {
    { a = {74,52,37,92}, b = {10,5,3,10}, z = {4,2,1,2}, qtype = {"I1", "I2", "I4", "I8"} }, -- simple values
  },
  output_qtype = qtype["vvrem"]
}
