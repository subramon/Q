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
  -- This tests when 1 input chunk used to create all output chunks 
  collectgarbage("stop")
  local pre = lgutils.mem_used()
  local in_max_num_in_chunk = 64 
  local out_max_num_in_chunk = 2 * in_max_num_in_chunk
  local in_len =  16 * in_max_num_in_chunk
  local a = Q.seq({len = in_len, qtype = "I4", start = 1, by = 1}):early_freeable(1)
  local c = Q.period({len = in_len, qtype = "I1", start = 0, by = 1, period = 2}):early_freeable(1)
  local b = Q.vconvert(c, "BL")
  local x = Q.where(a, b, { max_num_in_chunk = out_max_num_in_chunk}):set_name("x")
  assert(x:qtype() == "I4")
  assert(x:max_num_in_chunk() == out_max_num_in_chunk)
  x:eval()
  assert(x:num_elements() == in_len/2)
  local chk_x = Q.seq({len = in_len/2, qtype = "I4", start = 2, by = 2, 
    max_num_in_chunk = out_max_num_in_chunk}):set_name("chk_x")
  local y = Q.vveq(x, chk_x):set_name("y")
  local r = Q.sum(y)
  local n1, n2 = r:eval()
  assert(n1 == n2)
  assert(cVector.check_all())
  a:delete()
  b:delete()
  c:delete()
  x:delete()
  y:delete()
  r:delete()
  local pre = lgutils.mem_used()
  collectgarbage("restart")
  print("Test where with early free completed")
end
tests.t2 = function ()
  -- This tests when >1 input chunk used to create 1 output chunk
  collectgarbage("stop")
  local pre = lgutils.mem_used()
  local in_max_num_in_chunk = 64 
  local out_max_num_in_chunk = 2 * in_max_num_in_chunk
  local in_len =  16 * in_max_num_in_chunk
  local a = Q.seq({len = in_len, qtype = "I4", start = 1, 
  by = 1, max_num_in_chunk = in_max_num_in_chunk}):set_name("a"):early_freeable(1)
  local c = Q.period({len = in_len, qtype = "I1", start = 0, 
    by = 1, period = 2, max_num_in_chunk = in_max_num_in_chunk}):set_name("c"):early_freeable(1)
  assert(c:max_num_in_chunk() == in_max_num_in_chunk)
  local b = Q.vconvert(c, "BL"):set_name("b"):early_freeable(1)
  assert(b:max_num_in_chunk() == in_max_num_in_chunk)
  local x = Q.where(a, b, { max_num_in_chunk = out_max_num_in_chunk}):set_name("x")
  assert(x:qtype() == "I4")
  assert(x:max_num_in_chunk() == out_max_num_in_chunk)
  x:eval()
  assert(x:num_elements() == in_len/2)
  local chk_x = Q.seq({len = in_len/2, qtype = "I4", start = 2, by = 2, 
    max_num_in_chunk = out_max_num_in_chunk}):set_name("chk_x")
  local y = Q.vveq(x, chk_x):set_name("y")
  local r = Q.sum(y)
  local n1, n2 = r:eval()
  assert(n1 == n2)
  assert(cVector.check_all())
  a:delete()
  b:delete()
  c:delete()
  x:delete()
  y:delete()
  r:delete()
  local pre = lgutils.mem_used()
  collectgarbage("restart")
  print("Test where with early free completed")
end
tests.t1()
tests.t2()
-- return tests
