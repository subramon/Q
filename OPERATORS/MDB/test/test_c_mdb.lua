local mk_template = require 'Q/RUNTIME/AGG/lua/mk_template'
local ffi = require 'ffi'
-- START Define function prototype
local proto = [[
int
mk_comp_key_val(
    int **template, /* [nR][nC] */
    int nR,
    int nC,
    /* 0 <= template[i][j] < nD */
    uint8_t **in_dim_vals, /* [nD][nV] */
    float *in_measure_val, /* [nV] */
    uint64_t *out_key, /*  [nK] */ 
    float *out_val, /*  [nK] */
    int nV,
    int nK
    );
    ]]
ffi.cdef(proto)
ffi.cdef("        void *malloc(size_t size);")
-- START Make the .so file 
local QC_FLAGS = os.getenv("QC_FLAGS")
command = "gcc -g  ../src/mdb.c -I../inc/ -I../../../UTILS/inc/ -shared -o libmdb.so " .. QC_FLAGS
os.execute(command)
local qc = ffi.load("./libmdb.so")
local fn = assert(qc.mk_comp_key_val)
-- START Create variables for function call
local nDR = {3, 4, 2}
local template, nR, nD, nC  = mk_template(nDR)
local nV = 2 -- just two input values in this case
local nK = (nV * nR) + 7 -- over-allocate nK to test zero-ing extra
local in_dim_vals = ffi.cast("uint8_t **", 
  ffi.C.malloc(nD * ffi.sizeof("uint8_t *")))
for i = 1, nD do 
  in_dim_vals[i-1] = ffi.cast("uint8_t *", 
    ffi.C.malloc(nV * ffi.sizeof("uint8_t")) )
end
for i = 1, nD do 
  for j = 1, nV do 
    in_dim_vals[i-1][j-1] = i*10 + j
  end
end
--======================
local in_measure_val = ffi.cast("float *", 
  ffi.C.malloc(nV * ffi.sizeof("float")))
for j = 1, nV do 
  in_measure_val[j-1] = j*1000 
end
--======================
local out_key = ffi.cast("uint64_t *", 
  ffi.C.malloc(nK * ffi.sizeof("uint64_t")))
local out_val = ffi.cast("float *", 
  ffi.C.malloc(nK * ffi.sizeof("float")))
--======================
local status = fn(template, nR, nC, in_dim_vals, in_measure_val, 
   out_key, out_val, nV, nK)
assert(status == 0)
--===============================
print("SUCCESS")
