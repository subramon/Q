local qconsts = require 'Q/UTILS/lua/q_consts'

-- test_type: need to specify the vector type to be created
-- assert_fns: function to be called to perform checks
-- name: testcase name
-- meta: meta data file for vector
-- num_elements: number of elements
-- qtype: need to specify qtype if you want to run test for specific qtype
-- gen_method: need to specify the generation method ('func', 'scalar', 'cmem_buf')
-- test_category: need to specify this field if test-case is negative test-case

return {
  --=============================
  -- without nulls
  
  -- creating nascent vector, generating values by scalar
  { 
    test_type = "nascent_vector", 
    assert_fns = "nascent_vector1",
    name = "Creation of nascent vector_scalar", 
    meta = "gm_create_nascent_vector2.lua",
    num_elements = qconsts.chunk_size+4, 
    gen_method = "scalar", 
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8", "B1" }
  },
  
  -- creating nascent vector, generating values by scalar, put one element, check file size
  { 
    test_type = "nascent_vector", 
    assert_fns = "nascent_vector1",
    name = "Creation of nascent vector_scalar", 
    meta = "gm_create_nascent_vector2.lua",
    num_elements = 1, 
    gen_method = "scalar", 
    qtype = { "B1" }
  },
  
  -- creating nascent vector, generating values by cmem_buf
  { 
    test_type = "nascent_vector", 
    assert_fns = "nascent_vector1",
    name = "Creation of nascent vector_cmem_buf", 
    meta = "gm_create_nascent_vector2.lua",
    num_elements = 1025, 
    gen_method = "cmem_buf", 
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8", "B1" }
  },
  
  -- creating nascent vector, generating values by cmem_buf, SC qtype
  { 
    test_type = "nascent_vector", 
    assert_fns = "nascent_vector1",
    name = "Creation of nascent vector_cmem_buf", 
    meta = "gm_create_nascent_vector6.lua",
    num_elements = qconsts.chunk_size+4, 
    gen_method = "cmem_buf", 
    qtype = { "SC" }
  },
  
  -- creating nascent vector, generating values by cmem_buf, put one element, check file size
  { 
    test_type = "nascent_vector", 
    assert_fns = "nascent_vector1",
    name = "Creation of nascent vector_cmem_buf", 
    meta = "gm_create_nascent_vector2.lua",
    num_elements = 1, 
    gen_method = "cmem_buf", 
    qtype = { "B1" }
  },
  -- creating nascent vector, generating values by providing gen function,
  -- in case of gen function num_elements field is
  -- number of chunks (num_chunks) and not actula number of elements
  { 
    test_type = "nascent_vector", 
    assert_fns = "nascent_vector2",
    name = "Creation of nascent vector_gen1_func", 
    meta = "gm_create_nascent_vector1.lua",
    num_elements = 2 , 
    gen_method = "func", 
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },
  
  -- nascent vector with is_memo false, try eov, this method should not work
  -- also you can not add element after eov
  {
    test_type = "nascent_vector",
    assert_fns = "nascent_vector3_1",
    name = "nascent_vector_memo_false_check_add_element_after_eov",
    meta = "gm_create_nascent_vector3.lua",
    num_elements = 100,
    gen_method = "cmem_buf",
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" },
    test_category = "error_testcase_1"
  },
  
  -- nascent vector with is_memo false, try persist, this method should not work
  {
    test_type = "nascent_vector",
    assert_fns = "nascent_vector3_2",
    name = "nascent_vector_memo_false_check_persist",
    meta = "gm_create_nascent_vector3.lua",
    num_elements = 100,
    gen_method = "cmem_buf",
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" },
    test_category = "error_testcase_1"
  },  
  
  -- nascent vector with is_memo false, set is_memo explicitly to true then try vec:check(), 
  -- should be successful
  -- refer mail with subject "Testcase failing when setting memo explicitly with random boolean value"
  {
    test_type = "nascent_vector",
    assert_fns = "nascent_vector3_3",
    name = "nascent_vector_memo_false_set_memo_and_vec_check",
    meta = "gm_create_nascent_vector3.lua",
    num_elements = 100,
    gen_method = "cmem_buf",
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },
  --[[
  -- try modifying nascent vector after eov with mmap_ptr (without start_write()), it should fail
  -- this testcase should segfault, how to catch it?
  {
    test_type = "nascent_vector",
    assert_fns = "nascent_vector4",
    name = "write_to_nascent_vector_after_eov_with_mmap_ptr",
    meta = "gm_create_nascent_vector2.lua",
    num_elements = 10,
    gen_method = "cmem_buf",
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },
  ]]
 
  -- nascent_vector --> eov() ( i.e. is_nascent = T and is_eov = T )
  -- if we read values, its the last_chunk and it will be served from buffer itself
  -- so is_nascent remains T 
  -- now trying start_write(), should success and after start_write() is_nascent is set to F
  {
    test_type = "nascent_vector",
    assert_fns = "nascent_vector8_1_1",
    name = "nascent_vector_try_start_write()_after_eov_1_1",
    meta = "gm_create_nascent_vector2.lua",
    num_elements = 1025,
    gen_method = "cmem_buf",
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },
  
  -- nascent_vector --> eov() ( i.e. is_nascent = T and is_eov = T )
  -- reading values from previous chunk, (open mode is set to 0) 
  -- as reading values from previous chunk( values are serverd from file) 
  -- so is_nascent = F ( converted to materialized vector)
  -- now trying start_write(), should fail
  {
    test_type = "nascent_vector",
    assert_fns = "nascent_vector8_1_2",
    name = "nascent_vector_try_start_write()_after_eov_1_2",
    meta = "gm_create_nascent_vector2.lua",
    num_elements = qconsts.chunk_size+4,
    gen_method = "cmem_buf",
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" },
    test_category = "error_testcase_1"
  },
  
  -- nascent -> materialized vec (after eov)
  -- try consecutive get_chunk operation, should success 
  {
    test_type = "nascent_vector",
    assert_fns = "nascent_vector8_2",
    name = "nascent_vector_consecutive_get_chunk_operations",
    meta = "gm_create_nascent_vector2.lua",
    num_elements = 10,
    gen_method = "cmem_buf",
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },
  
  -- nascent -> materialized vec (after eov)
  -- start_write() should not success once vec is opened for reading
  {
    test_type = "nascent_vector",
    assert_fns = "nascent_vector8_3",
    name = "nascent_vector_followed_eov_try_start_write()_after_get_chunk()",
    meta = "gm_create_nascent_vector2.lua",
    num_elements = qconsts.chunk_size+4,
    gen_method = "cmem_buf",
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" },
    test_category = "error_testcase_1"
  },  

  -- nascent vector, try modifying memo after chunk is full, operation should fail
  {
    test_type = "nascent_vector",
    assert_fns = "nascent_vector5",
    name = "nascent_vec_update_memo_after_chunk_size",
    meta = "gm_create_nascent_vector2.lua",
    num_elements = qconsts.chunk_size,
    gen_method = "cmem_buf",
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" },
    test_category = "error_testcase_1"
  },
  -- Commenting out below testcase as this scenario is not supported - refer jira issue QQ-32
  -- nascent vector, try get_chunk() without passing chunk_num, it should return the current chunk
  --[[
  {
    test_type = "nascent_vector",
    assert_fns = "nascent_vector9",
    name = "nascent_vec_get_chunk_without_chunk_num_argument",
    meta = "gm_create_nascent_vector2.lua",
    num_elements = qconsts.chunk_size+4,
    gen_method = "cmem_buf",
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },
  ]]
  --=============================
  -- with nulls
  
  -- creating nascent vector with nulls, generating values by scalar
  { 
    test_type = "nascent_vector", 
    assert_fns = "nascent_vector1",
    name = "create_nascent_vector_with_nulls_scalar", 
    meta = "gm_create_nascent_vector5.lua",
    num_elements = qconsts.chunk_size+4, 
    gen_method = "scalar", 
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },
  
  -- creating nascent vector with nulls, generating values by cmem_buf
  {
    test_type = "nascent_vector", 
    assert_fns = "nascent_vector1",
    name = "create_nascent_vector_with_nulls_cmem_buf", 
    meta = "gm_create_nascent_vector5.lua",
    num_elements = qconsts.chunk_size+4, 
    gen_method = "cmem_buf", 
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },
  
  -- nascent vector, vec._has_nulls is true but don't provide nn_data in put_chunk
  {
    test_type = "nascent_vector", 
    assert_fns = "nascent_vector6",
    name = "nascent_vector_with_null_and_without_nn_data_in_put_chunk", 
    meta = "gm_create_nascent_vector5.lua",
    num_elements = 65, 
    gen_method = "cmem_buf", 
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },

  -- nascent vector, vec._has_nulls is true but don't provide nn_data in put1
  {
    test_type = "nascent_vector", 
    assert_fns = "nascent_vector7",
    name = "nascent_vector_with_null_and_without_nn_data_in_put1", 
    meta = "gm_create_nascent_vector5.lua",
    num_elements = 65, 
    gen_method = "scalar", 
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },
  
  -- creating materialized vectors 
  { 
    test_type = "materialized_vector", 
    name = "Creation of materialized vector", 
    assert_fns = "materialized_vector1",
    meta = "gm_create_materialized_vector1.lua",
    num_elements = qconsts.chunk_size+4, 
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },
  --[[
  -- materialized vector, set value at wrong index
  -- This testcase should segfault, how to catch it?
  {
    test_type = "materialized_vector",
    assert_fns = "materialized_vector2",
    name = "materialized_vector_set_value_at_wrong_index",
    meta = "gm_create_materialized_vector1.lua",
    num_elements = qconsts.chunk_size+4,
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },
  ]]
  -- materialized vector, try eov
  {
    test_type = "materialized_vector",
    assert_fns = "materialized_vector3",
    name = "materialized_vector_eov",
    meta = "gm_create_materialized_vector1.lua",
    num_elements = qconsts.chunk_size+4,
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },
  
  -- materialized vector, try modifying value with start_write()
  {
    test_type = "materialized_vector",
    assert_fns = "materialized_vector4",
    name = "modify_materialized_vector_with_start_write()",
    meta = "gm_create_materialized_vector2.lua",
    num_elements = qconsts.chunk_size+4,
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },
  
  -- create materialized vector where file is not present
  {
    test_type = "materialized_vector",
    assert_fns = "materialized_vector5",
    name = "create_materialized_vector_file_not_present",
    meta = "gm_create_materialized_vector3.lua",
    num_elements = qconsts.chunk_size+4,
    qtype = { "I2", "I4", "I8", "F4", "F8" },
    test_category = "error_testcase_2"
  },

  --[[
  -- create materialized vector where file is not present
  -- .bin file is not present so get_file_size returns -1
  -- at core_vec line 238 : if ( fsz <= 0 ) { go_BYE(-1); }
  -- this condition does not error out
  -- can we change the default value in get_file_size 
  -- from int64_t file_size = -1; to 0
  {
    test_type = "materialized_vector",
    assert_fns = "materialized_vector5",
    name = "create_materialized_vector_file_not_present",
    meta = "gm_create_materialized_vector3.lua",
    num_elements = qconsts.chunk_size+4,
    qtype = { "I1" }
  },
  ]]
  -- create materialized vector with has_nulls true
  { 
    test_type = "materialized_vector", 
    name = "create_materialized_vector_with_nulls", 
    assert_fns = "materialized_vector1",
    meta = "gm_create_materialized_vector4.lua",
    num_elements = qconsts.chunk_size+4, 
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },
  
  -- create materialized vector with has_nulls true but don't provide nn_file_name field
  -- This testcase is failing bcoz, 
  -- in vector code (lVector.lua) has_nulls is set/unset depending on existance of nn_file_name field
  { 
    test_type = "materialized_vector", 
    name = "materialized_vector_with_nulls_without_nn_file_name_field", 
    assert_fns = "materialized_vector5",
    meta = "gm_create_materialized_vector5.lua",
    num_elements = qconsts.chunk_size+4, 
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" },
    test_category = "error_testcase_2"
  },
  
  -- create materialized vector with has_nulls true but provide wrong value of nn_file_name
  { 
    test_type = "materialized_vector", 
    name = "materialized_vector_with_nulls_with_wrong_nn_file_name", 
    assert_fns = "materialized_vector5",
    meta = "gm_create_materialized_vector6.lua",
    num_elements = qconsts.chunk_size+4, 
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" },
    test_category = "error_testcase_2"
  },
  --[[
  -- modify the materialized vector with has_nulls true without modifying respective nn vector
  -- this testcase is causing segfault, how to catch it?
  { 
    test_type = "materialized_vector", 
    name = "modify_materialized_vector_with_nulls_without_modifying_nn_vec", 
    assert_fns = "materialized_vector6",
    meta = "gm_create_materialized_vector4.lua",
    num_elements = qconsts.chunk_size+4, 
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },
  ]]
  -- creating nascent vector, SV qtype
  { 
    test_type = "nascent_vector", 
    assert_fns = "nascent_vector1",
    name = "Creation of nascent vector_cmem_buf", 
    meta = "gm_create_nascent_vector8.lua",
    num_elements = 5, 
    gen_method = "cmem_buf", 
    qtype = { "SV" }
  }
}
