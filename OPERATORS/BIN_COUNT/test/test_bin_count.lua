local Scalar = require 'libsclr'
local Q      = require 'Q'
local tests = {}
tests.t1 = function()
  local len = 1024
  local qtype = "I4"
  local x = Q.seq({len = len, start = 0, by = 1, qtype = qtype})
  local y = Q.seq({len = len/8, start = 4, by = 8, qtype = qtype})
  local floor = Scalar.new(0, qtype)
  local ceil = Scalar.new(len+1, qtype)
  local optargs = { floor = floor, ceil = ceil, }
  local z = Q.bin_count(x, y, optargs)
  assert(type(z) == "Reducer")
  local vlb, vub, vcnt = z:eval()
  assert(type(vcnt) == "lVector")
  assert(vcnt:num_elements() == y:num_elements() + 1)
  local n1, n2 = Q.sum(vcnt):eval()
  assert(n1:to_num() == len)
  -- checks on vlb,vub
  local tmp = Q.vvlt(vlb, vub)
  local n1, n2 = Q.sum(tmp):eval()
  -- Q.print_csv({vlb, vub, tmp})
  assert(n1 == n2)
  -- check counts in first bin
  local ub = y:get1(0)
  local lb = 0
  local a = Q.vsgeq(x, lb):eval()
  local b = Q.vslt(x, ub):eval()
  local c = Q.vvand(a, b)
  local n1, n2 = Q.sum(c):eval()
  assert(n1 == vcnt:get1(0))
  -- check counts in last bin
  local lb = y:get1(y:num_elements()-1)
  local ub = ceil
  local a = Q.vsgeq(x, lb):eval()
  local b = Q.vslt(x, ub):eval()
  local c = Q.vvand(a, b)
  local n1, n2 = Q.sum(c):eval()
  assert(n1 == vcnt:get1(vcnt:num_elements()-1))
  -- TODO More checking to do 
  print("Test t1 OK");
  -- Starting testigng of bin_place
  local altx = Q.seq({len = len, start = len-1, by = -1, qtype = qtype})
  altx:set_name("altx")
  altx:eval()
  local altz = Q.bin_place(altx, vlb, vub, vcnt):set_name("altz")
  assert(altz:is_eov())
  assert(altz:num_elements() == altx:num_elements())

  local chk_x = Q.sort(altx, "ascending"):set_name("chk_x")
  local chk_z = Q.sort(altz, "ascending"):set_name("chk_z")
  local n1, n2 = Q.sum(Q.vveq(chk_x, chk_z)):eval()
  assert(n1 == n2)

end 
-- return tests
tests.t1()
