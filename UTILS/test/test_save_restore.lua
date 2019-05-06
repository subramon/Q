local Q = require 'Q'
local Scalar = require 'libsclr'

local tests = {}
local qconsts = require 'Q/UTILS/lua/q_consts'

tests.t1 = function()
  -- Simple test to check save() & restore() functionality  
  col1 = Q.mk_col({10,20,30,40,50}, "I4")
  Q.save("/tmp/saving_it.lua")

  -- nullifying col1 before restoring
  col1 = nil

  local status, ret = pcall(Q.restore, "/tmp/saving_it.lua")
  assert(status, ret)
  assert(col1:num_elements() == 5)
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

-- commenting this testcase as luaposix is removed from q_installation process
--[[
-- negative testcase
tests.t6 = function()
  -- Usecase note: within same lua environment, modification in environment variables(for eg here: Q_METADATA_FILE) would not modify 
  -- the Q environment variables as they are now treated as constants (refer Q/UTILS/lua/q_consts/lua)
  local posix = require 'posix.stdlib'
  col1 = Q.mk_col({10,20,30,40,50}, "I4")
  -- setting the Q_METADATA_FILE environment variable
  posix.setenv('Q_METADATA_FILE', '/tmp/saved.meta')
  -- Call save() without argument
  local status, reason = pcall(Q.save)
  assert(status == false)
  print("Successfully executed test t6")
end
]]

return tests


