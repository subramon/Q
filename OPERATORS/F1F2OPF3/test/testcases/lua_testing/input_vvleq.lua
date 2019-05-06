-- NO_OP
-- data for less than equalto operation
-- data field contains inputs in table 'a' and table 'b'
-- and output in table 'z'

return { 
  data = {
    { a = {10,20,30,90}, b = {90,30,40,90} , z = {1,1,1,1} }, -- all less than equal to
    { a = {20,15,30,40}, b = {10,20,30,40}, z = {0,1,1,1} }, -- 1st not less than equal to
    { a = {5,20,30,40}, b = {10,20,30,20}, z = {1,1,1,0} }, -- 4th not less than equal to
    { a = {10,10,30,40}, b = {10,20,10,40} , z = {1,1,0,1} }, -- 3rd not less than equal to
    { a = {10,20,30,35}, b = {10,8,30,40}, z = {1,0,1,1} }, -- 2nd not less than equal to
  }
}
