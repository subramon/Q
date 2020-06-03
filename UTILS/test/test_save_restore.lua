local Q = require 'Q'
local Scalar = require 'libsclr'
local lVector = require 'Q/RUNTIME/VCTR/lua/lVector'
local cVector = require 'libvctr'
local qconsts = require 'Q/UTILS/lua/q_consts'

local tests = {}

tests.t1 = function()
  -- Simple test to check save() & restore() functionality  
  -- Two iterations: in order to call save with and without argument
  for i = 1, 2 do 
    local qtype = "F4"
    local n = 10
    vec = lVector({qtype = qtype})
    for i = 1, n do 
      vec:put1(Scalar.new(i, qtype))
    end
    local meta_file = "/tmp/saving_it.lua"
    vec:persist()
    if ( i == 1 ) then 
      Q.save(meta_file)
    elseif ( i == 2 ) then 
      Q.save()
    else
      error("")
    end
    vec = nil -- nullifying vec before restoring
    local status, ret
    if ( i == 1 ) then 
      status, ret = pcall(Q.restore, meta_file)
    elseif ( i == 2 ) then 
      status, ret = pcall(Q.restore)
    else
      error("")
    end
    assert(status, ret)
    assert(vec:num_elements() == n)
    assert(vec:qtype() == qtype)
    assert(vec:is_eov())
    for i = 1, n do 
      local s = vec:get1(i-1)
      assert(s == Scalar.new(i, qtype))
    end
    end
  print("Successfully executed test t1")
end


tests.t3 = function()
  print("TODO test t3 needs to be fixed")
  --[[
  -- Test to check whether aux metadata is restored after calling restore()
  col1 = Q.mk_col({10,20,30,40,50}, "I4")
  col1:set_meta("key1", "value1")
  Q.save("/tmp/saving_it.lua")
  
  -- nullifying col1 before restoring
  col1 = nil

  -- restore operation
  local status, ret = pcall(Q.restore, "/tmp/saving_it.lua")
  assert(status, ret)
  assert(col1:meta().aux.key1)
  assert(col1:meta().aux.key1 == "value1")
  assert(col1:meta().base.is_persist == true)
  print("Successfully executed test t3")
  --]]
end

-- Q.save() should not try to persist global Vectors that have been 
-- marked as memo = false and whose size exceeds chunk size
tests.t4 = function()
  local qtype = "F4"
  local n = cVector.chunk_size() + 1 
  vec = lVector({qtype = qtype}):memo(false)
  for i = 1, n do 
    vec:put1(Scalar.new(i, qtype))
  end
  vec:persist()
  print(">>> START deliberate error")
  Q.save("/tmp/saving_it.lua")
  print("<<< STOP  deliberate error")
  vec = nil -- nullifying vec before restoring
  local status, ret = pcall(Q.restore, "/tmp/saving_it.lua")
  assert(status, ret)
  assert(not vec)
end

return tests
