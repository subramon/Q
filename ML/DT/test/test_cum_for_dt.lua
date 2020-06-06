require 'Q/UTILS/lua/strict'
local cVector = require 'libvctr'
local Scalar  = require 'libsclr'
local lVector = require 'Q/RUNTIME/VCTR/lua/lVector'
local cum_for_dt = require 'Q/ML/DT/lua/cum_for_dt'
local pr         = require 'Q/OPERATORS/PRINT/lua/print_csv'

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
  local V, C = cum_for_dt(F, G, ng)
  assert(type(C) == "table")
  assert(#C == ng)
  for k, v in ipairs(C) do 
    assert(type(v) == "lVector")
  end
  V:eval()
  assert(V:length() == fval)
  -- pr(V)  
  for i = 1, fval do 
    assert(V:get1(i-1) == Scalar.new(i-1, "F4"))
  end
  local idx = 0
  while true do 
    if ( idx >= fval ) then break end 
    for to_repeat = min_repeat, max_repeat do 
      if ( idx >= fval ) then break end 
      local cnt = 0
      for k, v in ipairs(C) do 
        local x = v:get1(idx)
        assert(type(x) == "Scalar")
        cnt = cnt + x:to_num()
      end
      assert(cnt == to_repeat)
      idx = idx + 1
    end
  end
  print("Test t1 succeeded")
end
return tests
-- tests.t1()
