local plpath = require 'pl.path'
local cutils = require 'libcutils'
require 'Q/UTILS/lua/strict'
local qcfg = require 'Q/UTILS/lua/qcfg'
local Q = require 'Q'
local do_subs = require 'Q/UTILS/lua/do_subs'

local function mma(col, fld, subs)
  -- --TODO P1 Using fold for this purpose so that we don't scan input
  -- multiple times 
  assert(type(col) == "lVector")
  assert(type(subs) == "table")

  -- min/max/average number of rows
  local min, n  = Q.min(col):eval()
  local max, n  = Q.max(col):eval()
  local sum, n  = Q.sum(col):eval()
  local avg = sum:to_num() / n:to_num()
  print("Min/Max/Average for " .. fld )
  subs["__min_" .. fld .. "__"] = min:to_num()
  subs["__max_" .. fld .. "__"] = max:to_num()
  subs["__avg_" .. fld .. "__"] = avg
end

--[[

subs.__NumPLPErrorsB__ = 
subs.__AvgTimePLPB__ = 
--]]

local function dfeds_report_prep(datafile, metafile) 
  assert(type(datafile) == "string")
  assert(type(metafile) == "string")

  local subs = {}
  local O = { is_hdr = true }
  local M = require 'Q/TESTS/HMAP/lua/in_meta'
  local datafile = qcfg.q_src_root .. "/TESTS/HMAP/data/data1.csv"
  assert(plpath.isfile(datafile))
  local T = Q.load_csv(datafile, M, O)
  assert(type(T) == "table")
  T.tcin:eval()
  -- how many entries
  local n = T.tcin:num_elements()
  print("Number of data sets = " .. n)
  subs.__NumDataSets__  = n
  mma(T.num_rows_read, "num_rows_read", subs)
  
  -- stats for plp1 
  assert(type(T.plp1_error) == "lVector")
  local x = Q.vseq(T.plp1_error, 0)
  print(type(x))
  assert(type(x) == "lVector")
  local n_plp1_good, n2 = Q.sum(x):eval()
  print("Number of data sets where PLP1 succeded = " .. n_plp1_good:to_num())
  subs.__NumPLPSuccessA__ = n_plp1_good:to_num()
  subs.__NumPLPErrorsA__  = n2:to_num() - n_plp1_good:to_num()
  if ( n_plp1_good:to_num() < n2:to_num() ) then 
    local X = {}
    X[#X+1] = T.tcin
    X[#X+1] = T.dist_loc_i
    Q.print_csv(X, { where = Q.vnot(x), opfile = "plp1_failures.csv" })
  end 
  
  local sum_t_plp1, n_plp1 = Q.sum(T.t_plp1):eval()
  local avg_t_plp1 = sum_t_plp1:to_num() / n_plp1:to_num()
  print("Time for plp1 =  ", avg_t_plp1)
  subs.__AvgTimePLPA__ = avg_t_plp1
  -- distribution of errors for plp1
  local plp1_err_file = 
    qcfg.q_src_root .. "/TESTS/HMAP/doc/plp1_errors.tex"
  local nE1 = cutils.num_lines(plp1_err_file) - 1 

  local ecnt = Q.numby(T.plp1_error, nE1):eval()
  local plp1_err_cnt_file = 
    qcfg.q_src_root .. "/TESTS/HMAP/doc/plp1_error_count.csv"
  local fp = io.open(plp1_err_cnt_file, "w")
  for i = 1, nE1 do 
    local str = string.format("%d & %d \\\\ \\hline\n",
    i-1, ecnt:get1(i-1):to_num())
    fp:write(str)
  end
  fp:close()
  -- stats for plp2
  
  local t_plp2 = Q.where(T.t_plp2, x):eval()
  local sum_t_plp2, n_plp2 = Q.sum(t_plp2):eval()
  local avg_t_plp2 = sum_t_plp2:to_num() / n_plp2:to_num()
  print("Time for plp2 =  ", avg_t_plp2)
  subs.__AvgTimePLPB__ = avg_t_plp2
  
  local frmla_file = 
    qcfg.q_src_root .. "/TESTS/HMAP/doc/formula_explanations.tex"
  local nF = cutils.num_lines(frmla_file) - 1 
  subs.__NumFormulas__ = nF
  local zero = Q.const({val = 0, qtype = "I8", len = n}):eval()
  local mask = Q.const({val = 15, qtype = "I8", len = n}):eval()
  local plp2_err_bmask = Q.where(T.plp2_err_bmask, x):eval()
  local n1, n2 = Q.sum(Q.vvneq(plp2_err_bmask, zero)):eval()
  subs.__NumPLPErrorsB__ = n1:to_num()
  subs.__NumPLPAttemptsB__ = n2:to_num()

  local plp2_err_file = 
    qcfg.q_src_root .. "/TESTS/HMAP/doc/plp2_errors.tex"
  local nE2 = cutils.num_lines(plp2_err_file) - 1

  local plp2_err_cnt_fileB = 
    qcfg.q_src_root .. "/TESTS/HMAP/doc/plp2_error_countB.csv"
  local fpB = io.open(plp2_err_cnt_fileB, "w")

  local plp2_err_cnt_file = 
    qcfg.q_src_root .. "/TESTS/HMAP/doc/plp2_error_count.csv"
  local fp = io.open(plp2_err_cnt_file, "w")
  for i = 1, nF do
    local x = Q.shift_right(plp2_err_bmask, 4*(i-1))
    local y = Q.vvand(x, mask)
    local z = Q.sum(Q.vveq(y, zero))
    local n1, n2 = z:eval()
    local str = string.format("%d & %d & %d \\\\ \\hline \n",
      i-1, n2:to_num(), n1:to_num())
    fp:write(str)
    local ecnt = Q.numby(y, nE2):eval()
    assert(type(ecnt) == "lVector")
    assert(ecnt:is_eov())
    for j = 1, nE2 do 
      local str = string.format(" %d & %d & %d \\\\ \\hline\n",
      i-1, j-1, ecnt:get1(j-1):to_num())
      fpB:write(str)
    end
    fpB:write("\\hline \n")
  end
  fp:close()
  fpB:close()
  return subs
end
local infile = qcfg.q_src_root .. "/TESTS/HMAP/doc/dfeds_report.tex"
local outfile = qcfg.q_src_root .. "/TESTS/HMAP/doc/_dfeds_report.tex"
local metafile = 'Q/TESTS/HMAP/lua/in_meta'
local datafile = qcfg.q_src_root .. "/TESTS/HMAP/data/data1.csv"
local subs = dfeds_report_prep(datafile, metafile)
assert(type(subs) == "table")
for k, v in pairs(subs) do 
  assert(type(k) == "string")
  assert(( type(v) == "string") or ( type(v) == "number"), k)
end
-- ==============
assert(do_subs(infile, outfile, subs))

print("Completed test")
