local Q = require 'Q'
local F = {}

local F = {}
local nnF = {}
local qtypes = {}
local widths = {}
local names  = {}

names[1] = "SC"
names[2] = "I2"
names[3] = "F4"
names[4] = "I8"

F[1] = "../../VSPLIT/test/_colSC.bin"
F[2] = "../../VSPLIT/test/_colI2.bin"
F[3] = "../../VSPLIT/test/_colF4.bin"
F[4] = "../../VSPLIT/test/_colI8.bin"

nnF[1] = nil
nnF[2] = "../../VSPLIT/test/_nn_colI2.bin"
nnF[3] = "../../VSPLIT/test/_nn_colF4.bin"
nnF[4] = nil

qtypes[1] = "SC"
qtypes[2] = "I2"
qtypes[3] = "F4"
qtypes[4] = "I8"

widths[1] = 32 
widths[2] = nil
widths[3] = nil
widths[4] = nil

for i = 1, 4 do 
  print("Creating " .. names[i])
  local v = Q.load_bin({
    infile = F[i], 
    nnfile = nnF[i], 
    qtype = qtypes[i], 
    width = widths[i]}
    )
  assert(type(v) == "lVector")
  assert(v:qtype() == qtypes[i])
  if ( ( i == 1 ) or ( i == 4 ) )  then
    assert(v:has_nulls() == false)
  else
    assert(v:has_nulls() == true)
  end
  v:eval()
  v:pr()
  assert(v:num_elements() == 11)
  print("=================================")
end
print("Test load bin completed successfully")
