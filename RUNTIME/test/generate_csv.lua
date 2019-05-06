local qconsts = require 'Q/UTILS/lua/q_consts'
local fns = {}

fns.generate_csv = function (csv_filename, qtype, no_of_rows, gen_type )
  local file = assert(io.open(csv_filename, 'w'))
  for i = 1, no_of_rows do
    local value
    
    if qtype == "B1" then
      if i % 2 == 0 then value = 0 else value = 1 end  
    else
      if gen_type == "random" then
        value = i*15 % qconsts.qtypes[qtype].max
      elseif(gen_type == "iter")then 
        value = i * 10
      end
    end
    --print(value)
    file:write(value.."\n")
  end
  file:close()
end

return fns


