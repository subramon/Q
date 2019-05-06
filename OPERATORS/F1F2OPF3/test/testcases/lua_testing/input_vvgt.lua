-- NO_OP
-- data for greater than operation
-- data field contains inputs in table 'a' and table 'b'
-- and output in table 'z'

return { 
  data = {
    { a = {90,30,40,100}, b = {10,20,30,90}, z = {1,1,1,1} }, -- all greater than
    { a = {10,40,50,60}, b = {20,20,30,40}, z = {0,1,1,1} }, -- 1st not greater than
    { a = {20,30,90,20}, b = {10,20,30,40}, z = {1,1,1,0} }, -- 4th not greater than
    { a = {50,60,10,80}, b = {10,20,30,40}, z = {1,1,0,1} }, -- 3rd not greater than
    { a = {100,8,110,90}, b = {10,20,30,40}, z = {1,0,1,1} }, -- 2nd not greater than
  }
}
