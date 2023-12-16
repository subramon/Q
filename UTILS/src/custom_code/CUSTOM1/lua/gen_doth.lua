local plfile = require 'pl.file'
local T = require 'Q/UTILS/src/custom_code/CUSTOM1/lua/custom1_spec'
local opfile = "../inc/custom1.h"
local H = {}
H[#H+1] = "#ifndef CUSTOM1_H"
H[#H+1] = "#define CUSTOM1_H"
H[#H+1] = "typdef struct _custom1_t { "
for k, v in ipairs(T) do 
  H[#H+1] = "bfloat16 " .. v .. ";" 
  
end
H[#H+1] = "} ; "
H[#H+1] = "#endif // CUSTOM1_H"
local  outstr = table.concat(H, "\n")

print("Generated " .. opfile)
