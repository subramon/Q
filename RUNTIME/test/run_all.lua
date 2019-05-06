tests = { 
"test_B1", 
"test_bvec",
"test_chunk_without_chunk_number",
"test_cmem",
-- "test_gen3",
"test_gen4",
"test_get_chunk_one",
"test_lVector_get_all",
"test_lVector_materialized",
"test_lVector_nascent",
"test_lVector_reincarnate",
"test_read_write",
"test_sclr_arith",
"test_sclr_eq",
"test_sclr_I8",
"test_sclr",
"test_vec_B1",
"test_vec_clone",
"test_vec",
"test_vec_name",
"test_vec_no_chunk_num",
"test_vec_prev_chunk",
"test_vec_SC",
"test_vec_writable",
}

for k, test in  pairs(tests) do 
  print("working on script ", test)
  T = require(test)
  for k, v in pairs(T) do print(k); v() end 
  package.loaded[test] = nil
  collectgarbage()
end
print("ALL DONE")
--[[
  T = require 'test_bvec'
  for k, v in pairs(T) do print(k); v() end 
  package.loaded.test_bvec = nil
  --]]
