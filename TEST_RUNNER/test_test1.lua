require 'Q/UTILS/lua/strict'
function t1()
print(1)
assert (1==1)
end

function t2()
print(2)
assert (1==2)
end

-- tests are identified by the index
return {t1,t2}