local plpath     = require 'pl.path'
local ffi        = require 'ffi'
local Q          = require 'Q'
local qcfg       = require 'Q/UTILS/lua/qcfg'
local lgutils    = require 'liblgutils'
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
  assert(C:size() > 0)
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
  assert(C:nitems() < C:size())
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
tests.t_get_count = function()
  local mem_used_pre = lgutils.mem_used()
  local label = "test_get_count"
  local rootdir = assert(os.getenv("Q_SRC_ROOT")) 
  local opdir = rootdir .. "/TMPL_FIX_HASHMAP/KEY_COUNTER/" .. label 
  os.execute("rm -r -f " .. opdir)
  local len = 2 * blksz + 3 
  local vecs = {}
  vecs[1] = Q.seq( {start = 1, by = 1, qtype = "I4", len = len })
  vecs[2] = Q.seq( {start = 2, by = 2, qtype = "F4", len = len })
  local optargs = {}
  optargs.label = label
  local C = KeyCounter(vecs, optargs)
  C:eval()
  -- Look for something that *IS there 
  local key, keytype, val, valtype, is_found, where_found = 
    C:get_count({1, 2})
  key = ffi.cast(keytype .. " *", key)
  assert(key.key1 == 1)
  assert(key.key2 == 2)

  is_found = ffi.cast("bool *", is_found)
  assert(is_found[0] == true)

  where_found = ffi.cast("uint32_t *", where_found)
  assert(where_found[0] < C:size())

  val = ffi.cast(valtype .. " *", val)
  assert (val.count == 1) -- TODO P0 This is wrong
  -- Look for something that is NOT there 

  local key, keytype, val, valtype, is_found, where_found = 
    C:get_count({2, 1})
  key = ffi.cast(keytype .. " *", key)
  assert(key.key1 == 2)
  assert(key.key2 == 1)

  is_found = ffi.cast("bool *", val)
  assert(is_found[0] == false)

  where_found = ffi.cast("uint32_t *", val)
  assert(where_found[0] == 0) 

  val = ffi.cast(valtype .. " *", val)
  assert(val.count == 0) 

  --===============================================
  -- test sum_count
  local sum_count = C:sum_count()
  assert(sum_count == len)
  --===============================================
  os.execute("rm -r -f " .. opdir) -- cleanup
  C = nil
  for k, v in ipairs(vecs) do v = nil end; vecs = nil
  collectgarbage()
  local mem_used_post = lgutils.mem_used()
  -- print(mem_used_pre, mem_used_post)
  assert(mem_used_pre == mem_used_post)
  print("Test t_get_count successfully completed. ")
end
tests.t_condense = function()
  local mem_used_pre = lgutils.mem_used()
  local label = "test_period"
  local rootdir = assert(os.getenv("Q_SRC_ROOT")) 
  local opdir = rootdir .. "/TMPL_FIX_HASHMAP/KEY_COUNTER/" .. label 
  os.execute("rm -r -f " .. opdir)
  local len = 2 * blksz + 3 
  local p = 16
  local vecs = {}
  vecs[1] = Q.period({start = 1, by=1, period=p, qtype = "I4", len = len })
  vecs[2] = Q.period({start = 2, by=2, period=p, qtype = "F4", len = len })
  local optargs = {}
  optargs.label = label
  local C = KeyCounter(vecs, optargs)
  C:eval()
  -- Look for something that *IS there 
  local count, guid = C:condense()
  assert(type(count) == "lVector")
  assert(type(guid) == "lVector")

  assert(type(count:num_elements() == 0))
  count:eval()
  assert(type(count:num_elements() == p))
  
  assert(type(guid:num_elements() == 0))
  guid:eval()
  assert(type(guid:num_elements() == p)) 
  --===============================================
  os.execute("rm -r -f " .. opdir) -- cleanup
  C = nil
  for k, v in ipairs(vecs) do v = nil end; vecs = nil
  collectgarbage()
  local mem_used_post = lgutils.mem_used()
  -- print(mem_used_pre, mem_used_post)
  assert(mem_used_pre == mem_used_post)
  print("Test t_condense successfully completed. ")
end
tests.t_condense()
--[[
tests.t_get_count()
tests.t1(1)
tests.t1(2)
tests.t_delete()
tests.t_clone()
--]]
collectgarbage()
--[[
--]]
os.exit() -- needed to avoid seg fault complaint
-- return tests
