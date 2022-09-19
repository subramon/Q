local plfile = require 'pl.file'
local strict = require 'Q/UTILS/lua/strict'
local Scalar  = require 'libsclr'
local lVector = require 'Q/RUNTIME/VCTRS/lua/lVector'
local qcfg    = require 'Q/UTILS/lua/qcfg'
local max_num_in_chunk = qcfg.max_num_in_chunk

local tests = {}
tests.t1 = function()
  local x, y = lVector({ qtype = "F4"})
  local n = 2 * max_num_in_chunk + 1 
  for i = 1, n do 
    x:put1(Scalar.new(i, "F4"))
  end
  x:eov()
  assert(x:num_elements() == n)
  local chkfile = "_x"
  local dir = qcfg.q_src_root .. "/RUNTIME/VCTRS/test/"
  local outfile = dir .. "/test_put_out1.csv"
  x:pr(chkfile)

  local chk1 = plfile.read(chkfile)
  local chk2 = plfile.read(outfile)
  assert(chk1 == chk2)
  assert(x:check(true, true)) -- checking on all vectors

  print("Test t1 succeeded")
end
-- return tests
tests.t1()

