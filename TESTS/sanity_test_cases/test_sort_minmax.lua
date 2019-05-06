-- FUNCTIONAL
local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local tests = {}
tests.t1 = function ()
	-- TEST MIN MAX WITH SORT
	local meta = {
		{ name = "empid", has_nulls = true, qtype = "I4", is_load = true }
	}
  local datadir = os.getenv("Q_SRC_ROOT") .. "/TESTS/sanity_test_cases/"
	local result = Q.load_csv(datadir .. "I4.csv", meta)
	assert(type(result) == "table")
  local min
  local max
	for i, v in pairs(result) do
  	local x = result[i]
  	assert(type(x) == "lVector")
		-- Sort dsc & find min & max
		Q.sort(x, "dsc")
		local y = Q.min(x)
		local status = true repeat status = y:next() until not status
		assert(y:value():to_num() == 10 )
		assert(Q.min(x):eval():to_num() == 10)
		min = Q.min(x):eval():to_num()

		local z = Q.max(x)
		local status = true repeat status = z:next() until not status
		assert(z:value():to_num() == 50 )
		assert(Q.max(x):eval():to_num() == 50)
		max = Q.max(x):eval():to_num()

 end
	-- Sort asc & find min & max --]]
  local datadir = os.getenv("Q_SRC_ROOT") .. "/TESTS/sanity_test_cases/"
	local result = Q.load_csv(datadir .. "I4.csv", meta)
	assert(type(result) == "table")
  local min_new
  local max_new
	for i, v in pairs(result) do 
    local x = result[i]
  	assert(type(x) == "lVector")
		Q.sort(x, "asc")
		local y1 = Q.min(x)
		local status = true repeat status = y1:next() until not status
		assert(y1:value():to_num() == 10 )
		assert(Q.min(x):eval():to_num() == 10)
		min_new = Q.min(x):eval():to_num()

		local z1 = Q.max(x)
		local status = true repeat status = z1:next() until not status
		assert(z1:value():to_num() == 50 )
		assert(Q.max(x):eval():to_num() == 50)
		max_new = Q.max(x):eval():to_num()
  end

	-- Verifying min max remains the same.
  -- ToDo: How to capture values of min & max to br compared later?
	assert(min == min_new, "Value mismatch in the case of minimum")
	assert(max == max_new, "Value mismatch in the case of minimum")
  --end
end
--=======================================
return tests
