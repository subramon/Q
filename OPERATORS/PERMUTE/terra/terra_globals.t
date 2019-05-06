local qconsts = require 'Q/UTILS/lua/q_consts'
terra_types = {} 
terra_types['I1'] = int8
terra_types['I2'] = int16
terra_types['I4'] = int32
terra_types['I8'] = int64
terra_types['F4'] = float
terra_types['F8'] = double
terra_types['SV'] = int32
-- terra_types['SC'] = "char"
terra_types['B1'] = uint64  

--local C = terralib.includec("stdlib.h")
local ffi = require 'ffi'
  
-- TODO belongs in utils
function t_Array(qtype, N)
    local r = ffi.C.malloc(qconsts.qtypes[qtype].width * N)
    r = terralib.cast(&terra_types[qtype], r)
    ffi.gc(r, ffi.C.free)
    return r
end
