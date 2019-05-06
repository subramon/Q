local Q = require 'Q'
local Vector = require 'libvec'
local file_name = "profile_result.txt"

local n = 128*1048576

-- Q.save()
-- os.exit()
-- Q.restore()
_G['g_time']  = {}
Vector.reset_timers()
local start_time, stop_time, time
start_time = qc.RDTSC()

a = Q.const({ val = 1, len = n, qtype = "F8" }):memo(false)
b = Q.const({ val = 1, len = n, qtype = "F8" }):memo(false)
c = Q.const({ val = 1, len = n, qtype = "F8" }):memo(false)
d = Q.const({ val = 1, len = n, qtype = "F8" }):memo(false)
e = Q.const({ val = 1, len = n, qtype = "F8" }):memo(false)


local t1 = Q.vvadd( a,b):memo(false):set_name("t1")
local t2 = Q.vvsub(t1,c):memo(false):set_name("t2")
local t3 = Q.vvmul(t2,d):memo(false):set_name("t3")
local t4 = Q.vvdiv(t3,e):memo(false):set_name("t4")
local r1 = Q.sum(t4)
local r2 = Q.min(t4)
local r3 = Q.max(t4)

while true do
  local status = r1:next()
  if ( ( not status ) or ( status == 0 ) ) then  break end
  r2:next()
  r3:next()
end
--[[
r1:eval()
--]]
stop_time = qc.RDTSC()
Vector.print_timers()
-- print(n1, n2)
if _G['g_time'] then
  for k, v in pairs(_G['g_time']) do
    local niters  = _G['g_ctr'][k] or "unknown"
    local ncycles = tonumber(v)
    print("0," .. k .. "," .. niters .. "," .. ncycles)
  end
end
print("1,Time,1," ..  tostring(tonumber(stop_time-start_time)))

