require 'Q/UTILS/lua/strict'
local plpath    = require 'pl.path'
local Q         = require 'Q'
local qconsts   = require 'Q/UTILS/lua/q_consts'
local converter = require 'Q/OPERATORS/LOAD_CSV/test/converter_1'
--=======================================================
local tests = {}
tests.t1 = function()
  local M = {}
  local O = { is_hdr = true }
  M[1] = { name = "day", qtype = "SC", width = 10, has_nulls = false }
  local datafile = qconsts.Q_SRC_ROOT .. 
    "/OPERATORS/LOAD_CSV/test/SC_to_XX_1.csv"
  assert(plpath.isfile(datafile))
  local T = Q.load_csv(datafile, M, O)
  assert(type(converter) == "function")
  assert(type(T.day) == "lVector")
  local d = Q.SC_to_XX(T.day, converter, "I4")
  assert(type(d) == "lVector")
  assert(d:fldtype() == "I4")
  d:eval() 
  -- check that min value is 1 and max value is 7
  local minval, n = Q.min(d):eval()
  local maxval, n = Q.max(d):eval()
  local day = T.day
  print(minval, maxval)
  assert(minval:to_num() == 1 ) 
  assert(maxval:to_num() == 8 ) 
  -- Q.print_csv({ T.day, d}, { opfile = "_x.csv" } )
  print("Test t1 succeeded")
end
--[[
tests.t1()
os.exit()
--]]
return tests
