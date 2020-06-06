require 'Q/UTILS/lua/strict'
local cVector = require 'libvctr'
local Scalar  = require 'libsclr'
local lVector = require 'Q/RUNTIME/VCTR/lua/lVector'
local foo     = require 'Q/ML/DT/lua/expander_cum_for_dt'
local pr      = require 'Q/OPERATORS/PRINT/lua/print_csv'

_G['g_time']  = {}
_G['g_ctr']  = {}

local chunk_size = cVector.chunk_size()

local tests = {}
tests.t1 = function()
  local nF = 4 * chunk_size + 37;
  local ng = 2;
  local F = lVector({ qtype = "F4"})
  local G = lVector({ qtype = "I4"})
  
  local min_repeat = 1;
  local max_repeat = 8;
   
  local to_repeat = min_repeat;
  local num_in_F = 0;
  local fval = 0;
  local num_unique_F = 0
  while num_in_F < nF do 
    for to_repeat = min_repeat, max_repeat do 
      for i = 1, to_repeat do
        F:put1(Scalar.new(fval, "F4"))
        local gval = math.ceil(math.random() *1000000 ) % ng
        G:put1(Scalar.new(gval, "I4"))
        num_in_F = num_in_F + 1 
      end
      fval = fval + 1
    end
  end
  F:eov()
  G:eov()
  assert(F:length() >= nF)
  assert(G:length() >= nF)
  -- pr({F, G})
  local H = foo(F, G, ng)
  H:eval()
  assert(H:length() == fval)
  -- pr(H)  
end
-- return tests
tests.t1()
