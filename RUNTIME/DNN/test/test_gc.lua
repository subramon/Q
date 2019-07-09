local Q = require 'Q'
local lDNN = require 'Q/RUNTIME/DNN/lua/lDNN'
require 'Q/UTILS/lua/strict'

local tests = {}
tests.t1 = function(n)
  local n = n or 100000000
  -- this is a ridiculously large number of layers

  local npl = {}
  local dpl = {}
  local nl = 64
  for i = 1, nl do npl[i] = nl - i + 1 end
  for i = 1, nl do dpl[i] = 1.0 / ( 1.0 + 1 + i) end

  for i = 1, n do 
    local x = lDNN.new({ npl = npl})
    assert(type(x) == "lDNN")
    if ( ( i % 1000 ) == 0 )  then
      print("Iterations " .. i)
    end
  end
  print("Success on test t1")
end
--========================================
tests.t2 = function(n)
  local n = n or 100000000
  local Xin = {}; 
    Xin[1] = Q.mk_col({1, 2, 3, 4, 5, 6, 7}, "F4"):eval()
    Xin[2] = Q.mk_col({10, 20, 30, 40, 50, 60, 70}, "F4"):eval()
    Xin[3] = Q.mk_col({100, 200, 300, 400, 500, 600, 700}, "F4"):eval()
  local Xout = {}; 
    Xout[1] = Q.mk_col({0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7}, "F4"):eval()

  local npl = {}
  npl[1] = 3
  npl[2] = 4
  npl[3] = 1
  local dpl = {}
  dpl[1] = 0.5
  dpl[2] = 0.5
  dpl[3] = 0
  local afns = {}
  afns[1] = ""
  afns[2] = "sigmoid"
  afns[3] = "sigmoid"
  local x = lDNN.new({ npl = npl, dpl = dpl, activation_functions = afns} )
  assert(x:check())
  for i = 1, n do 
    x:set_io(Xin, Xout)
    x:set_batch_size(i+1)
    assert(x:check())
    assert(x:check())
    if ( ( i % 1000 ) == 0 )  then
      print("Iterations " .. i)
    end
    x:fit()
    x:unset_io()
    x:delete()
  end
  print("Success on test t2")
end
tests.t3 =  function(n)
  local n = n or 100000000
  local Xin = {}
  local Xout = {}; 
  for i = 1, n do 
    Xin[1] = Q.mk_col({1, 2, 3, 4, 5, 6, 7}, "F4"):eval()
    Xin[2] = Q.mk_col({10, 20, 30, 40, 50, 60, 70}, "F4"):eval()
    Xin[3] = Q.mk_col({100, 200, 300, 400, 500, 600, 700}, "F4"):eval()
    Xout[1] = Q.mk_col({0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7}, "F4"):eval()
    if ( ( i % 1000 ) == 0 )  then
      print("Iterations " .. i)
    end
  end
end
return tests

