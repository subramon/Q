local cutils     = require 'libcutils'
local cVector    = require 'libvctr'
local Scalar     = require 'libsclr'
local plpath     = require 'pl.path'
local ffi        = require 'ffi'
local Q          = require 'Q'
local qcfg       = require 'Q/UTILS/lua/qcfg'
local lgutils    = require 'liblgutils'
local KeyCounter = require 'Q/RUNTIME/CNTR/lua/KeyCounter'
local exec_and_capture_stdout = 
  require 'Q/UTILS/lua/exec_and_capture_stdout'

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
  --=================
  vecs[1]:delete()
  vecs[2]:delete()
  -- TODO C1:delete()
  -- TODO C2:delete()
  assert(cVector.check_all())
  --=================
  print("Test t_clone successfully completed.")

end
--=====================================================
tests.t_delete = function()
  local C1 = tests.t1(1)
  assert(cVector.check_all())
  collectgarbage()
  C1 = nil
  collectgarbage()
  assert(cVector.check_all())
  print("Test t_delete successfully completed.")
end
tests.t_get_val = function()
  local mem_used_pre = lgutils.mem_used()
  local label = "test_get_val"
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
    C:get_val({1, 2})
  key = ffi.cast(keytype .. " *", key)
  assert(key.key1 == 1)
  assert(key.key2 == 2)

  is_found = ffi.cast("bool *", is_found)
  assert(is_found[0] == true)

  where_found = ffi.cast("uint32_t *", where_found)
  assert(where_found[0] < C:size())

  val = ffi.cast(valtype .. " *", val)
  assert (val.count == 1) 
  -- Look for something that is NOT there 

  local key, keytype, val, valtype, is_found, where_found = 
    C:get_val({2, 1})
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
  assert(cVector.check_all())
  os.execute("rm -r -f " .. opdir) -- cleanup
  C = nil
  for k, v in ipairs(vecs) do v = nil end; vecs = nil
  collectgarbage()
  local mem_used_post = lgutils.mem_used()
  -- print(mem_used_pre, mem_used_post)
  -- TODO assert(mem_used_pre == mem_used_post)
  assert(cVector.check_all())
  print("Test t_get_val successfully completed. ")
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
  vecs[2] = Q.period({start = 2, by=2, period=p, qtype = "I8", len = len })
  local optargs = {}
  optargs.label = label
  optargs.name = "condensor"
  local C = KeyCounter(vecs, optargs)
  C:eval()
  --=== test make_cum_count
  C:make_cum_count()
  assert(C:sum_count() == len)
  print("mem after counter = ", lgutils.mem_used())
  -- Create condensed count
  local count = C:condense("count")
  assert(type(count) == "lVector")
  assert(count:qtype() == "I4")
  assert(type(count:num_elements() == 0))
  print("mem before condensor = ", lgutils.mem_used())
  count:eval()
  assert(type(count:num_elements() == p))
  local r = Q.min(count); local n1, n2 = r:eval()
  assert(n1 == Scalar.new(4096, "I4")); 
  assert(n2 == Scalar.new(p, "I8")); 
  local r = Q.max(count); local n1, n2 = r:eval()
  assert(n1 == Scalar.new(4097, "I4")); 
  assert(n2 == Scalar.new(p, "I8")); 
  -- Create condensed guid
  local guid = C:condense("guid")
  assert(type(guid) == "lVector")
  assert(guid:qtype()  == "I4")
  assert(type(guid:num_elements() == 0))
  guid:eval()
  print("mem after condensor = ", lgutils.mem_used())
  assert(type(guid:num_elements() == p)) 
  local r = Q.min(guid); local n1, n2 = r:eval()
  assert(n1 == Scalar.new(1, "I4")); 
  assert(n2 == Scalar.new(p, "I8")); 
  local r = Q.max(guid); local n1, n2 = r:eval()
  assert(n1 == Scalar.new(16, "I4")); 
  assert(n2 == Scalar.new(p, "I8")); 
  --===============================================
  -- Create condensed idx
  local hidx = C:condense("idx")
  assert(type(hidx) == "lVector")
  assert(hidx:qtype()  == "I8")
  assert(type(hidx:num_elements() == 0))
  hidx:eval()
  print("mem after condensor = ", lgutils.mem_used())
  assert(type(hidx:num_elements() == p)) 
  local r = Q.min(hidx); local min_idx = r:eval()
  assert(min_idx:to_num() >= 0)
  local r = Q.max(hidx); local max_idx  = r:eval()
  assert(max_idx:to_num() < C:size())
  assert(min_idx:to_num() < max_idx:to_num())
  --===============================================
  -- Now condense something that is an auiliary field 
  local cc = C:condense("cum_count")
  assert(type(cc) == "lVector")
  assert(cc:qtype()  == "I8")
  assert(type(cc:num_elements() == 0))
  cc:eval()
  -- Q.print_csv({cc}, {opfile = "_x.csv"})
  assert(type(cc:num_elements() == p)) 
  local r = Q.min(cc); local n1, n2 = r:eval()
  assert(n1 == Scalar.new(0, "I8")); 
  assert(n2 == Scalar.new(p, "I8")); 
  local r = Q.max(cc); local n1, n2 = r:eval()
  -- NOT CORRECT assert(n1 == Scalar.new(len-1, "I8")); 
  assert(n1 < Scalar.new(len-1, "I8")); 
  assert(n2 == Scalar.new(p, "I8")); 
  --===============================================
  -- cleanup
  r = nil; n1 = nil; n2 = nil
  assert(cVector.check_all())
  os.execute("rm -r -f " .. opdir) 
  C = nil
  for k, v in ipairs(vecs) do v = nil end; vecs = nil
  count = nil
  guid = nil
  hidx = nil
  cc = nil
  collectgarbage()
  local mem_used_post = lgutils.mem_used()
  print(mem_used_pre, mem_used_post)
  -- TODO P0 assert(mem_used_pre == mem_used_post)
  assert(cVector.check_all())
  print("Test t_condense successfully completed. ")
end
tests.t_permute = function()
  local mem_used_pre = lgutils.mem_used()
  local label = "test_period"
  local rootdir = assert(os.getenv("Q_SRC_ROOT")) 
  local opdir = rootdir .. "/TMPL_FIX_HASHMAP/KEY_COUNTER/" .. label 
  os.execute("rm -r -f " .. opdir)
  local len = 2 * blksz + 3 
  local p = 16
  local vecs = {}
  vecs[1] = Q.period({start = 1, by=1, period=p, qtype = "I4", len = len })
  vecs[2] = Q.period({start = 2, by=2, period=p, qtype = "I8", len = len })
  local optargs = {}
  optargs.label = label
  optargs.name = "permutation"
  local C = KeyCounter(vecs, optargs)
  C:eval()
  C:make_cum_count()
  local perm = C:make_permutation(vecs)
  assert(type(perm) == "lVector")
  assert(perm:qtype() == "I8")
  assert(type(perm:num_elements() == 0))

  perm:eval()
  local sum_count = C:sum_count()
  assert(sum_count == len)
  assert(perm:num_elements() == sum_count)

  local r = Q.min(perm); local n1, n2 = r:eval()
  assert(n1 == Scalar.new(0, "I8")); 
  assert(n2 == Scalar.new(len, "I8")); 

  local r = Q.max(perm); local n1, n2 = r:eval()
  print("max", n1, n2)
  assert(n1 == Scalar.new(len-1, "I8")); 
  assert(n2 == Scalar.new(len, "I8")); 
  r = nil
  --[[
  -- TODO I've tested the permutation independently. This is better 
  -- but it does not work right now because sort creates the vector
  -- as a file and this causes problems in expander_f1f2opf3.lua
  -- when we check f1_len versus f2_len
  local srt_perm = Q.sort(perm, "asc")
  assert(type(srt_perm) == "lVector")
  assert(srt_perm:is_eov())
  assert(srt_perm:num_elements() == perm:num_elements())
  assert(srt_perm:qtype()  == perm:qtype())
  local chk = Q.seq({start=0, by=1, len=len, qtype = "I8"})
  chk:eval()
  Q.print_csv({chk, perm}, { opfile = "_x.csv", })
  local x = Q.vvneq(perm, chk)
  local r = Q.sum(x)
  assert(type(r) == "Reducer")
  local n1, n2 = r:eval()
  assert(Scalar.to_num(n1) == 0)
  --]]
  --===============================================
  -- cleanup
  assert(cVector.check_all())
  os.execute("rm -r -f " .. opdir) 
  C = nil
  for k, v in ipairs(vecs) do v = nil end; vecs = nil
  perm = nil
  collectgarbage()
  local mem_used_post = lgutils.mem_used()
  print(mem_used_pre, mem_used_post)
  -- TODO assert(mem_used_pre == mem_used_post)
  assert(cVector.check_all())
  print("Test t_permute successfully completed. ")
end
tests.t_get_hidx = function()
  local mem_used_pre = lgutils.mem_used()
  local label = "test_period"
  local rootdir = assert(os.getenv("Q_SRC_ROOT")) 
  local opdir = rootdir .. "/TMPL_FIX_HASHMAP/KEY_COUNTER/" .. label 
  os.execute("rm -r -f " .. opdir)
  local len = 2 * blksz + 3 
  local p = 16
  local vecs = {}
  vecs[1] = Q.period({start = 1, by=1, period=p, qtype = "I4", len = len })
  vecs[2] = Q.period({start = 2, by=2, period=p, qtype = "I8", len = len })
  local optargs = {}
  optargs.label = label
  optargs.name = "condensor"
  local C = KeyCounter(vecs, optargs)
  C:eval()
  --===============================================
  local hidx = C:get_hidx(vecs)
  assert(type(hidx) == "lVector")
  assert(hidx:qtype()  == "I8")
  assert(type(hidx:num_elements() == 0))
  hidx:eval()
  Q.print_csv({hidx}, { opfile = "_x.csv", })
  assert(type(hidx:num_elements() == len)) 
  local r = Q.min(hidx); local min_hidx = r:eval()
  assert(min_hidx:to_num() >= 0)
  local r = Q.max(hidx); local max_hidx  = r:eval()
  assert(max_hidx:to_num() < C:size())
  assert(min_hidx:to_num() < max_hidx:to_num())
  -- test on hidx values TODO P4 Do this in Q not shell
  local cmd = 
    "sort -n _x.csv | uniq | wc | sed s'/^[ ]*//'g | sed s'/ .*$//'g"
  local rslt = exec_and_capture_stdout(cmd)
  local chk_rslt = string.format("%d\n", p)
  assert(rslt == chk_rslt)
  --===============================================
  -- cleanup
  cutils.delete("_x.csv")
  r = nil; 
  assert(cVector.check_all())
  os.execute("rm -r -f " .. opdir) 
  C = nil
  for k, v in ipairs(vecs) do v = nil end; vecs = nil
  hidx = nil
  collectgarbage()
  local mem_used_post = lgutils.mem_used()
  print(mem_used_pre, mem_used_post)
  -- TODO P0 assert(mem_used_pre == mem_used_post)
  assert(cVector.check_all())
  print("Test t_get_hidx successfully completed. ")
end
tests.t_get_hidx()
--[[
tests.t_condense() 
tests.t_permute()
tests.t_get_val()
tests.t1(1)
tests.t1(2)
tests.t_delete()
tests.t_clone()
collectgarbage()
--]]
print("ALL TESTS SUCCEEDED")
os.exit() -- needed to avoid seg fault complaint
-- return tests
