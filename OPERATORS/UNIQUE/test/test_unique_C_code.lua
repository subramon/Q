-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi = require 'ffi'
local cmem    = require 'libcmem'
local get_ptr = require 'Q/UTILS/lua/get_ptr'

local q_src_root = os.getenv("Q_SRC_ROOT")
local so_dir_path = q_src_root .. "/OPERATORS/UNIQUE/src/"

ffi.cdef([[
int
unique(
      const int32_t * restrict A,
      uint64_t nA,
      uint64_t *ptr_aidx,
      int32_t *C,
      uint64_t nC,
      uint64_t *ptr_num_in_C
      );  
]])

os.execute("cd " .. so_dir_path .. "; bash run_unique.sh")
local qc = ffi.load(so_dir_path .. 'unique.so')

-- lua test to check the working of UNIQUE operator only for I4 qtype
local tests = {}
tests.t1 = function ()
  local expected_result = {1, 2, 3, 4, 5}
  
  local num_elements = 10
  local qtype = "I4"
  
  local input = Q.period( {start = 1, by = 1, len = num_elements, period = 5, qtype = qtype} ):persist(true)
  input:eval()
  -- unique operator assumes that the input vector is sorted
  local input_col = Q.sort(input, "asc")

  local sz_out_in_bytes = num_elements * qconsts.qtypes[qtype].width
  local out_buf = nil
  local n_out = nil
  local aidx  = nil

  out_buf = assert(cmem.new(sz_out_in_bytes))

  n_out = assert(get_ptr(cmem.new(ffi.sizeof("uint64_t"))))
  n_out = ffi.cast("uint64_t *", n_out)
  n_out[0] = 0

  aidx = assert(get_ptr(cmem.new(ffi.sizeof("uint64_t"))))
  aidx = ffi.cast("uint64_t *", aidx)
  aidx[0] = 0
      
  local a_len, a_chunk, a_nn_chunk = input:chunk(0)
  
  local casted_a_chunk = ffi.cast( "int32_t *",  get_ptr(a_chunk))
  local casted_out_buf = ffi.cast( "int32_t *",  get_ptr(out_buf))
  local status = qc["unique"](casted_a_chunk, a_len, aidx, casted_out_buf, num_elements, n_out)
  assert(status == 0, "C error in UNIQUE")
  assert(tonumber(n_out[0]) == #expected_result)
  -- Validate the result
  out_buf = ffi.cast("int32_t *", casted_out_buf)
  for i = 1, tonumber(n_out[0]) do
    print(out_buf[i-1])
    assert(out_buf[i-1] == expected_result[i] )
  end
  
  print("Test t1 succeeded")
end

return tests
