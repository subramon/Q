-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi = require 'ffi'
local get_ptr = require 'Q/UTILS/lua/get_ptr'

local q_src_root = os.getenv("Q_SRC_ROOT")
local so_dir_path = q_src_root .. "/OPERATORS/SORT2/src/"

ffi.cdef([[
int
qsort2_asc_I4_basic (
	    void *const pbase,
      int32_t *drag,
	    size_t total_elems
	    );  
]])

os.execute("cd " .. so_dir_path .. "; bash run_sort2_asc_I4.sh")
local qc_sort = ffi.load(so_dir_path .. 'qsort2_asc_I4_basic.so')

-- lua test to check the working of SORT2_ASC operator only for I4 qtype
local tests = {}
tests.t1 = function ()
  local a = {10, 9, 8, 7, 6, 5, 4, 3, 2, 1}
  local b = {100, 90, 80, 70, 60, 50, 40, 30, 20, 10}
  local expected_b = {10, 20, 30, 40, 50 ,60, 70, 80, 90, 100}
  local expected_a = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
  
  local num_elements = 10
  local qtype = "I4"
  local col_a = Q.mk_col(a, "I4")
  local col_b = Q.mk_col(b, "I4")

  local a_len, a_chunk, a_nn_chunk = col_a:get_chunk(0)
  local b_len, b_chunk, b_nn_chunk = col_b:get_chunk(0)
  local casted_a_chunk = ffi.cast("void *",  get_ptr(a_chunk))
  local casted_b_chunk = ffi.cast("int32_t *",  get_ptr(b_chunk))
  local status = qc_sort["qsort2_asc_I4_basic"](casted_a_chunk, casted_b_chunk, a_len)
  assert(status == 1, "C error in QSORT2_ASC")
  -- Validate the result
  casted_a_chunk = ffi.cast("int32_t *", casted_a_chunk)
  casted_b_chunk = ffi.cast("int32_t *", casted_b_chunk)
  for i = 1, a_len do
    assert(casted_a_chunk[i-1] == expected_a[i] )
    assert(casted_b_chunk[i-1] == expected_b[i] )
  end
  col_a:unget_chunk(0)
  col_b:unget_chunk(0)
  
  print("Test t1 succeeded")
end
-- tests.t1()
return tests
