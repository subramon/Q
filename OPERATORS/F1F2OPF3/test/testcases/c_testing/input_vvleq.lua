-- NO_OP
-- data for less than equalto operation
-- data field contains inputs in table 'a' and table 'b'
-- and output in table 'z'

return { 
  data = {
    { a = {10,20,30,90}, b = {90,30,40,90} , z = {15} }, -- all less than equal to
    { a = {20,15,30,40}, b = {10,20,30,40}, z = {14} }, -- 1st not less than equal to
    { a = {5,20,30,40}, b = {10,20,30,20}, z = {7} }, -- 4th not less than equal to
    { a = {10,10,30,40}, b = {10,20,10,40} , z = {11} }, -- 3rd not less than equal to
    { a = {10,20,30,35}, b = {10,8,30,40}, z = {13} }, -- 2nd not less than equal to
  }
}
