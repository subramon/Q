local Q = require 'Q'
local cutils = require 'libcutils'
local F = {}

local F = {}
local nnF = {}
local qtypes = {}
local widths = {}
local names  = {}

names[1] = "colSC"
names[2] = "colI2"
names[3] = "colF4"
names[4] = "colI8"

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

for i = 1, 4 do -- 4 fields 
  print("Creating " .. names[i])
  local infiles = {}
  local nnfiles = nil
  for k = 1, 4 do  -- 4 part files 
    infiles[k] = "../../VSPLIT/test/_" .. tostring(k) .. 
      "_" .. names[i] .. ".bin"
    assert(cutils.isfile(infiles[k]))
  end
  -- create nn files 
  if ( ( i == 2 ) or ( i == 3 ) )  then
    nnfiles = {}
    for k = 1, 4 do  -- 4 part files 
      nnfiles[k] = "../../VSPLIT/test/_nn_" .. tostring(k) .. 
        "_" .. names[i] .. ".bin"
      assert(cutils.isfile(nnfiles[k]))
    end
  end
  for j, v in ipairs(infiles) do print(j, v) end 
  print("================")
  local v = Q.load_bin({
    infiles = infiles, 
    nnfiles = nnfiles,
    qtype = qtypes[i], 
    width = widths[i]}
    )
  assert(type(v) == "lVector")
  assert(v:qtype() == qtypes[i])
  if ( ( i == 2 ) or ( i == 3 ) )  then
    assert(v:has_nulls() == true)
  else
    assert(v:has_nulls() == false)
  end
  v:eval()
  v:pr()
  assert(v:num_elements() == 11)
  print("=================================")
end
print("Test load bin completed successfully")
