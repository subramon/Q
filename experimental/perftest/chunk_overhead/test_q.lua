local Q = require 'Q'
-- local dbg = require 'Q/UTILS/lua/debugger'
local qc      = require 'Q/UTILS/lua/q_core'
local filenm = arg[1]
local Column = require 'Q/RUNTIME/COLUMN/code/lua/Column'
local col = Column{field_type='I4', filename=filenm,}
local z = Q.vvadd(col,col, {junk = "junk"})
local start_time = qc.RDTSC()
z.eval(z)
local stop_time = qc.RDTSC()
print("time taken", stop_time-start_time)

