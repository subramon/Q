-- NO_OP
-- data for less than operation
-- data field contains inputs in table 'a' and table 'b'
-- and output in table 'z'

return { 
  data = {
    { a = {10,20,30,10}, b = {90,30,40,90} , z = {1,1,1,1} }, -- all less than 
    { a = {20,15,25,35}, b = {10,20,30,40}, z = {0,1,1,1} }, -- 1st not less than 
    { a = {5,10,20,40}, b = {10,20,30,20}, z = {1,1,1,0} }, -- 4th not less than
    { a = {8,12,30,30}, b = {10,20,10,40} , z = {1,1,0,1} }, -- 3rd not less than
    { a = {7,20,20,35}, b = {10,1,30,40}, z = {1,0,1,1} }, -- 2nd not less than
  }
}
