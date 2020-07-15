-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q       = require 'Q'
local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi     = require 'ffi'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local for_cdef = require 'Q/UTILS/lua/for_cdef'

local so_dir_path = os.getenv("Q_SRC_ROOT") ..  "/OPERATORS/F1F2_IN_PLACE/lua/"
local sofile = so_dir_path .. "libsort2.so"

local qtypes = { "I1", "I2", "I4", "I8", "F4", "F8" }
for _, qtype in ipairs(qtypes) do 
  local hfile = 
    "OPERATORS/F1F2_IN_PLACE/gen_inc/sort2_asc_" .. qtype .. "_" .. qtype .. ".h"
  local x = for_cdef(hfile)
  print(x)
  ffi.cdef(x)
end 

local cmd = "make -C " .. so_dir_path .. " test"
local xstatus = os.execute(cmd)
assert(xstatus == 0 )
local qc_sort = ffi.load(sofile)

-- lua test to check the working of SORT2_ASC operator only for I4 qtype
local tests = {}
tests.t1 = function ()
  local qtypes = { "I1", "I2", "I4", "I8", "F4", "F8" }
  for _, qtype in ipairs(qtypes) do
    local cst_as = qconsts.qtypes[qtype].ctype .. " * "
    local a = {10, 9, 8, 7, 6, 5, 4, 3, 2, 1}
    local b = {100, 90, 80, 70, 60, 50, 40, 30, 20, 10}
    local expected_b = {10, 20, 30, 40, 50 ,60, 70, 80, 90, 100}
    local expected_a = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}

    local col_a = Q.mk_col(a, qtype):eval()
    local col_b = Q.mk_col(b, qtype):eval()

    local a_len, a_chunk = col_a:get_chunk(0)
    local _,     b_chunk = col_b:get_chunk(0)
    local cst_a_chunk = ffi.cast(cst_as,  get_ptr(a_chunk))
    local cst_b_chunk = ffi.cast(cst_as,  get_ptr(b_chunk))
    local func_name = "sort2_asc_" .. qtype .. "_" .. qtype
    local status = qc_sort[func_name](cst_a_chunk, cst_b_chunk, a_len)
    assert(status == 0)
    -- Validate the result
    cst_a_chunk = ffi.cast(cst_as, cst_a_chunk)
    cst_b_chunk = ffi.cast(cst_as, cst_b_chunk)
    for i = 1, a_len do
      assert(cst_a_chunk[i-1] == expected_a[i] )
      assert(cst_b_chunk[i-1] == expected_b[i] )
    end
    col_a:unget_chunk(0)
    col_b:unget_chunk(0)
  end
  print("Test t1 succeeded")
end
-- tests.t1()
return tests
