local M = {}
local num_cols = 14
for i = 1, num_cols do 
  local name = "x" .. tostring(i)
  M[i] = { name = name, qtype = "F4", is_memo= true, is_persist = true }
end
M[#M+1] = { name = "goal", qtype = "I4", is_memo= true, is_persist = true }
return M
