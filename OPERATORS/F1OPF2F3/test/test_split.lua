require 'Q/UTILS/lua/strict'
local Q        = require 'Q'
local qcfg    = require 'Q/UTILS/lua/qcfg'
local max_num_in_chunk = qcfg.max_num_in_chunk
local tests = {}

local function in_t1 (n)
  local x = Q.seq( {start = 0, by = 1, qtype = "I4", len = n} )
  local y = Q.seq( {start = 1, by = 1, qtype = "I4", len = n} )
  local z = Q.concat(x, y)
  assert(z:qtype() == "I8")
  local X = Q.split(z, { out_qtypes = { "I4", "I4", }})
  assert(type(X) == "table")
  assert(#X == 2 )
  local x1 = X[1]
  local y1 = X[2]
  assert(type(x1) == "lVector")
  assert(type(y1) == "lVector")
  x1:eval()
  assert(x:is_eov())
  assert(y:is_eov())

  assert(x1:qtype() == x:qtype())
  assert(y1:qtype() == y:qtype())

  assert(x1:num_elements() == x:num_elements())
  assert(y1:num_elements() == y:num_elements())

  local U = {}
  U[1] = x
  U[2] = y
  U[3] = x1
  U[4] = y1
  Q.print_csv(U, { impl = "C", opfile = "_xx" .. tostring(n) })

  --[[ TODO 
  local n1, n2 = Q.sum(Q.vveq(x, x1)):eval()
  assert(n1 == n2)
  assert(n1:to_num() == n)
  local n1, n2 = Q.sum(Q.vveq(y, y1)):eval()
  assert(n1 == n2)
  assert(n1:to_num() == n)
  --]]

  print("Successfully completed t1")
  return true
end

tests.t1 = function()
  assert(in_t1(max_num_in_chunk - 1))
  assert(in_t1(max_num_in_chunk + 1))
  assert(in_t1(max_num_in_chunk + 1))
  print("Successfully completed t1")
end

tests.t1()
os.exit()
