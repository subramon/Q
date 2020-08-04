require 'Q/UTILS/lua/strict'
local Q        = require 'Q'
local cVector  = require 'libvctr' 
local chunk_size = cVector.chunk_size()
local tests = {}

local function in_t1 (n)
  local x = Q.seq( {start = 0, by = 1, qtype = "I4", len = n} )
  local y = Q.seq( {start = 1, by = 1, qtype = "I4", len = n} )
  local z = Q.concat(x, y)
  local X = Q.split(z)
  assert(type(X) == "table")
  assert(#X == 2 )
  local x1 = X[1]
  local y1 = X[2]
  assert(type(x1) == "lVector")
  assert(type(y1) == "lVector")
  x1:eval()
  assert(x:is_eov())
  assert(y:is_eov())

  assert(x1:fldtype() == x:fldtype())
  assert(y1:fldtype() == y:fldtype())

  assert(x1:length() == x:length())
  assert(y1:length() == y:length())

  local n1, n2 = Q.sum(Q.vveq(x, x1)):eval()
  assert(n1 == n2)
  assert(n1:to_num() == n)
  local n1, n2 = Q.sum(Q.vveq(y, y1)):eval()
  assert(n1 == n2)
  assert(n1:to_num() == n)

  print("Successfully completed t1")
  return true
end

tests.t1 = function()
  assert(in_t1(chunk_size - 1))
  assert(in_t1(chunk_size + 1))
  assert(in_t1(chunk_size + 1))
  print("Successfully completed t1")
end

tests.t1()
os.exit()
