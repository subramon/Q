local Q = require 'Q'
local cutils = require 'libcutils'

local M = {}
M[#M+1] = { name = "colSC", qtype = "SC", width = 32, has_nulls = false, is_load = true}
M[#M+1] = { name = "colI2", qtype = "I2", has_nulls = true, is_load = true}
M[#M+1] = { name = "colI8", qtype = "I8", has_nulls = false, is_load = true}
M[#M+1] = { name = "colI4", qtype = "I4", has_nulls = false, is_load = false, }
M[#M+1] = { name = "colF4", qtype = "F4", has_nulls = true, is_load = true}

local F = {}
F[#F+1] = "./infile0.csv"
F[#F+1] = "./infile1.csv"
F[#F+1] = "./infile2.csv"
F[#F+1] = "./infile3.csv"

local opdir = "./"
assert(Q.vsplit(F, M, opdir))

for k, v in pairs(F) do 
  if ( M[k].is_load ) then 
    local fld = M[k].name
    local filename = "_" .. tostring(k) .. "_" .. fld .. ".bin"
    assert(cutils.isfile(filename), "File not found " .. filename)
  end
end
print("Test vsplit completed")
