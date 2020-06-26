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
local M = require 'Q/EVAN_REAS/data/meta2'
local O = require 'Q/EVAN_REAS/data/opt'
T = Q.load_csv(infile, M, O)
T.highAvgBPCombo:eval()
print("All done")
Q.save()
