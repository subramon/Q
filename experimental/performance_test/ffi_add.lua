local ffi = require 'ffi'
local header_file = "add.h"

local qc = ffi.load('./libadd.so')

local file = io.open(header_file, "r")
ffi.cdef(file:read("*all"))
file:close()

local limit = 100000000
if ( arg ) and ( arg[1] ) then 
  limit = tonumber(arg[1])
end

local function sum_of_n()
  local output = qc['add'](limit)
  --print(tonumber(output))
end


for i = 1, 100 do
  sum_of_n()
end
