local plpath    = require 'pl.path'
local plfile    = require 'pl.file'
require 'Q/UTILS/lua/strict'
local Q         = require 'Q'
local qcfg      = require 'Q/UTILS/lua/qcfg'
local cVector = require 'libvctr'
local lgutils = require 'liblgutils'
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
  T.day:eval()
  assert(T.day:num_elements() == 1200000)
  local d = Q.SC_to_XX(T.day, converter, "I4", { name = "d"})
  assert(type(d) == "lVector")
  assert(d:qtype() == "I4")
  d:eval() 
  assert(d:num_elements() == 1200000)
  local num_vectors = cVector.count()
  assert(num_vectors == 2) -- T.day and d 
  print("num_vectors = " , num_vectors)
  -- check results
  local outfile = qcfg.q_src_root .. 
    "/OPERATORS/LOAD_CSV/test/SC_to_XX_1_out.csv"
  local tmpfile = "/tmp/_SC_to_XX_1.csv"
  d:pr(tmpfile)
  local x = plfile.read(tmpfile)
  local y = plfile.read(outfile)
  assert(x == y)
  assert(cVector.check_all())
  local num_vectors = cVector.count(); assert(num_vectors == 2) 
  d:delete()
  local num_vectors = cVector.count(); assert(num_vectors == 1) 
  T.day:delete()
  local num_vectors = cVector.count(); assert(num_vectors == 0) 
  print("Test t1 succeeded")
end
tests.t1()
collectgarbage()
print("MEM", lgutils.mem_used())
print("DSK", lgutils.dsk_used())
assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
-- return tests
