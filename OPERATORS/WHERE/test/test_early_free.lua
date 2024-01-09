-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q        = require 'Q'
local Scalar   = require 'libsclr'
local cVector  = require 'libvctr'
local lVector  = require 'Q/RUNTIME/VCTRS/lua/lVector'
local qcfg     = require 'Q/UTILS/lua/qcfg'
local max_num_in_chunk = qcfg.max_num_in_chunk 
local lgutils = require 'liblgutils'

local tests = {}
tests.t1 = function ()
  collectgarbage("stop")
  local pre = lgutils.mem_used()
  local in_max_num_in_chunk = 64 
  local out_max_num_in_chunk = 2 * in_max_num_in_chunk
  local in_len =  16 * in_max_num_in_chunk
  local a = Q.seq({len = in_len, qtype = "I4", start = 1, by = 1}):early_freeable(true)
  local c = Q.period({len = in_len, qtype = "I1", start = 0, by = 1, period = 2}):early_freeable(true)
  local b = Q.vconvert(c, "BL")
  local x = Q.where(a, b, { max_num_in_chunk = out_max_num_in_chunk})
  assert(x:qtype() == "I4")
  assert(x:max_num_in_chunk() == out_max_num_in_chunk)
  x:eval()
  assert(cVector.check_all())
  a:delete()
  b:delete()
  c:delete()
  x:delete()
  local pre = lgutils.mem_used()
  collectgarbage("restart")
  print("Test where with rearly free completed")
end
tests.t1()
-- return tests
