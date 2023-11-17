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
tests.t_permute = function()
  local mem_used_pre = lgutils.mem_used()
  local label = "test_permute"
  local rootdir = assert(os.getenv("Q_SRC_ROOT")) 
  local opdir = rootdir .. "/TMPL_FIX_HASHMAP/KEY_COUNTER/" .. label 
  os.execute("rm -r -f " .. opdir)
  -- START load data 
  local M = {}
  local O = { is_hdr = true }
  -- TODO P1 Test with different memo_len values 
  M[#M+1] = { name = "sc", qtype = "SC", width = 16, memo_len = -1  }
  M[#M+1] = { name = "i1", qtype = "I1", memo_len = -1 }
  local datafile = qcfg.q_src_root .. "/RUNTIME/CNTR/test/in2.csv"
  assert(plpath.isfile(datafile))
  local T = Q.load_csv(datafile, M, O)
  assert(type(T) == "table")
  assert(type(T.i1) == "lVector")
  -- convert to indexed table 
  local Tpr = {}
  Tpr[1] = T.sc
  Tpr[2] = T.i1
  T.i1:eval()
  Q.print_csv(Tpr, { opfile = "_x.csv", })
  -- STOP  load data 
  -- START: Create KeyCounter
  local optargs  = {}
  optargs.label = label
  optargs.name  = "t_permute"
  local C = assert(KeyCounter(Tpr, optargs))
  C:eval()
  -- STOP : Create KeyCounter
  -- START: Make permutation 
  local perm = C:make_permutation(Tpr):eval()
  Q.print_csv(perm, { opfile = "_perm.csv", })

  local count = C:condense("count"):eval()
  local guid = C:condense("guid"):eval()
  Q.print_csv({count, guid}, { opfile = "_count_guid.csv", })
  -- STOP : Make permutation 
  -- START: Make hidx 
  local hidx = C:get_hidx(Tpr):eval()
  Q.print_csv(hidx, { opfile = "_hidx.csv", })
  local n1, n2 = Q.min(hidx):eval()
  assert(n1:to_num() >= 0)
  local n1, n2 = Q.max(hidx):eval()
  assert(n1:to_num() < C:size())
  -- START map out
  local len = hidx:num_elements()
  local chk_count = C:map_out(hidx, "count"):eval()
  assert(type(chk_count) == "lVector")
  assert(chk_count:qtype() == "UI4")

  local chk_guid  = C:map_out(hidx, "guid"):eval()
  assert(type(chk_guid) == "lVector")
  assert(chk_guid:qtype() == "UI4")

  local r = Q.min(chk_count)
  local n1, n2 = r:eval()
  assert(n1:to_num() == 1)

  local r = Q.max(chk_count)
  local n1, n2 = r:eval()
  assert(n1:to_num() == 4)

  local r = Q.min(chk_guid)
  local n1, n2 = r:eval()
  assert(n1:to_num() == 1)

  local r = Q.max(chk_guid)
  local n1, n2 = r:eval()
  assert(n1:to_num() == C:nitems())

  Q.print_csv({chk_count, chk_guid}, { opfile = "_chk_count_guid.csv", })
  --==================================================================
  local bogus_hidx = Q.const({qtype = "I4", len = len, val = 0})
  local bogus_count = C:map_out(bogus_hidx, "count"):eval()
  local bogus_guid = C:map_out(bogus_hidx, "guid"):eval()
  Q.print_csv({bogus_count, bogus_guid}, { opfile = "_bogus_count_guid.csv", })
  local r = Q.min(bogus_count)
  local n1, n2 = r:eval()
  assert(n1:to_num() == 0)

  local r = Q.max(bogus_count)
  local n1, n2 = r:eval()
  assert(n1:to_num() == 0)

  local r = Q.min(bogus_guid)
  local n1, n2 = r:eval()
  assert(n1:to_num() == 0)

  local r = Q.max(bogus_guid)
  local n1, n2 = r:eval()
  assert(n1:to_num() == 0)
  -- STOP  map out

  -- cleanup
  C = nil; for k, v in pairs(T) do v = nil end; T = nil
  collectgarbage()
  local mem_used_post = lgutils.mem_used()
  print(mem_used_pre, mem_used_post)
  -- TODO P0 assert(mem_used_pre == mem_used_post)
  assert(cVector.check_all())
  print("Test t_permute successfully completed. ")
end
tests.t_permute()
