local Q = require 'Q'
local Scalar = require 'libsclr'
local lVector = require 'Q/RUNTIME/VCTR/lua/lVector'
local cVector = require 'libvctr'
local qconsts = require 'Q/UTILS/lua/q_consts'

local tests = {}

tests.t1 = function()
  -- Simple test to check save() & restore() functionality  
  local qtype = "F4"
  local n = 10
  col1 = lVector({qtype = qtype})
  for i = 1, n do 
    col1:put1(Scalar.new(i, qtype))
  end
  col1:persist()
  Q.save("/tmp/saving_it.lua")
  local col2 = col1
  col1 = nil -- nullifying col1 before restoring
  local status, ret = pcall(Q.restore, "/tmp/saving_it.lua")
  assert(status, ret)
  assert(col1:num_elements() == n)
  assert(col1:qtype() == qtype)
  assert(col1:is_eov())
  for i = 1, n do 
    local s = col1:get1(i-1)
    assert(s == Scalar.new(i, qtype))
  end
  print("Successfully executed test t1")
end

tests.t2 = function()
  -- negative testcase:
  -- not setting Q_METADATA_FILE env var nor passing file name to save
  col1 = Q.mk_col({10,20,30,40,50}, "I4")
  -- Call save() without argument
  local status, reason = pcall(Q.save)
  assert(status == false)
  print("Successfully executed test t2")
end

tests.t3 = function()
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
end

tests.t4 = function()
    -- JIRA QQ-160:
    -- verifying Q.save() should not try to persist global Vectors that have been marked as memo = false
    col1 = Q.seq({ start = 1, by = 1, len = 10 , qtype = "I8"})
    col1:memo(false)
    col1:eval()
    Q.save("/tmp/saving_it.lua")
end

-- basic global scalar testcase
tests.t5 = function()
  -- creating global Scalars
  sc_B1_bool = Scalar.new(true, "B1")
  sc_I1 = Scalar.new(100, "I1")
  sc_B1_num = Scalar.new(0, "B1")
  Q.save("/tmp/saving_sclrs.lua")

  -- nullifying sc_* before restoring
  sc_B1_bool = nil
  sc_I1 = nil
  sc_B1_num = nil

  local status, ret = pcall(Q.restore, "/tmp/saving_sclrs.lua")
  assert(status, ret)
  assert(sc_B1_bool:to_str() == "true")
  assert(sc_B1_bool:to_num() == 1)
  assert(sc_I1:to_num() == 100)
  print("Successfully executed test t5")
end

-- return tests
tests.t1()


