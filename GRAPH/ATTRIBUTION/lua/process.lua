local Q = require 'Q'
local qc = require 'Q/UTILS/lua/q_core'
local load_alpha = require 'load_alpha'
local extend = require 'extend'
-- TODO WIP local extend = require 'extend2'
local Vector = require 'libvec'

Q.restore()

local a_start_time = qc.RDTSC()
Vector.reset_timers()

-- Reset Operator C Timings
_G['g_time'] = {}
_G['g_ctr'] = {}

T = {}
T[#T+1] = {}
T[#T].x = Q.where(T0.x, c)
T[#T].y = Q.where(T0.y, c)

local max_d = 4
local alpha = load_alpha()
while true do
  -- print("--------------")
  local a =  extend(T[#T], T0.y)
  if ( not a ) then break end
  T[#T+1] = a
  -- Q.print_csv({T[#T].x, T[#T].y}, { opfile = "_T" .. #T .. ".csv"})
  Q.set_sclr_val_by_idx(T[#T].x, T0.d, {sclr_val = #T})
  -- print("#T = ",  #T )
  if ( #T >= max_d ) then break end
  -- Q.print_csv(Q.numby(T0.d, #T+1):eval())
end
for k = 1, #T do
  -- print(" k = ", k)
  T[k].d = Q.get_val_by_idx(T[k].x, T0.d):memo(false)
  T[k].r = Q.get_val_by_idx(T[k].x, T0.r):memo(false)
  T[k].alpha = Q.get_val_by_idx(T[k].d, alpha[k]):memo(false)
  local s = Q.vvmul(T[k].r, T[k].alpha):memo(false)
  Q.add_vec_val_by_idx(T[k].y, s, T0.s)
end
-- Q.print_csv({T0.x,T0.y, T0.d, T0.r, T0.s}, { opfile = "_final.csv"})
local a_stop_time = qc.RDTSC()
print("=========================================================")
print("DATA ANALYSIS TIME = " .. tonumber(a_stop_time-a_start_time))
print("=========================================================")
print("data analysis time distribution")
print("\n--------Vector Timings---------")
Vector.print_timers()
print("\n--------Operator C Timings----------")
if _G['g_time'] then
  for k, v in pairs(_G['g_time']) do
    local niters  = _G['g_ctr'][k] or "unknown"
    local ncycles = tonumber(v)
    print(k .. "," .. niters .. "," .. ncycles)
  end
end

return process_data
