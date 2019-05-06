require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local qc = require 'Q/UTILS/lua/q_core'
local Scalar = require 'libsclr'
local record_time = require 'Q/UTILS/lua/record_time'

local t_start_time = qc.RDTSC()
local M = { 
   { name = "x", has_nulls = false, qtype = "I4", is_load = true }, 
   { name = "y", has_nulls = false, qtype = "I4", is_load = true }, 
 }
local datafile = "../data/37M.csv"
-- local datafile = "../data/1M.csv"
local l_start_time = qc.RDTSC()
tmp = Q.load_csv(datafile, M); 
x = tmp.x
y = tmp.y
print("Loaded data, # rows = ", x:length())
local l_stop_time = qc.RDTSC()
print("=========================================================")
print("CSV LOAD TIME = " .. tonumber(l_stop_time-l_start_time))
print("=========================================================")
local m_start_time = qc.RDTSC()
null_val = Scalar.new(1000000000, "I4")

z1 = Q.concat(x, y):set_name("z1")
w  = Q.const({val = null_val, len = x:length(), qtype = "I4"}):set_name("w")
z2 = Q.concat(y, w):set_name("z2")
z1z2 = Q.cat({z1, z2}, { name = "z1z2" } )
assert(z1z2:length() == z1:length() + z2:length())
z1z2:check()

Q.sort(z1z2, "ascending")
x, y = Q.split(z1z2, { names = { "x", "y"} })
x:eval()
y:eval()
-- basic test on concat/split
local n1, n2 = Q.sum(Q.vseq(x, null_val):set_name("dbg0")):eval()
assert(n1:to_num() == 0, n1)
n1, n2 = Q.sum(Q.vseq(y, null_val):set_name("dbg1")):eval()
assert(n1:to_num() > 0)
assert(Q.is_next(x, "geq"):eval() == true)
--=====
z = Q.is_prev(x, "neq", {default_val = 1}):set_name("z"):eval()
-- x:check()
-- y:check()
-- z:check()
-- print("======== where starting ===========")
xlbl = Q.where(x, z):set_name("xlbl"):eval()
ylbl = Q.where(y, z):set_name("ylbl"):eval()
-- print("======== where stopping  ===========")
y = Q.get_idx_by_val(ylbl,xlbl):eval() -- TODO: check with Ramesh, eval'ed y
local n0 = xlbl:length()
-- Q.print_csv({xlbl,ylbl,y}, { opfile = "_1.csv"})
x = Q.seq( { start = 0, by = 1, qtype = "I4", len = n0}):eval() -- TODO: check with Ramesh, eval'ed x

-- Q.print_csv({x, y, xidx, yidx}, { opfile = "_2.csv"})
-- prepare T0
T0 = {}
T0.x = x
T0.y = y
T0.xlbl = xlbl
ylbl = nil
-- Q.print_csv({T0.x, T0.y}, { opfile = "_T0.csv"})
-- T0.y = y, we do not need this guy
--===================
-- prepare T1
c = Q.vsneq(T0.y, -1)
T0.d = Q.convert(c, "I1"):eval()
T0.r = Q.rand({ lb = 0, ub = 1000, seed = 1234, qtype = "F4", len = n0 }):eval()
T0.s = Q.const({ val = 0, qtype = "F4", len = n0 }):eval()
-- Q.print_csv({T[#T].x, T[#T].y}, { opfile = "_T1.csv"})
local m_stop_time = qc.RDTSC()
print("=========================================================")
print("DATA MASSAGING TIME = " .. tonumber(m_stop_time-m_start_time))
print("=========================================================")
print("data massaging time distribution")
print("\n--------Operator C Timings----------")
if _G['g_time'] then
  for k, v in pairs(_G['g_time']) do
    local niters  = _G['g_ctr'][k] or "unknown"
    local ncycles = tonumber(v)
    print(k .. "," .. niters .. "," .. ncycles)
  end
end


local t_stop_time = qc.RDTSC()
print("=========================================================")
print("TOTAL EXECUTION TIME for load.lua = " .. tonumber(t_stop_time - t_start_time))
print("=========================================================")
print("ALL DONE")
Q.save()
