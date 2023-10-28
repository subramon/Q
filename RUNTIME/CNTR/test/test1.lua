local plpath = require 'pl.path'
local Q = require 'Q'
local qcfg     = require 'Q/UTILS/lua/qcfg'
local KeyCounter = require 'Q/RUNTIME/CNTR/lua/KeyCounter'

local blksz = qcfg.max_num_in_chunk 
local tests = {}
tests.t1 = function(test_num)
  local label = "foobar_" .. tostring(test_num)
  local rootdir = assert(os.getenv("Q_SRC_ROOT")) 
  local opdir = rootdir .. "/TMPL_FIX_HASHMAP/KEY_COUNTER/" .. label 
  os.execute("rm -r -f " .. opdir)
  assert( not plpath.isdir(opdir))
  local len = 2 * blksz + 3 
  local vecs = {}
  if ( test_num == 1 ) then 
    vecs[1] = Q.const( {val = 1, qtype = "I4", len = len })
    vecs[2] = Q.const( {val = 1, qtype = "I4", len = len })
  elseif ( test_num == 2 ) then 
    vecs[1] = Q.seq( {start = 1, by = 1, qtype = "I4", len = len })
    vecs[2] = Q.seq( {start = 1, by = 1, qtype = "I4", len = len })
  else 
    error("XX")
  end
  local optargs = {}
  optargs.label = label
  optargs.name  = "test_" .. tostring(test_num)
  local C = KeyCounter(vecs, optargs)
  assert(type(C) == "KeyCounter")
  assert(C:nitems() == 0)
  assert(C:label() == optargs.label)
  assert(C:name()  == optargs.name)
  assert(C:is_eor() == false)
  C:eval()
  assert(C:is_eor() == true)
  if ( test_num == 1 ) then 
    assert(C:nitems() == 1)
  elseif ( test_num == 2 ) then 
    assert(C:nitems() == len)
  else 
    error("XX")
  end
  os.execute("rm -r -f " .. opdir) -- cleanup
  print("Test t1 successfully completed. Iteration ", test_num)
  return C
end
--=====================================================
tests.t_clone = function ()
  local C1 = tests.t1(1)
  local len = 2 * blksz + 3 
  local vecs = {}
  local p = 4
  vecs[1] = Q.period({start=1, by=1, period=p, qtype="I4", len=len })
  vecs[2] = Q.period({start=1, by=1, period=p, qtype="I4", len=len })
  local optargs = {}
  optargs.name = "clone_name"
  local C2 = C1:clone(vecs, optargs)
  assert(type(C2)    == "KeyCounter")
  assert(C2:nitems() == 0)
  assert(C2:label()  == C1:label())
  assert(C2:name()  == "clone_name")
  assert(C2:is_eor() == false)

  assert(C1:nitems() == 1)
  C2:eval()
  assert(C2:is_eor() == true)
  assert(C2:nitems() == p)

  assert(C1:nitems() == 1)
  C1:eval()
  assert(C1:is_eor() == true)
  assert(C1:nitems() == 1)
  print("Test t_clone successfully completed.")

end
--=====================================================
tests.t_delete = function()
  local C1 = tests.t1(1)
  collectgarbage()
  C1 = nil
  collectgarbage()
  print("Test t_delete successfully completed.")
end
tests.t1(1)
tests.t1(2)
tests.t_delete()
tests.t_clone()
collectgarbage()
--[[
--]]
os.exit() -- needed to avoid seg fault complaint
-- return tests
