local plpath = require 'pl.path'
require 'Q/UTILS/lua/strict'
local qcfg = require 'Q/UTILS/lua/qcfg'
local Q = require 'Q'

local function mma(col, fld)
  assert(type(col) == "lVector")

  -- min/max/average number of rows
  local min, n  = Q.min(col):eval()
  local max, n  = Q.max(col):eval()
  local sum, n  = Q.sum(col):eval()
  local avg = sum:to_num() / n:to_num()
  print("Min/Max/Average for " .. fld )
  print(min)
  print(max)
  print(avg)
end

local O = { is_hdr = true }
local M = require 'Q/TESTS/HMAP/lua/in_meta'
local datafile = qcfg.q_src_root .. "/TESTS/HMAP/data/data1.csv"
assert(plpath.isfile(datafile))
local T = Q.load_csv(datafile, M, O)
assert(type(T) == "table")
T.tcin:eval()
-- for k, v in pairs(T) do print(k, type(v)) end
-- how many entries
local n = T.tcin:num_elements()
print("Number of data sets = " .. n)
mma(T.num_rows_read, "num_rows_read")
-- Using fold for this purpose so that we don't scan input
-- multiple times 
-- TODO P1

-- stats for plp1 
assert(type(T.plp1_error) == "lVector")
local x = Q.vseq(T.plp1_error, 0)
print(type(x))
assert(type(x) == "lVector")
local n_plp1_good, n2 = Q.sum(x):eval()
print("Number of data sets where PLP1 succeded = " .. n_plp1_good:to_num())
if ( n_plp1_good:to_num() < n2:to_num() ) then 
  local X = {}
  X[#X+1] = T.tcin
  X[#X+1] = T.dist_loc_i
  Q.print_csv(X, { where = Q.vnot(x), opfile = "plp1_failures.csv" })
end 

local t_plp1, n2 = Q.sum(T.t_plp1):eval()
print("Time for plp1 =  ", t_plp1:to_num() / n2:to_num())

print("Completed test")
