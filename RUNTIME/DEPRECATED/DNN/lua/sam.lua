lDNN = {}

mt = {}

-- introduce a '__call' metamethod in table 'mt'
mt.__call = function (cls, ...)
  print(cls)
  print(...)
end

-- associate the metatable 'mt' with 'lDNN' table
setmetatable(lDNN, mt)

-- call table 'lDNN' as like function
lDNN("abc")
-- above statement will execute a function associated with __call metamethod
-- first argument ia table itself and rest of the arguments are passed as it is.
-- line no. 7 will print the string representation of table
-- line no. 8 will print the rest of the arguments passed (i.e "abc")

--==========================================================================================

-- set lDNN as metatable 
dnn = setmetatable({}, lDNN)
-- above statement is same as
-- dnn= {}
-- setmetatabale(dnn, lDNN)

-- below statement will not work as line no. 15 becasue lDNN doesn't have '__call' metamethod
dnn("hellow world")
