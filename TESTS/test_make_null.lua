-- FUNCTIONAL
local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local tests = {}
tests.t1 = function ()
	local x = Q.mk_col({1, 2, 3, 4, 5, 6, 7}, "I4")
	local y = Q.mk_col({1, 0, 1, 0, 1, 0, 1}, "B1")
	local bady1 = Q.mk_col({1, 0, 1, 0, 1, 0, 1, 0}, "B1")
	local bady2 = Q.mk_col({1, 0, 1, 0, 1, 0, 1}, "I4")
	x:make_nulls(y)
	assert(x:has_nulls() == true)
	-- ptrs should reflect existence of nn vector
	local len, xptr, nn_xptr = x:get_all()
	assert(len > 0)
	assert(xptr)
	assert(nn_xptr) -- must have null value now 
	--
	-- cannot set null vector if one already set 
	local status = pcall(x.make_nulls, y)
	assert(status == false)
end

tests.t2 = function ()
	-- try some "bad" values for bit vector
	local x = Q.mk_col({1, 2, 3, 4, 5, 6, 7}, "I4")
	local y = Q.mk_col({1, 0, 1, 0, 1, 0, 1}, "B1")
	local bady1 = Q.mk_col({1, 0, 1, 0, 1, 0, 1, 0}, "B1")
	local bady2 = Q.mk_col({1, 0, 1, 0, 1, 0, 1}, "I4")
	local status = pcall(x.make_nulls, x, bady1)
	assert(status == false)
	local status = pcall(x.make_nulls, x, bady2)
	assert(status == false)
	local status, err = pcall(x.make_nulls, x, y)
	assert(status == true)

	x:drop_nulls()
	assert(x:has_nulls() == false)
	-- multiple deletions of null vector okay
	assert(x:drop_nulls())
	assert(x:drop_nulls())
	assert(x:drop_nulls())
	-- can add null vector after deleting it 
	status, err = pcall(x.make_nulls, x, y)
	assert(status == true)
	assert(x:check())
end
--=======================================
return tests
