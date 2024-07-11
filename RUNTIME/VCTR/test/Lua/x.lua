local plfile = require 'pl.file'
local plpath = require 'pl.path'
local plpretty = require 'pl.pretty'
require 'Q/UTILS/lua/strict'

local lgutils = require 'liblgutils'
local lVector = require 'Q/RUNTIME/VCTRS/lua/lVector'
local qcfg = require 'Q/UTILS/lua/qcfg'
local Q = require 'Q'
local max_num_in_chunk = qcfg.max_num_in_chunk
local len = 2 * max_num_in_chunk + 3 
assert(type(x) == "lVector")
assert(x:qtype() == "I4")
local width = x:width()
assert(width == 4)
assert(x:num_elements() == len)
assert(lgutils.mem_used() == 0)
local chk_dsk = math.ceil(len/max_num_in_chunk)*max_num_in_chunk*width
assert(lgutils.dsk_used() >= chk_dsk)
-- Create a copy of vector x, delete x and then make sure copy exists
x:nop()
print("REF", x:ref_count())
assert(x:ref_count() == 1)
copy_x = lVector({uqid = x:uqid()})
assert(copy_x:ref_count() == 2)
assert(x:ref_count() == 2)
x:delete()
x = nil
assert(copy_x:ref_count() == 1)
copy_x:set_name("x")
print(">>>> NOP ")
-- copy_x:pr()
copy_x:nop()
copy_x:drop_mem(1)
x = copy_x
copy_x = nil
print("<<<< NOP ")
--==========================
-- create a new vector y 
assert(lgutils.mem_used() == 0)
y = Q.const({ val = 1, qtype = "F8", len = len}):set_name("YY"):eval()
local nC = y:num_chunks()
local width = y:width()
local mem = max_num_in_chunk * nC * width
assert(lgutils.mem_used() == mem)
assert(lgutils.dsk_used() >= chk_dsk)
print("Saving started")
assert(Q.save())
