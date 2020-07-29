_G['g_time'] = {}
_G['g_ctr']  = {}
require 'Q/UTILS/lua/strict'
local cVector = require 'libvctr'
local chunk_size = cVector.chunk_size()
local mk_col   = require 'Q/OPERATORS/MK_COL/lua/mk_col'
local where    = require 'Q/OPERATORS/WHERE/lua/where'
local f_to_s   = require 'Q/OPERATORS/F_TO_S/lua/f_to_s'
local f1f2opf3 = require 'Q/OPERATORS/F1F2OPF3/lua/f1f2opf3'
where = where.where
local vveq = f1f2opf3.vveq
local sum  = f_to_s.sum

local tests = {}
tests.t1 = function()
  local qtypes = { "I4", "I8", "F4", "F8"}
  for _, qtype in ipairs(qtypes) do 
    local A = {}
    for i = 1, chunk_size + 17  do
      A[i] = i
    end
    local B = {}
    for i = 1, chunk_size + 17  do
      B[i] = 0
    end
    local goodC = {}
    local one_idxs = { 2, 4, chunk_size+1}
    for _, idx in ipairs(one_idxs) do
      B[idx] = 1
      goodC[#goodC+1] = A[idx]
    end
    local a = mk_col(A, qtype)
    local b = mk_col(B, "B1")
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
return tests
