-- NO_OP
-- data for not equalto operation
-- data field contains inputs in table 'a' and table 'b'
-- and output in table 'z'

return { 
  data = {
    { a = {40,30,20,10}, b = {10,20,30,40}, z = {15} }, -- all not equal
    { a = {20,40,50,60}, b = {20,20,30,40}, z = {14} }, -- 1st equal
    { a = {100,90,80,40}, b = {10,20,30,40}, z = {7} }, -- 4th equal
    { a = {1,2,30,4}, b = {10,20,30,40}, z = {11} }, -- 3rd equal
    { a = {100,20,80,90}, b = {10,20,30,40}, z = {13} }, -- 2nd equal
  }
}
