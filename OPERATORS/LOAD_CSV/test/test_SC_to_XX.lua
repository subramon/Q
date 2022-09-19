local plpath    = require 'pl.path'
local plfile    = require 'pl.file'
require 'Q/UTILS/lua/strict'
local Q         = require 'Q'
local qcfg      = require 'Q/UTILS/lua/qcfg'
local converter = require 'Q/OPERATORS/LOAD_CSV/test/converter_1'
--=======================================================
local tests = {}
tests.t1 = function()
  local M = {}
  local O = { is_hdr = true }
  M[1] = { name = "day", qtype = "SC", width = 10, has_nulls = false }
  local infile = qcfg.q_src_root .. 
    "/OPERATORS/LOAD_CSV/test/SC_to_XX_1_in.csv"
  assert(plpath.isfile(infile))
  local T = Q.load_csv(infile, M, O)
  assert(type(converter) == "function")
  assert(type(T.day) == "lVector")
  local d = Q.SC_to_XX(T.day, converter, "I4")
  assert(type(d) == "lVector")
  assert(d:qtype() == "I4")
  d:eval() 
  -- check results
  local outfile = qcfg.q_src_root .. 
    "/OPERATORS/LOAD_CSV/test/SC_to_XX_1_out.csv"
  local tmpfile = "/tmp/_SC_to_XX_1.csv"
  d:pr(tmpfile)
  local x = plfile.read(tmpfile)
  local y = plfile.read(outfile)
  assert(x == y)
  print("Test t1 succeeded")
end
tests.t1()
--[[
return tests
os.exit()
--]]
