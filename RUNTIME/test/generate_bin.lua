local qconsts = require 'Q/UTILS/lua/q_consts'
local cmem    = require 'libcmem'
local ffi = require 'ffi'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local plpath  = require 'pl.path'
local fns = {}

-- generate_ bin() function parameters are:
-- num_values: desired num of values to be written in bin file
-- q_type: desired Q type of values
-- bin_filename: desired filename for .bin file
-- gen_type: 
--         (1) "random" : i*15 % qconsts.qtypes[q_type].max
--         (2) "iter"   : index multiply by 10 
fns.generate_bin = function (num_values, q_type, bin_filename, gen_type)
  local q_type_width = qconsts.qtypes[q_type].width
  if q_type == "B1" then
    num_values = math.ceil( num_values / 64 )
    q_type_width = 8
  end
  local bufsz = num_values * ffi.sizeof(qconsts.qtypes[q_type].ctype)
  local buf = cmem.new(bufsz, q_type, "buffer for gen bin")
  local bufptr = get_ptr(buf, q_type)

  for i = 1,num_values do
    local value 
    if q_type == "B1" then
      if i % 2 == 0 then value = 0 else value = 1 end  
    else
      if gen_type == "random" then
        value = i*15 % qconsts.qtypes[q_type].max
      elseif(gen_type == "iter")then 
        value = i * 10
      end
    end
    bufptr[i-1] = value
  end

  local fp = ffi.C.fopen(bin_filename, "w")
  -- print("L: Opened file")
  local nw = ffi.C.fwrite(bufptr, q_type_width, num_values , fp)
  -- print("L: Wrote to file")
  -- assert(nw > 0 )
  ffi.C.fclose(fp)
  --print("L: Done with file")
  assert(plpath.isfile(bin_filename))
end

return fns


