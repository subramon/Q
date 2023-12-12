local Q = require 'Q'
local cVector = require 'libvctr'
local load_promo = require 'load_promo'
local select_promo = require 'select_promo'

local is_debug = true 
local T = load_promo(is_debug)
local lb = 1697324400 -- 2023-10-15
local ub = 1702166400 -- 2023-12-10

local cond = select_promo(T, lb, ub)
assert(type(cond) == "lVector")
assert(cond:qtype() == "BL")
print("Evaluating selections from promo")
local n1, n2 = Q.sum(cond):eval()
print("num selections from promo", n1, n2)

for k, v in pairs(T) do v:delete() end 
cVector.check_all()
print("All done")
