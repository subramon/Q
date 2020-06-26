local Q = require 'Q'
local cond = Q.vsleq(T.gainLossPct90Day, -17.44) 
local gprime = Q.where(T.highAvgBPCombo, cond)
local n1, n2 = Q.sum(gprime):eval()
print(n1, n2)
local n1, n2 = Q.sum(T.highAvgBPCombo):eval()
print(n1, n2)
print("Checked")
os.exit()
