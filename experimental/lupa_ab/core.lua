local ffi = require 'ffi'
local header_file = "core.h"
local qc = ffi.load('./lib_ab.so')
local JSON = require "JSON"


local file = io.open(header_file, "r")
ffi.cdef(file:read("*all"))
file:close()

ffi.cdef([[
void * malloc(size_t size);
void free(void *ptr);
]])


local fns = {}


local function init_ab(config_file)
  local size = 20
  assert(config_file)
  local ab_struct = ffi.C.malloc(ffi.sizeof("AB_ARGS_TYPE*"))
  status = qc.init_ab(config_file, size, ab_struct)
  ab_struct = ffi.cast("AB_ARGS_TYPE **", ab_struct)
  return ab_struct[0]
end
fns.init_ab = init_ab


local function sum_ab(ab_struct, json_body)
  local ab_tbl = assert(JSON:decode(json_body),
    "Not valid JSON")
  local sum = ffi.C.malloc(ffi.sizeof("int*"))
  local status = qc.sum_ab(ab_struct, ab_tbl['factor'], sum)
  local result = {}
  sum = ffi.cast("int *", sum)
  result['sum'] = sum[0]
  return JSON:encode(result)
end
fns.sum_ab = sum_ab


local function print_ab(ab_struct)
  return qc.print_ab(ab_struct)
end
fns.print_ab = print_ab


local function free_ab(ab_struct)
  return qc.free_ab(ab_struct)
end
fns.free_ab = free_ab


return fns
