local Q = require 'Q'
local get_nDR      = require 'Q/OPERATORS/MDB/lua/get_nDR'
local mk_mdb_input = require 'Q/OPERATORS/MDB/test/mk_mdb_input'
local mk_template  = require 'Q/OPERATORS/MDB/lua/mk_template'
local qconsts      = require 'Q/UTILS/lua/q_consts'
local qc           = require 'Q/UTILS/lua/q_core'
-- NOTE: We are using MAGG not AGG
local lAggregator  = require 'Q/RUNTIME/MAGG/lua/lAggregator'

local tests = {}
tests.t1 = function()
  assert(nil, "NEED TO REWRITE FOR NEW AGGREGATOR CREATION")
  local m = 256 * 1048576
  local Tk, n = mk_mdb_input.f1(m); assert(n)
  local nDR, vecs = get_nDR(Tk)
  local template, nR, nD, nC = mk_template(nDR)
  --=============================================
  local vtype = "F4"
  local val_vec = Q.seq({ start = 2, incr = 4, qtype = vtype, len = n}):memo(false):set_name("valvec")
  local key_vec, val_vec = Q.mk_comp_key_val(Tk,  val_vec)
  key_vec:set_name("ckeyvec")
  key_vec:memo(false)
  val_vec:set_name("cvalvec")
  val_vec:memo(false)

  local params = { initial_size = 65536, keytype = "I8", valtype = vtype}

  local A = lAggregator(params)
  assert(A:set_consume(key_vec, val_vec))
  t_start = qc.RDTSC()
  local iter = 0
  repeat 
    local x = A:consume()
  until x == 0 
  t_stop = qc.RDTSC()
  print("Time = ", t_stop - t_start)
  local M = A:get_meta()
  for k, v in pairs(M) do print(k, v) end 
  print("nK = ", key_vec:length())
  --=============================
  print("Success on test t1")
end
-- return tests
tests.t1()
os.exit()
