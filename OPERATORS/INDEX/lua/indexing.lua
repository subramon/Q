local T = {}

local function index(x, y)
-- Q.index(x, y) : searches the index of given value(i.e. y) from the given vector(i.e. x)
            -- if found, returns index(a lua number)
            -- else returns nil
-- In Q.index(x, y), indexing starts with 0
-- Convention: Q.index(vector, value)
-- 1) vector : a vector other than B1 qtype
-- 2) value  : number or Scalar value

-- TODO: Q.index(x, y) with x vector of qtype 'B1' can be supported 
-- in indices, to return index of first index of y value 

-- Q.index(x) : returns a I8 vector containing the indices of 1 in given boolean vector(B1)
-- In Q.index(x), indexing starts with 0
-- Convention: Q.index(B1_vector)

  assert(x, "no arg x to index")
  assert(type(x) == "lVector",  "x is not lVector")
  local expander
  local op
  
  if y then
    assert(x:qtype() ~= "B1", "B1 not supported")
    assert(type(y) == "Scalar" or type(y) == "number", "y is not Scalar or number")
    expander = require 'Q/OPERATORS/INDEX/lua/expander_index'
    op = "index"
    assert(y, "no arg y to index")
  elseif x:qtype() == "B1" then
    expander = require 'Q/OPERATORS/INDEX/lua/expander_indices'
    op = "indices"
  else
    assert(nil, "Improper arguments to index operator")
  end

  local status, col = pcall(expander, op, x, y)
  if not status then print(col) end
  assert(status, "Could not execute INDEX")
  return col
end

T.index = index
require('Q/q_export').export('index', index)
