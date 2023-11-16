local cutils = require 'libcutils'
local plutils= require 'pl.utils'
local plfile = require 'pl.file'
local plpath = require 'pl.path'
require 'Q/UTILS/lua/strict'
local Q       = require 'Q'
local ffi     = require 'ffi'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local Scalar  = require 'libsclr'
local cVector = require 'libvctr'
local KeyCounter = require 'Q/RUNTIME/CNTR/lua/KeyCounter'
local qcfg    = require 'Q/UTILS/lua/qcfg'
local lgutils  = require 'liblgutils'
--=======================================================
local rootdir = assert(os.getenv("Q_SRC_ROOT")) 
local tests = {}
tests.t1 = function()
  local M = {}
  local O = { is_hdr = true }
  -- TODO P1 Test with different memo_len values 
  M[#M+1] = { name = "i8", qtype = "I8", memo_len = -1 }
  M[#M+1] = { name = "f4", qtype = "F4", memo_len = -1  }
  M[#M+1] = { name = "sc", qtype = "SC", width = 16, memo_len = -1  }
  local datafile = qcfg.q_src_root .. "/RUNTIME/CNTR/test/in1.csv"
  assert(plpath.isfile(datafile))
  local T = Q.load_csv(datafile, M, O)
  assert(type(T) == "table")
  assert(type(T.i8) == "lVector")
  -- convert to indexed table 
  local Tpr = {}
  Tpr[1] = T.i8
  Tpr[2] = T.f4
  Tpr[3] = T.sc
  -- clean out old stuff
  local label = "t1_i8_f4_sc"
  local opdir=rootdir .. "/TMPL_FIX_HASHMAP/KEY_COUNTER/" .. label 
  os.execute("rm -r -f " .. opdir)
  -- create a KeyCounter
  local optargs = {}
  optargs.label = label
  optargs.name  = "i8_f4_sc"
  local C = KeyCounter(Tpr, optargs)
  assert(type(C) == "KeyCounter")
  assert(C:size() > 0)
  assert(C:nitems() == 0)
  assert(C:label() == optargs.label)
  assert(C:name()  == optargs.name)
  assert(C:is_eor() == false)
  -- evaluate the KeyCounter
  assert(C:eval())
  -- get some items to make sure C is working well 
  -- Look for something that *IS there 
  local key, keytype, val, valtype, is_found, where_found = 
    C:get_val({123,456,"hello world 1"})
  key = ffi.cast(keytype .. " *", key)
  assert(key.key1 == 123)
  assert(key.key2 == 456)
  assert(ffi.string(key.key3) == "hello world 1")
  assert(C:nitems() == 3)
  -- TODO asserts on val  as well 
  val = ffi.cast(valtype .. " *", val)
  assert(val[0].count == 5)
  assert(val[0].guid == 1)
  --=================================================
  -- test map out functionality
  local len = T.sc:num_elements()
  local hidx = C:get_hidx(Tpr)
  assert(type(hidx) == "lVector")
  assert(hidx:qtype()  == "I4")
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
  -- Now use hidx to map out a few things 
  local chk_count = C:map_out(hidx, "count")
  assert(type(chk_count) == "lVector")
  assert(chk_count:qtype() == "UI4")
  chk_count:eval()
  print("XXXXXXX")
  local r = Q.min(chk_count); local min_count = r:eval()
  assert(min_count:to_num() > 0) -- TODO DIX 
  local r = Q.max(chk_count); local max_count = r:eval()
  assert(max_count:to_num() > 0) -- TODO DIX 
  --=================================================
  for k, v in pairs(T) do v:delete() end; T = nil ; Tpr = nil
  print("Test t1 succeeded")
end
tests.t1()
-- return tests
collectgarbage()
print("MEM", lgutils.mem_used())
print("DSK", lgutils.dsk_used())
assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
