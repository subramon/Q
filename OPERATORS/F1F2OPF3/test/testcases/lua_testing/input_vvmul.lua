
-- NO_OP
-- data for mul operation
-- data field contains inputs in table 'a' and table 'b'
-- and output in table 'z'
return { 
  data = {
    { a = {10,2,35,10}, b = {10,20,2,9}, z = {100,40,70,90} }, -- simple values
    -- only F4 and F8 type will be run for the below data
    { a = {9.8,5.8,8.2}, b = {2.5,2.5,1.5}, z = {24.5,14.5,12.3}, qtype = {"F4", "F8"}, precision = 1 }, 
    { a = {10.5,20.6,15.5}, b = {5.5,3.6,6.5}, z = {57.75,74.16,100.75}, qtype = {"F4", "F8"}, precision = 2 },
  },
}
