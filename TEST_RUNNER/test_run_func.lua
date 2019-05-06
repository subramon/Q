--[[
To run this "test case" directly from command line, use below command
    luajit -e "t = require 'test_run_func'; t.f1();t.f2()"
]]

local tests = {}
tests.f1 = function()
    print ("func1 called!")
end
tests.f2 = function()
    print ("func2 called!")
end
return tests