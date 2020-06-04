require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local plpath = require 'pl.path'
local infile = assert(arg[1], "Supply data file")
local threshold = assert(arg[2], "Supply threshold")
threshold = assert(tonumber(threshold))
assert(plpath.isfile(infile))
assert(type(threshold) == "number")
assert(threshold >= 10)
-- define meta data
local M = {}
local O = { is_hdr = true }
local num_cols = 14
for i = 1, num_cols do 
  local name = "x" .. tostring(i)
  M[i] = { name = name, qtype = "F4", is_memo= true, is_persist = true }
end
M[#M+1] = { name = "goal", qtype = "I4", is_memo= true, is_persist = true }
T = Q.load_csv(infile, M, O)
T.goal:eval()
print("All done")
Q.save()
