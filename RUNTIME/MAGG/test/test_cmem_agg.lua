local qconsts     = require 'Q/UTILS/lua/q_consts'
local cmem        = require 'libcmem'
local lAggregator = require 'Q/RUNTIME/MAGG/lua/lAggregator'

local tests = {}
tests.t1 = function(n, niters)
  local n = n or 1000
  local niters = niters or 10000
  -- create an aggregator, should work
  local T1 = require 'Q/RUNTIME/MAGG/lua/test1'
  local A = lAggregator(T1, "libaggtest1")
  A:instantiate()
  -- create and initialize CMEM
  local n_keys = 100
  local n_keys_per_val = 20
  local n_vals = n_keys / n_keys_per_val

  local key_type = "I4"
  local key_width = qconsts.qtypes[key_type].width
  local keys = cmem.new(n_keys * key_width, key_type, "keys")

  local val_width = 32
  local vals = cmem.new(n_vals * val_width)
  vals:set_width(val_width)

  A:put_cmem(keys, vals, n_keys_per_val)
  local M = A:meta()
  assert(M._num_puts == n_keys)
  print("Success on test t1")
end
-- return tests
tests.t1()
print("All done"); os.exit()
