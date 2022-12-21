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

local function dfeds_report_prep(datafile, metafile) 
  assert(type(datafile) == "string")
  assert(type(metafile) == "string")

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
  
  local subs = {}
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
  
  local sum_t_plp1, n_plp1 = Q.sum(T.t_plp1):eval()
  local avg_t_plp1 = sum_t_plp1:to_num() / n_plp1:to_num()
  print("Time for plp1 =  ", avg_t_plp1)
  -- stats for plp2
  
  local t_plp2 = Q.where(T.t_plp2, x):eval()
  local sum_t_plp2, n_plp2 = Q.sum(t_plp2):eval()
  local avg_t_plp2 = sum_t_plp2:to_num() / n_plp2:to_num()
  print("Time for plp2 =  ", avg_t_plp2)
  
  local plp2_err_bmask = Q.where(T.plp2_err_bmask, x):eval()
  local nF = 5
  local zero = Q.const({val = 0, qtype = "I8", len = n}):eval()
  local mask = Q.const({val = 15, qtype = "I8", len = n}):eval()
  for i = 1, nF do
    local x = Q.shift_right(plp2_err_bmask, 4*(i-1))
    local y = Q.vvand(x, mask)
    local z = Q.sum(Q.vveq(y, zero))
    local n1, n2 = z:eval()
    print("Formula " .. i .. " succeeded " .. n1:to_num() .. " out of " .. 
      n2:to_num() .. " attempts")
  end

return subs
local metafile = 'Q/TESTS/HMAP/lua/in_meta'
local datafile = qcfg.q_src_root .. "/TESTS/HMAP/data/data1.csv"
local subs = dfeds_report_prep(datafile, metafile)
for k, v in pairs(subs) do print(k, v) end 

print("Completed test")
