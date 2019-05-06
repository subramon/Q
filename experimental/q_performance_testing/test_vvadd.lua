local Q = require 'Q'
local Vector = require 'libvec'
local Scalar = require 'libsclr'
local qconsts = require 'Q/UTILS/lua/q_consts'
local qc = require 'Q/UTILS/lua/q_core'

local file_name = "profile_result.txt"

local len = qconsts.chunk_size*2
local in_table = {}
for i = 1, len do
  in_table[i] = i
end

local col1 = Q.mk_col(in_table, "I4", nil):set_name("col1")
local col2 = Q.mk_col(in_table, "I4", nil):set_name("col2")
local vec_meta = col1:meta()

local start_time, stop_time, time

Vector.reset_timers()
local dbg = false
start_time = qc.RDTSC()
for i = 1, 10000 do
  local x = Q.vvadd(col1, col2):memo(false):set_name("vvadd_out")
  if ( dbg ) then 
    local n1, n2 = Q.sum(x):eval()
    assert(n1:to_num() == 2 * len * (len+1) / 2)
  else
    x:eval()
  end
end
stop_time = qc.RDTSC()
Vector.print_timers()

print("vvadd total execution time : " .. tostring(tonumber(stop_time-start_time)))

print("=========================")

if _G['g_time'] then
  for k, v in pairs(_G['g_time']) do
    local niters  = _G['g_ctr'][k] or "unknown"
    local ncycles = tonumber(v)
    print("0," .. k .. "," .. niters .. "," .. ncycles)
  end
end

