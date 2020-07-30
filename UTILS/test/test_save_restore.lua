os.execute("export Q_RESET=true")
-- DO NOT USE require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local Scalar = require 'libsclr'
local lVector = require 'Q/RUNTIME/VCTR/lua/lVector'
local cVector = require 'libvctr'
local qconsts = require 'Q/UTILS/lua/q_consts'

local tests = {}

vec = nil

tests.t1 = function()
  -- Simple test to check save() & restore() functionality  
    local qtype = "F4"
    local n = 10
    vec = lVector({qtype = qtype})
    for i = 1, n do 
      vec:put1(Scalar.new(i, qtype))
    end
    local meta_file = "/tmp/saving_it.lua"
    vec:persist()
    Q.save()
    vec = nil -- nullifying vec before restoring
    local status, ret
    status, ret = pcall(Q.restore)
    assert(status, ret)
    assert(vec:num_elements() == n)
    assert(vec:qtype() == qtype)
    assert(vec:is_eov())
    for i = 1, n do 
      local s = vec:get1(i-1)
      assert(s == Scalar.new(i, qtype))
    end
  print("Successfully executed test t1")
end


tests.t2 = function()
  print("TODO test t2 needs to be fixed")
  --[[
  -- Test to check whether aux metadata is restored after calling restore()
  print("Successfully executed test t2")
  --]]
end

-- Q.save() should not try to persist global Vectors that have been 
-- marked as memo = false and whose size exceeds chunk size
tests.t3 = function()
  local qtype = "F4"
  local n = cVector.chunk_size() + 1 
  vec = lVector({qtype = qtype}):memo(false)
  for i = 1, n do 
    vec:put1(Scalar.new(i, qtype))
  end
  vec:persist()
  print(">>> START deliberate error")
  Q.save()
  print("<<< STOP  deliberate error")
  vec = nil -- nullifying vec before restoring
  local status, ret = pcall(Q.restore)
  assert(status, ret)
  assert(not vec)
  print("Successfully executed test t3")
end
return tests
-- tests.t3()
