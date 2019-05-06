-- NO_OP
-- data for greater than equalto operation
-- data field contains inputs in table 'a' and table 'b'
-- and output in table 'z'

return { 
  data = {
    { a = {90,30,40,90}, b = {10,20,30,90}, z = {15} }, -- all greater equal to
    { a = {10,20,30,40}, b = {20,20,30,40}, z = {14} }, -- 1st not greater equal to
    { a = {10,20,30,20}, b = {10,20,30,40}, z = {7} }, -- 4th not greater equal to
    { a = {10,20,10,40}, b = {10,20,30,40}, z = {11} }, -- 3rd not greater equal to
    { a = {10,8,30,40}, b = {10,20,30,40}, z = {13} }, -- 2nd not greater equal to
  }
}
