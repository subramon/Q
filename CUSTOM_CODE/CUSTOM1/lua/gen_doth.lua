local plfile = require 'pl.file'
local T = require 'Q/CUSTOM_CODE/CUSTOM1/lua/custom1_spec'
local opfile = "../inc/custom1.h"
local H = {}
H[#H+1] = "#ifndef CUSTOM1_H"
H[#H+1] = "#define CUSTOM1_H"
H[#H+1] = "typedef struct _custom1_t { "
for k, v in ipairs(T) do 
  H[#H+1] = "  bfloat16 " .. v .. ";" 
  
end
H[#H+1] = "  uint64_t bmask; "
H[#H+1] = "} custom1_t; "
H[#H+1] = "#endif // CUSTOM1_H"
H[#H+1] = "\n"
local  outstr = table.concat(H, "\n")

plfile.write(opfile, outstr)

print("Generated " .. opfile)
