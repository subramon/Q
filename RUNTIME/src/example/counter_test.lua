lcounter = require("lcounter")
 
c = lcounter.new(0, "c1")
c:add(4)
c:decrement()
print("val=" .. c:getval())
 
c:subtract(-2)
c:increment()
print(c)

