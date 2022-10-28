_G['g_time'] = {}
_G['g_ctr']  = {}
require 'Q/UTILS/lua/strict'
local cVector = require 'libvctr'
local qcfg = require 'Q/UTILS/lua/qcfg'
local max_num_in_chunk = qcfg.max_num_in_chunk 
local mk_col   = require 'Q/OPERATORS/MK_COL/lua/mk_col'
local where    = require 'Q/OPERATORS/WHERE/lua/where'
local f_to_s   = require 'Q/OPERATORS/F_TO_S/lua/f_to_s'
local f1f2opf3 = require 'Q/OPERATORS/F1F2OPF3/lua/f1f2opf3'
where = where.where
local vveq = f1f2opf3.vveq
local sum  = f_to_s.sum

local tests = {}
tests.t1 = function()
  for _, b_qtype in ipairs({ "BL", "B1", }) do 
    for _, a_qtype in ipairs({ "I4", "I8", "F4", "F8"}) do
      local A = {}
      local n = max_num_in_chunk + 3 
      for i = 1, n do 
        A[i] = i
      end
      local B = {}
      for i = 1, n do 
        B[i] = 0
      end
      local goodC = {}
      local one_idxs = { 2, 4, chunk_size+1}
      for _, idx in ipairs(one_idxs) do
        B[idx] = 1
        goodC[#goodC+1] = A[idx]
      end
      local a = mk_col(A, a_qtype)
      local b = mk_col(B, b_qtype) 
      assert(type(a) == "lVector")
      assert(type(b) == "lVector")
      assert(a:length() == b:length())
      local c = where(a, b):eval()
      assert(c:length() == #goodC)
      local goodc = mk_col(goodC, qtype)
      local n1, n2 = sum(vveq(c, goodc)):eval()
      assert(n1 == n2)
    end
  end
end
return tests
