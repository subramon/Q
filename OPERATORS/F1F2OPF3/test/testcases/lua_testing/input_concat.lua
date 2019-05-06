-- NO_OP
-- data for concat operation
-- data field contains inputs in table 'a' and table 'b'
-- and output in table 'z'
-- combination of input_type 1 and input_type 2,
-- has to be specified in qtype field ( mandatory field )

-- TODO: the test_concat format can be same as test_vvxxx format,
-- just the output of each combination needs to be specified
-- in z field as a comma seperated values but in specific order
-- for eg:{ z = { 257, 65537, 4294967297, 257, 65537, 4294967297,
-- 257, 65537, 4294967297}, qtype = { "I1", "I2", "I4"} }:
-- can have following combinations as,
-- input_type1 = I1 input_type2 = I1 --> z[1] = 257
-- input_type2 = I1 input_type2 = I2 --> z[2] = 65537
-- input_type2 = I1 input_type2 = I4 --> z[3] = 4294967297 and so on...
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
}
