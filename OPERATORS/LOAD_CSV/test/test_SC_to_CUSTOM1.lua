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
  assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
  local M = {}
  local O = { is_hdr = true }
  M[1] = { name = "str", qtype = "SC", width = 1024, has_nulls = false }
  local infile = qcfg.q_src_root .. 
    "/OPERATORS/LOAD_CSV/test/SC_to_CUSTOM1_in.csv"
  assert(plpath.isfile(infile))
  local T = Q.load_csv(infile, M, O)
  T.str:delete()
  assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
  print("Test t1 succeeded")
end
tests.t1()
-- return tests
