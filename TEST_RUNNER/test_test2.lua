local tests = {}
tests.t1 = function ()
print(1)
assert (1==1)
end

tests.t2 = function()
print(2)
assert (1==2)
end

-- tests are identified by names "t1", "t2"
return tests