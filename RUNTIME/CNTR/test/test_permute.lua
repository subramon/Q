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
