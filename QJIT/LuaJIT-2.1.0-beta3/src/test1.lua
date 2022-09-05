local lVector = require 'lVector'

local x = lVector({ qtype = "F4", width = 4, chunk_size = 0 })
print(" type(x) = ",  type(x))
x = nil
collectgarbage()
print("All done")
