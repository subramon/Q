-- NO_OP
-- data for div operation
-- data field contains inputs in table 'a' and table 'b'
-- and output in table 'z'
return { 
  data = {
    { a = {70,55,30,90}, b = {10,5,3,10}, z = {7,11,10,9} }, -- simple values
    -- only F4 and F8 type will be run for the below data
    { a = {9.8,50.5,130.2}, b = {2,5,3}, z = {4.9,10.1,43.4}, qtype = {"F4", "F8"}, precision = 1 }, 
  },
}
