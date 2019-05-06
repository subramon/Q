local lVector = require 'Q/RUNTIME/lua/lVector'
local qc = require 'Q/UTILS/lua/q_core'

local tests = {}

local start, stop

tests.t1 = function()
  print("Creating nascent vector")
  local result
  local x = lVector( { qtype = "I4", gen = true, has_nulls = false})
  start = qc.get_time_usec()
  for i=1, 10000000 do
    result = x:fldtype_old()
  end
  stop = qc.get_time_usec()
  print(tonumber(stop-start))
  print("Successfully completed test t1")
end

tests.t2 = function()
  print("Creating nascent vector")
  local result
  local x = lVector( { qtype = "I4", gen = true, has_nulls = false})
  start = qc.get_time_usec()
  for i=1, 10000000 do
    result = x:fldtype()
  end
  stop = qc.get_time_usec()
  print(tonumber(stop-start))
  print("Successfully completed test t2")
end

return tests
