local mk_template = require 'Q/OPERATORS/MDB/lua/mk_template'
local get_hdr   = require 'Q/UTILS/lua/get_hdr'
local ffi       = require 'ffi'
local qconsts   = require 'Q/UTILS/lua/q_consts'
local get_ptr   = require 'Q/UTILS/lua/get_ptr'
local cmem      = require 'libcmem'
local qc        = require 'Q/UTILS/lua/q_core'
local plfile    = require 'pl.file'
--====================================
local fn = "mk_comp_key_val_F4" -- which function we are testing
local hfile = "../gen_inc/_" .. fn .. ".h"
local cfile = "../gen_src/_" .. fn .. ".c"
-- cedef what you need
local hdr = get_hdr(hfile)
ffi.cdef(hdr)
ffi.cdef("void *malloc(size_t size);")
-- START Make the .so file  and load it 
local QC_FLAGS = os.getenv("QC_FLAGS")
assert(#QC_FLAGS > 0)
INCS = " -I../inc/ -I../gen_inc/ -I../../../UTILS/inc/ "
command = "gcc  -O4 " .. cfile .. INCS .. " -shared -o libmdb.so " .. QC_FLAGS
print(command)
plfile.delete("./libmdb.so")
os.execute(command)
local this_qc = ffi.load("./libmdb.so")
local fnptr = assert(this_qc[fn])
--====================================
-- Create template
local nDR = {3, 4, 2} -- number of derived attributes/raw attribute
local template, nR, nD, nC  = mk_template(nDR)
-- nD = niumber of derived attributes
-- nC = number of raw attributes
-- nR = number of output rows per input row 
local nV =  math.floor(qconsts.chunk_size / nR) -- size of input
local nK = qconsts.chunk_size                   -- size of output
print("num input values nV = ", nV)
print("num output values nK = ", nK)

-- Create input keys
local in_dim_vals = cmem.new(nD * ffi.sizeof("uint8_t *"))
in_dim_vals = ffi.cast("uint8_t **", get_ptr(in_dim_vals))
for i = 1, nD do 
  local x = cmem.new( nV * ffi.sizeof("uint8_t"))
  in_dim_vals[i-1] = ffi.cast("uint8_t *",  get_ptr(x))
end
-- set some bogus values for input keys
for i = 1, nD do 
  for j = 1, nV do 
    in_dim_vals[i-1][j-1] = i*10 + j
  end
end
--  Create input value
local in_measure_val = cmem.new(nV * ffi.sizeof("float"))
in_measure_val = ffi.cast("float *", get_ptr(in_measure_val))
-- set some  bogus values for input value
for j = 1, nV do 
  in_measure_val[j-1] = j*1000 
end
--  Create space for output key and value 
local out_key = cmem.new( nK * ffi.sizeof("uint64_t"))
out_key = ffi.cast("uint64_t *", get_ptr(out_key))
local out_val = cmem.new( nK * ffi.sizeof("float"))
out_val = ffi.cast("float *", get_ptr(out_val))
--======================
local niters = 8192 --- number of iterations to perform 
print("num interations ", niters)
local t_start = qc.RDTSC()
for i = 1, niters do
  local status = fnptr(1, template, nR, nC, nD, in_dim_vals, in_measure_val, 
   out_key, out_val, nV, nK)
  assert(status == 0)
end
local t_stop = qc.RDTSC()
print("Time for " .. niters .. " iterations = " .. tostring(t_stop-t_start))
--===============================
print("SUCCESS")
os.exit()
