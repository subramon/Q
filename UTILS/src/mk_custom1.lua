-- luajit mk_custom1.lua custom1_terms
local plfile = require 'pl.file'
assert(#arg == 1, "Usage is luajit " .. arg[0] .. " <terms> ")
local termfile = arg[1]
local terms = require (termfile)
assert(type(terms) == "table")
assert(#terms >= 1)
local H = {}
H[#H+1] = "//START_FOR_CDEF "
H[#H+1] = "typedef struct { "
for k, v in ipairs(terms) do 
  H[#H+1] = "  float " .. v .. ";"
end
H[#H+1] = "  uint64_t bmask; "
H[#H+1] = "} custom1_t; "
H[#H+1] = "//STOP_FOR_CDEF "

local hstr = table.concat(H, "\n");
local opfile = "../inc/custom1.h"
plfile.write(opfile, hstr)
print("Generated " .. opfile)
