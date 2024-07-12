local plpath = require 'pl.path'
local pldir  = require 'pl.dir'
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local lVector = require 'Q/RUNTIME/VCTR/lua/lVector'
local Scalar  = require 'libsclr'
local cVector = require 'libvctr'
local cutils  = require 'libcutils'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local lgutils = require 'liblgutils'

local qtype = "I4"
local max_num_in_chunk = 64
local len = 3 * max_num_in_chunk + 7
local tests = {}
tests.t_clone = function()
  collectgarbage("stop")
  assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
  local x = Q.seq({ len = len, start = 1, by = 1, qtype = qtype, 
    name = "x", max_num_in_chunk = max_num_in_chunk, memo_len = -1 })
  x:eval()
  x:chunks_to_lma()
  x:nop()
  local nC = x:num_chunks() 
  for k = 1, nC do 
    assert(x:num_readers(k-1) == 0) 
  end 
  x:nop()
  local nx, cx = x:get_chunk(3); assert(nx == 7)
  x:unget_chunk(3)
  assert(x:num_elements() == len)
  local y = x:clone()
  y:lma_to_chunks()
  y:check()
  assert(x:num_chunks() == y:num_chunks())
  assert(nC == 4)
  x:nop()
  for k = 1, nC do 
    print("Checking " .. k)
    assert(x:num_readers(k-1) == 0) 
  end 
  for i = 1, nC do 
    -- print("Iteration i = ", i)
    local nx, cx = x:get_chunk(3); assert(nx == 7)
    x:unget_chunk(3)

    local nx, cx = x:get_chunk(i-1)
    assert(type(cx) == "CMEM")
    assert(type(nx) == "number")
    x:unget_chunk(i-1)

    local ny, cy = y:get_chunk(i-1)
    assert(type(cy) == "CMEM")
    assert(type(ny) == "number")
    y:unget_chunk(i-1)

    local xptr = get_ptr(cx, "int32_t *")
    local yptr = get_ptr(cy, "int32_t *")
    for j = 1, nx do
      assert(xptr[j-1] == yptr[j-1])
    end

    assert(nx == ny)
    if ( i == nC ) then 
      assert(nx == 7)
    else
      assert(nx == x:max_num_in_chunk())
    end
  end

  for k = 1, nC do assert(x:num_readers(k-1) == 0) end 
  assert(x:num_readers() == 0)

  local z = Q.vveq(x, y):eval()
  Q.print_csv({x, y, z}, { opfile = "_x"})
  local r = Q.sum(z)
  local n1, n2 = r:eval()
  assert(n1 == n2)
  for k = 1, nC do assert(x:num_readers(k-1) == 0) end 
  assert(x:num_readers() == 0)

  x:delete()
  y:delete()
  z:delete()
  r:delete()
  assert(lgutils.mem_used() == 0)
  assert(lgutils.dsk_used() == 0)
  collectgarbage("restart")
  print("Test t_clone completed successfully")
end
-- return tests
tests.t_clone()
