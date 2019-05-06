-- f_to_s is a table consisting of all reducers registered with Q
local f_to_s = require 'Q/OPERATORS/F_TO_S/lua/_f_to_s'
local function reduce( fns, vec)
  local status
  -- setup reducers for each input 
  local gens = {} 
  for i, v in ipairs(fns) do 
    gens[i] = f_to_s[v](vec) 
  end
  -- for each chunk, evaluate reducer on that chunk
  repeat 
    for i, v in ipairs(fns) do 
      status = gens[i]:next() 
    end 
  until not status
  -- return results for each reducer in return_vals
  local return_vals = {}
  for i, v in ipairs(gens) do 
    return_vals[i] = gens[i]:eval() 
  end
  return unpack(return_vals)
end
