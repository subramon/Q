local Q = require 'Q'
local Scalar = require 'libsclr'
local qconsts = require 'Q/UTILS/lua/qconsts'
local function referrer(r) -- r = referrer
  assert(type(r) == "lVector")
  local s = Q.where(r, Q.vsgeq(r, Scalar.new(0, r:fldtype())))
  Q.sort(s, "ascending")
  z = Q.cum_cnt(s)
  if ( qconsts.debug ) then 
    d1, d2 = Q.sum(Q.vseq(z, 0)):eval()
    assert(d1:to_num() == 0)
  end
  y = Q.is_prev(z, "leq", { default_val = 1 })

  t1 = Q.where(z, y)
  local n1, n2 = Q.max(t1):eval()
  n1 = n1:to_num() 
  t2 = Q.numby(t1, n1+1)
  idx = Q.seq( { start = 0, by = 1, qtype = "I4", len = n1+1})
  Q.print_csv({idx, t2}, { lb = 0, ub = 20 })
end
return referrer
