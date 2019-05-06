local Q = require 'Q'
local Scalar = require 'libsclr'
local tests = {}

tests.t1 = function()
  local len = 65536*2 + 456
  local input = {}
  for i = 1, len do
    input[i] = i
  end

  local a = Q.mk_col(input, "I8")

  local b = Q.pow(a, Scalar.new(2, "I8"))
  b:eval()

  -- Q.print_csv(b)

  -- verify output
  local val, nn_val
  for i = 1, len do
    val, nn_val = b:get_one(i-1)
    assert(val:to_num() == i*i)
  end
  print("DONE")
end

-- testing Q.sqr() for returning correct values
tests.t2 = function()
  local len = 65536*2 + 456
  local input = {}
  for i = 1, len do
    input[i] = i
  end
  local a = Q.mk_col(input, "I8")

  local b = Q.sqr(a)
  b:eval()

  -- Q.print_csv(b)

  -- verify output
  local val, nn_val
  for i = 1, len do
    val, nn_val = b:get_one(i-1)
    assert(val:to_num() == i*i)
  end
  print("DONE")
end
-- TODO: add more tests considering corner cases, 
-- like what if sqr or pow crosses qtype limit
return tests
