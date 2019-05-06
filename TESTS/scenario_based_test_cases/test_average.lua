-- Calculating average and adding it to the attached csv file
local Q = require 'Q'
require 'Q/UTILS/lua/strict'
local plpath= require 'pl.path'

local tests = {}
tests.t1 = function ()
  local datadir = os.getenv("Q_SRC_ROOT") .. "/TESTS/scenario_based_test_cases/"
  local datafilename = datadir .. "test.csv"
  plpath.isfile(datafilename)

  local metafilename = datadir .. "meta.lua"
  plpath.isfile(metafilename)

  local M = dofile(metafilename)
  assert(type(M) == "table")
  local x = Q.load_csv(datafilename, M, {use_accelerator = false})
  local y = Q.vvadd(x["eng"], x["phy"])
  local a = Q.mk_col({2, 2, 2, 2}, "I4")
  local b = Q.vvdiv(y, a)
  x[#x + 1] = b:eval()
  local opt_args = {
                     opfile = "average.csv"
	           }
  Q.print_csv(x, opt_args)
end
--======================================
return tests
