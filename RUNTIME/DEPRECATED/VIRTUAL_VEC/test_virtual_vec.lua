local Q = require 'Q'
local lVector = require 'Q/RUNTIME/lua/lVector'
local c_to_txt = require 'Q/UTILS/lua/C_to_txt'
local ffi = require 'Q/UTILS/lua/q_ffi'
local get_ptr = require 'Q/UTILS/lua/get_ptr'

local tests = {}
--[[
tests.t1 = function()
  local col1 = Q.mk_col({1, 2, 3, 4}, "I4")
  local nX, X, nn_X = col1:start_write()
  local arg = {map_addr = X, num_elements = 3, qtype = "I4"}
  local virtual_vec = lVector.virtual_new(arg)

  -- set name
  virtual_vec:set_name("vir_vec")
  virtual_vec:check()

  -- set meta
  virtual_vec:set_meta("virtual_vec", true)
  virtual_vec:check()

  print("######## Metadata")
  -- get meta
  local vec_meta = virtual_vec:meta()
  for i, v in pairs(vec_meta.base) do
    print(i, v)
  end
  for i, v in pairs(vec_meta.aux) do
    print(i, v)
  end
  virtual_vec:check()

  -- get num_elements
  print("Num Elements", virtual_vec:num_elements())
  virtual_vec:check()

  -- get chunk_num
  print("Chunk num", virtual_vec:chunk_num())
  virtual_vec:check()

  -- get_all
  local len, base, nn = virtual_vec:get_all()
  base = ffi.cast("int32_t *", get_ptr(base))
  for i = 1, len do
    print(base[i-1])
  end
  virtual_vec:check()

  -- get_one
  for i = 1, virtual_vec:length() do
    print(virtual_vec:get_one(i-1))
  end
  virtual_vec:check()

  -- get_name
  print("Vector name", virtual_vec:get_name())
  virtual_vec:check()

  -- get fldtype
  print("Field type", virtual_vec:qtype())
  print("Field type", virtual_vec:fldtype())
  virtual_vec:check()

  -- get field size
  print("field size", virtual_vec:field_width())
  virtual_vec:check()

 
  -- check is_nascent (not supported at lVector)
  --print("is_nascent", virtual_vec:is_nascent())
  --virtual_vec:check()

  -- check is_eov
  print("is_eov", virtual_vec:is_eov())
  virtual_vec:check()

  -- check is_virtual
  --print("is_virtual", virtual_vec:is_virtual()
  --virtual_vec:check()

  -- check is_memo
  print("is_memo", virtual_vec:is_memo())
  virtual_vec:check()

  -- get chunk
  local len, base, nn = virtual_vec:chunk(0)
  base = ffi.cast("int32_t *", get_ptr(base))
  for i = 1, len do
    print(base[i-1])
  end
  virtual_vec:check()

  col1:end_write()
  print("SUCCESS")
end

tests.t2 = function()
  -- Test virtual vector from virtual vector
  local len = 65536 * 2 + 2
  local in1 = {}
  for i = 1, len do
    in1[i] = i
  end
  local parent = Q.mk_col(in1, "I4")
  local nX, X, nn_X = parent:start_write()
  
  -- create virtual vector 1 with elements 65536 + 1
  local arg = {map_addr = X, num_elements = 65536+1, qtype = "I4"}
  local vir_vec1 = lVector.virtual_new(arg)

  -- create virtual vector 2 with remaining elements
  
  local casted_X = ffi.cast("CMEM_REC_TYPE *", X)
  casted_X[0].data = ffi.cast("int32_t *", casted_X[0].data) + 65536+1
  arg = {map_addr = X, num_elements = 65536+1, qtype = "I4"}
  local vir_vec2 = lVector.virtual_new(arg)

  -- get_one
  for i = 1, vir_vec1:length() do
    local val, nn_val = vir_vec1:get_one(i-1)
    assert(val:to_num() == i, "Mismatch vir_vec1, expected = " .. tostring(i) .. ", actual = " .. tostring(val:to_num()))
  end
  
  -- get_one
  for i = 1, vir_vec2:length() do
    local val, nn_val = vir_vec2:get_one(i-1)
    assert(val:to_num() == 65537 + i, "Mismatch vir_vec1, expected = " .. tostring(65537 + i) .. ", actual = " .. tostring(val:to_num()))
  end

  --print("Virtual Vector 1")
  --print(vir_vec1:get_one(0))
  --print(vir_vec1:get_one(vir_vec1:length()-1))

  --print("Virtual Vector 2")
  --print(vir_vec2:get_one(0))
  --print(vir_vec2:get_one(vir_vec2:length()-1))

  --print("Total length")
  --print(vir_vec1:length() + vir_vec2:length())


  -- create virtual vector vir_vec11 from vir_vec1
  nX, X, nn_X = vir_vec1:start_write()

  local arg = {map_addr = X, num_elements = 32768, qtype = "I4"}
  local vir_vec11 = lVector.virtual_new(arg)
  
  -- create virtual vector vir_vec12 from vir_vec1
  casted_X = ffi.cast("CMEM_REC_TYPE *", X)
  casted_X[0].data = ffi.cast("int32_t *", casted_X[0].data) + 32768
  arg = {map_addr = X, num_elements = 32769, qtype = "I4"}
  local vir_vec12 = lVector.virtual_new(arg)
  
  vir_vec1:end_write()

  --print("Virtual Vector 11")
  val, nn_val = vir_vec11:get_one(0)
  assert(val:to_num() == 1, "Mismatch, expected " .. tostring(1) .. ", actual " .. tostring(val:to_num()))
  val, nn_val = vir_vec11:get_one(vir_vec11:length()-1)
  assert(val:to_num() == 32768, "Mismatch, expected " .. tostring(32768) .. ", actual " .. tostring(val:to_num()))

  --print("Virtual Vector 12")
  val, nn_val = vir_vec12:get_one(0)
  assert(val:to_num() == 32769, "Mismatch, expected " .. tostring(32769) .. ", actual " .. tostring(val:to_num()))
  val, nn_val = vir_vec12:get_one(vir_vec12:length()-1)
  assert(val:to_num() == 65537, "Mismatch, expected " .. tostring(65537) .. ", actual " .. tostring(val:to_num()))

  -- create virtual vector vir_vec21 from vir_vec2
  nX, X, nn_X = vir_vec2:start_write()

  local arg = {map_addr = X, num_elements = 32768, qtype = "I4"}
  local vir_vec21 = lVector.virtual_new(arg)

  -- create virtual vector vir_vec22 from vir_vec2
  casted_X = ffi.cast("CMEM_REC_TYPE *", X)
  casted_X[0].data = ffi.cast("int32_t *", casted_X[0].data) + 32768
  arg = {map_addr = X, num_elements = 32769, qtype = "I4"}
  local vir_vec22 = lVector.virtual_new(arg)

  vir_vec2:end_write()

  --print("Virtual Vector 21")
  val, nn_val = vir_vec21:get_one(0)
  assert(val:to_num() == 65538, "Mismatch, expected " .. tostring(65538) .. ", actual " .. tostring(val:to_num()))
  val, nn_val = vir_vec21:get_one(vir_vec21:length()-1)
  assert(val:to_num() == 98305, "Mismatch, expected " .. tostring(98305) .. ", actual " .. tostring(val:to_num()))

  --print("Virtual Vector 22")
  val, nn_val = vir_vec22:get_one(0)
  assert(val:to_num() == 98306, "Mismatch, expected " .. tostring(98306) .. ", actual " .. tostring(val:to_num()))
  val, nn_val = vir_vec22:get_one(vir_vec22:length()-1)
  assert(val:to_num() == 131074, "Mismatch, expected " .. tostring(131074) .. ", actual " .. tostring(val:to_num()))
 

  -- Change Values
  nX, X, nn_X = vir_vec11:start_write()
  local data_ptr = get_ptr(X, vir_vec11:qtype())
  data_ptr[0] = 0
  data_ptr[vir_vec11:length()-1] = 0
  vir_vec11:end_write()

  nX, X, nn_X = vir_vec12:start_write()
  local data_ptr = get_ptr(X, vir_vec12:qtype())
  data_ptr[0] = 0
  data_ptr[vir_vec12:length()-1] = 0
  vir_vec12:end_write()

  nX, X, nn_X = vir_vec21:start_write()
  local data_ptr = get_ptr(X, vir_vec21:qtype())
  data_ptr[0] = 0
  data_ptr[vir_vec21:length()-1] = 0
  vir_vec21:end_write()

  nX, X, nn_X = vir_vec22:start_write()
  local data_ptr = get_ptr(X, vir_vec22:qtype())
  data_ptr[0] = 0
  data_ptr[vir_vec22:length()-1] = 0
  vir_vec22:end_write()

  parent:end_write()
  
  assert(parent:get_one(0):to_num() == 0)
  assert(parent:get_one(32767):to_num() == 0)
  assert(parent:get_one(32768):to_num() == 0)
  assert(parent:get_one(65536):to_num() == 0)
  assert(parent:get_one(65537):to_num() == 0)
  assert(parent:get_one(98304):to_num() == 0)
  assert(parent:get_one(98305):to_num() == 0)
  assert(parent:get_one(131073):to_num() == 0)

  print("SUCCESS")
end

tests.t3 = function()
  -- Test modification in virtual vector, it should affect parent vector
end
--]]
return tests
