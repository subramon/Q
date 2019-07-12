-- require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local tests = {}
local plfile = require 'pl.file'
local plpath = require 'pl.path'
--=======================================================
tests.t1 = function()
  local converter = require 'converter_1'
  local M = {}
  local O = { is_hdr = true }
  M[1] = { name = "day", qtype = "SC", width = 10, has_nulls = false }
  local datafile = "SC_to_XX_1.csv"
  local T = Q.new_load_csv(datafile, M, O)
  assert(type(converter) == "function")
  assert(type(T.day) == "lVector")
  d = Q.SC_to_XX(T.day, converter, "I4")
  assert(type(d) == "lVector")
  assert(d:fldtype() == "I4")
  d:eval() 
  -- check that min value is 1 and max value is 7
  local minval, n = Q.min(d):eval()
  local maxval, n = Q.max(d):eval()
  day = T.day
  print(minval, maxval)
  assert(minval:to_num() == 1 ) 
  assert(maxval:to_num() == 8 ) 
  -- Q.print_csv({ T.day, d}, { opfile = "_x.csv" } )
  print("Test t1 succeeded")
end
-- tests.t1()
-- os.exit()
return tests
