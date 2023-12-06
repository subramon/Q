local Q = require 'Q'
local function unique_tcins(tcin)
  local x = Q.sort(tcin, "ascending")
  local y = x:lma_to_chunks()
  local val, cnt = Q.unique(y)
  assert(type(val) == "lVector")
  assert(type(cnt) == "lVector")
  val:eval()
  assert(cnt:num_elements() == val:num_elements())
  Q.print_csv({val,cnt}, {opfile = "_initial_T4.csv"})
  local T4 = {}
  T4.tcin = val; 
  cnt:delete()
  x:delete()
  y:delete()
  return T4
end
return unique_tcins
