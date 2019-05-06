-- FUNCTIONAL 
local Q = require 'Q'
require 'Q/UTILS/lua/strict'
local diff = require 'Q/UTILS/lua/diff'
local plstring = require 'pl.stringx'
local Q_SRC_ROOT = os.getenv("Q_SRC_ROOT")
local script_dir = Q_SRC_ROOT .. "/OPERATORS/MM/test/"

local compare = function (file1, file2)
  local f1 = assert(io.open(file1, "r"))
  local s1 = f1:read("*a")
  f1:close()
  local f2 = assert(io.open(file2, "r"))
  local s2 = f2:read("*a")
  f2:close()

  local a1 = plstring.split(s1, "\n")
  local a2 = plstring.split(s2, "\n")

  for i, v in pairs(a1) do
    if(tonumber(v) ~= tonumber(a2[i])) then
      return false
    end
  end
  return true
end

local tests = {}
tests.t1 = function(
  num_iters
  )
  if ( not num_iters ) then num_iters = 10 end 
  local x1 = Q.mk_col({1, 2, 3, 4, 5, 6, 7, 8}, 'F8')
  local x2 = Q.mk_col({10, 20, 30, 40, 50, 60, 70, 80}, 'F8')
  local X = {x1, x2}
  local Y = Q.mk_col({100, 200}, 'F8')
  local Z
  local good_Z = Q.mk_col({ 
    2100, 4200, 6300, 8400, 10500, 12600, 14700, 16800}, "F8")
  for i = 1, num_iters  do 
    Z = Q.mv_mul(X, Y):eval()
    assert(Z:num_elements() == x1:length())
    -- Q.print_csv({Z, good_Z})
    assert(Q.vvseq(Z, good_Z, 0.01))
  end
  print("Completed Test t1")
end
tests.t2 = function()
 --[[
  local num_cols = 8
  local num_rows = 1048576 + 17
  local X = {}
  for i = 1, num_cols do 
    X[i] = 
  end
  local x1 = Q.mk_col({1, 2, 3, 4, 5, 6, 7, 8}, 'F8')
  local x2 = Q.mk_col({10, 20, 30, 40, 50, 60, 70, 80}, 'F8')
  local X = {x1, x2}
  local Y = Q.mk_col({100, 200}, 'F8')
  local Z = Q.mv_mul(X, Y):eval()
  --]]
  print("TODO")
end
tests.t3 = function()
  local num_trials = 2
  local x1 = Q.seq({ len = 8, start = 1, by = 1, qtype = "F8"})
  local x2 = Q.seq({ len = 8, start = 10, by = 10, qtype = "F8"})
  local X = {x1, x2}
  local Y = Q.seq({ len = 2, start = 100, by = 100, qtype = "F8"})
  local Z
  for i = 1, num_trials do
    Z = Q.mv_mul(X, Y):eval()
  end
  assert(Z:num_elements() == x1:length())
  Q.print_csv(Z)
  os.exit()
  print("Completed mv_mul")
  local opt_args = { opfile =  script_dir .. "_out1.txt" }
  Q.print_csv(Z, opt_args)
  assert(compare(script_dir .. "out1.txt", script_dir .. "_out1.txt"))
  os.execute("rm -f " .. script_dir .. "_out1.txt")
end
return tests
