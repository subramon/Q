local Q = require 'Q'
-- Q.print_csv({T.x1, T.x2, T.goal}, { filter = { lb = 0, ub = 10} })
--  Is x14 > 488? This results in 500 samples where 265/500, 
--  or 53%, are profitable (y = 1)
local cond = Q.vsgt(T.x14, 488) -- from Evan 
-- local cond = Q.vsgt(T.x14, 468.66) -- from Ramesh
local gprime = Q.where(T.goal, cond)
local n1, n2 = Q.sum(gprime):eval()
print(n1, n2)
local n1, n2 = Q.sum(T.goal):eval()
print(n1, n2)
print("Checked")
os.exit()
