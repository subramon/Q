-- NO_OP
local ffi = require 'ffi'
local qconsts = require 'Q/UTILS/lua/q_consts'
local utils
utils = {
  arr_from_col = function (c)
    local sz, vec, nn_vec = c:get_all()
    local ctype = qconsts.qtypes[c:fldtype()].ctype .. " *"
    return ffi.cast(ctype, vec)
  end,
  
  col_as_str = function (c) 
    local s = ""
    local vec = utils.arr_from_col(c)
    local N=c:length()
    for i=0,N-1 do
      local num = vec[i]
      if c:qtype() == "F4" or c:qtype() == "F8" then
        num = utils.round_num_to_x_precision(vec[i])
      end
      s = s .. tostring(num) .. ","
    end
    return s
  end,

  round_num_to_x_precision = function (num, x)
    if not x then
      x = 2   -- default to 2 precision
    end
    return math.floor(num * (10 ^ x) + 0.5) / (10 ^ x)
  end,
}

return utils
