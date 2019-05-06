local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local tests = {}
tests.t1 = function ()
	local X = {}
	for i = 1,9 do
  	X[#X + 1] = 31
	end
	for i = 1,333 do
  	X[#X + 1] = 32
	end
	for i = 1,55 do
  	X[#X + 1] = 33
	end
	for i = 1,64 do
  	X[#X + 1] = 34
	end
	for i = 1,35 do
  	X[#X + 1] = 35
	end
	for i = 1,85 do
  	X[#X + 1] = 36
	end
	for i = 1,22 do
  	X[#X + 1] = 37
	end
	for i = 1,32 do
  	X[#X + 1] = 38
	end
	local ysubp = Q.const({ val = 0.5, len = #X, qtype = 'F8' })
	local X = Q.mk_col(X, 'F8')
	local b = Q.sum(Q.vvmul(X, ysubp)):eval():to_num()
	for i = 1,1000 do
  	local btmp = Q.sum(Q.vvmul(X, ysubp)):eval():to_num()
  	assert(btmp == b, "original result: "..b..", different result: "..btmp)
	end
end
--=======================================
return tests

