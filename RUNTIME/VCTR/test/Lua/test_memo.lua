local Q = require 'Q'
local lVector = require 'Q/RUNTIME/VCTR/lua/lVector'
local Scalar  = require 'libsclr'
local cVector = require 'libvctr'
local lgutils = require 'liblgutils'

local tests = {}
tests.t1 = function()
  local max_num_in_chunk = 64 
  local len = 3 * max_num_in_chunk + 7
  x1 = Q.seq({ len = len, start = 1, by = 1, qtype = "I4",
   name = "x1", max_num_in_chunk = max_num_in_chunk, memo_len = 1 })
  assert(x1:memo_len() == 1)
  assert(x1:name() == "x1")

  y1 = Q.concat(x1, x1, { name = "y1", f3_qtype = "I8", shift_by = 32})
  y2 = Q.concat(x1, x1, { name = "y2", f3_qtype = "I8", shift_by = 16})
  lVector.conjoin({y1, y2})
  y1:set_name("y1")
  y2:set_name("y2")
  y1:eval()
  assert(y2:is_eov())
  assert(x1:num_elements() == len)
  assert(y1:num_elements() == x1:num_elements())
  assert(y1:num_elements() == y2:num_elements())
  assert(x1:check())
  assert(cVector.check_all())
  Q.save()
  x1 = nil; y1 = nil; y2 = nil; collectgarbage()
  print("Test t1 succeeded")
end
-- test memory usage when memo len is set 
tests.t2 = function()
  local max_num_in_chunk = 64 
  local nC = 10 
  local len = nC * max_num_in_chunk + 7
  x1 = Q.seq({ len = len, start = 1, by = 1, qtype = "I4",
   name = "x1", max_num_in_chunk = max_num_in_chunk, memo_len = 1 })
  local chunk_idx = 0
  local m1, m2
  repeat 
    if (chunk_idx == nC+1 ) then print(">>>>> START DELIBERATE ERROR") end 
    local n, c = x1:get_chunk(chunk_idx)
    if (chunk_idx == nC+1 ) then print(">>>>> STOP DELIBERATE ERROR") end 
    -- make sure memory usage plateaus, even as more chunks are generated
    if ( chunk_idx == 1 ) then 
      m1 = lgutils.mem_used() 
    elseif ( chunk_idx > 1 ) then 
      assert(lgutils.mem_used() <= m1)
    end
    --=========================================
    if ( n > 0 ) then 
      -- print("Chunk " .. chunk_idx ..  ", Mem =  ", lgutils.mem_used())
      -- do some work with the chunk you got 
      x1:unget_chunk(chunk_idx)
      chunk_idx = chunk_idx + 1 
    end
  until n == 0
end
-- return tests
tests.t1()
tests.t2()
