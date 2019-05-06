-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi     = require 'Q/UTILS/lua/q_ffi'
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
  local expected_result = {10, 20, 30, 40, 50 ,60, 70, 80, 90, 100}
  
  local num_elements = 10
  local qtype = "I4"
  local input_col = Q.mk_col({10, 9, 8, 7, 6, 5, 4, 3, 2, 1}, "I4")
  local input_drag_col = Q.mk_col({100, 90, 80, 70, 60, 50, 40, 30, 20, 10}, "I4")

  local a_len, a_chunk, a_nn_chunk = input_col:chunk(0)
  local b_len, b_chunk, b_nn_chunk = input_drag_col:chunk(0)
  local casted_a_chunk = ffi.cast("void *",  get_ptr(a_chunk))
  local casted_b_chunk = ffi.cast("int32_t *",  get_ptr(b_chunk))
  local status = qc_sort["qsort2_asc_I4_basic"](casted_a_chunk, casted_b_chunk, a_len)
  assert(status == 1, "C error in QSORT2_ASC")
  -- Validate the result
  casted_b_chunk = ffi.cast("int32_t *", casted_b_chunk)
  for i = 1, a_len do
    print(casted_b_chunk[i-1])
    assert(casted_b_chunk[i-1] == expected_result[i] )
  end
  
  print("Test t1 succeeded")
end

return tests
