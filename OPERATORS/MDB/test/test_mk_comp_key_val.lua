local Q = require 'Q'
-- stand alone testing local mk_kv       = require 'Q/OPERATORS/MDB/lua/mk_comp_key_val'
local get_nDR     = require 'Q/OPERATORS/MDB/lua/get_nDR'
local mk_in       = require 'Q/OPERATORS/MDB/test/mk_mdb_input'
local mk_template = require 'Q/OPERATORS/MDB/lua/mk_template'
local qconsts     = require 'Q/UTILS/lua/q_consts'
local lAggregator = require 'Q/RUNTIME/AGG/lua/lAggregator'

local tests = {}
tests.t1 = function()
  local ns = {}
  ns[1] = 1024
  for i = 2, 20 do 
    ns[i] = ns[i-1] * 2 
  end
  for _, n in pairs(ns) do 
    local Tk, n = mk_in.f1(n); assert(n)
    local nDR, vecs = get_nDR(Tk)
    local template, nR, nD, nC = mk_template(nDR)
    --=============================================
    local val_vec = Q.seq({ start = 2, incr = 4, qtype = "F4", len = n})
  -- stand alone  local key_vec, val_vec = mk_kv(Tk,  val_vec)
    local key_vec, val_vec = Q.mk_comp_key_val(Tk,  val_vec)
    assert(type(key_vec) == "lVector")
    assert(type(val_vec) == "lVector")
    local chunk_idx = 0
    repeat 
      local n =   key_vec:chunk(chunk_idx)
      chunk_idx = chunk_idx + 1 
    until ( n == 0 )
    assert(key_vec:is_eov())
    assert(val_vec:is_eov())
    -- print(val_vec:length() ,n, nR)
    -- print(key_vec:length() ,n, nR)
    -- Q.print_csv({key_vec, val_vec})
    if ( (n * nR ) < qconsts.chunk_size ) then 
      assert(val_vec:length() == n * nR)
    end
    assert(key_vec:length() == val_vec:length())
    print("Success on test t1", n)
  end
  print("Success on test t1")
end

tests.t2 = function()
  local m = 32 * 1048576
  local Tk, n = mk_in.f1(m); assert(n)
  local nDR, vecs = get_nDR(Tk)
  local template, nR, nD, nC = mk_template(nDR)
  --=============================================
  local vtype = "F4"
  local val_vec = Q.seq({ start = 2, incr = 4, qtype = vtype, len = n})
  local key_vec, val_vec = Q.mk_comp_key_val(Tk,  val_vec)
  local update_type = "ADD"
  local params = { initial_size = 65536, keytype = "I8", valtype = vtype}
  local A = lAggregator(params)
  assert(A:set_consume(key_vec, val_vec))
  repeat 
    local x = A:consume()
  until x == 0 
  local M = A:get_meta()
  for k, v in pairs(M) do print(k, v) end 
  print("nK = ", key_vec:length())

  print("Success on test t2")
end
return tests
