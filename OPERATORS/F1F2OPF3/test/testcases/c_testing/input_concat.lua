-- NO_OP
-- data for concat operation
-- data field contains inputs in table 'a' and table 'b'
-- and output in table 'z'
local qtype = require 'Q/OPERATORS/F1F2OPF3/test/testcases/c_testing/output_qtype'
return { 
  data = {
  
    { a = {1}, b = {1}, z = {257}, qtype = {"I1", "I1"} }, 
    { a = {1}, b = {1}, z = {65537}, qtype = {"I1", "I2"} }, 
    { a = {1}, b = {1}, z = {4294967297}, qtype = {"I1", "I4"} }, 
    { a = {1}, b = {1}, z = {257}, qtype = {"I2", "I1"} }, 
    { a = {1}, b = {1}, z = {65537}, qtype = {"I2", "I2"} }, 
    { a = {1}, b = {1}, z = {4294967297}, qtype = {"I2", "I4"} }, 
    { a = {1}, b = {1}, z = {257}, qtype = {"I4", "I1"} }, 
    { a = {1}, b = {1}, z = {65537}, qtype = {"I4", "I2"} }, 
    { a = {1}, b = {1}, z = {4294967297}, qtype = {"I4", "I4"} },
  },
  output_qtype = qtype["concat"]
}
