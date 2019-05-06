-- NO_OP
-- data for equalto operation
-- data field contains inputs in table 'a' and table 'b'
-- and output in table 'z'

return { 
  data = {
    { a = {10,20,30,40}, b = {10,20,30,40}, z = {1,1,1,1} }, -- all equal
    { a = {20,20,30,40}, b = {10,20,30,40}, z = {0,1,1,1} }, -- 1st not equal
    { a = {10,20,30,50}, b = {10,20,30,40}, z = {1,1,1,0} }, -- 4th not equal
    { a = {10,20,40,40}, b = {10,20,30,40}, z = {1,1,0,1} }, -- 3rd not equal
    { a = {10,30,30,40}, b = {10,20,30,40}, z = {1,0,1,1} }, -- 2nd not equal
  }
}
