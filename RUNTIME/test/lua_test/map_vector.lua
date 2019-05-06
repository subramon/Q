-- test_type: need to specify the vector type to be created
-- name: testcase name
-- meta: meta data file for vector
-- num_elements: number of elements
-- qtype: need to specify qtype and not in meta data file

-- gen_method: need to specify the generation method
-- like scalar, gen function or randomly in the iteration
local qconsts = require 'Q/UTILS/lua/q_consts'

return { 
  -- creating nascent vectors
  -- without nulls
  
  -- nascent vector : generating values with cmem_buf
  {
    test_type = "nascent_vector",
    assert_fns = "nascent_vector1",
    name = "create_nascent_vector_cmem_buf", 
    meta = "gm_create_nascent_vector1.lua", 
    num_elements = qconsts.chunk_size+4, 
    gen_method = "cmem_buf", 
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8", "B1" }
  },
  
  -- nascent vector : generating values with scalar
  {
    test_type = "nascent_vector",
    assert_fns = "nascent_vector1",
    name = "create_nascent_vector_scalar", 
    meta = "gm_create_nascent_vector1.lua", 
    num_elements = 1000, 
    gen_method = "scalar", 
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
  
  -- nascent vector with is_memo false, try eov, this method should not work
  -- also you can not add element after eov
  {
    test_type = "nascent_vector",
    assert_fns = "nascent_vector2_1",
    name = "nascent_vector_memo_false_check_add_element_after_eov",
    meta = "gm_create_nascent_vector2.lua",
    num_elements = 100,
    gen_method = "cmem_buf",
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" },
    test_category = "error_testcase_1"
  },
  
  -- nascent vector with is_memo false, try persist, this method should not work
   {
    test_type = "nascent_vector",
    assert_fns = "nascent_vector2_2",
    name = "nascent_vector_memo_false_check_persist",
    meta = "gm_create_nascent_vector2.lua",
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
    assert_fns = "nascent_vector2_3",
    name = "nascent_vector_memo_false_set_memo_and_vec_check",
    meta = "gm_create_nascent_vector2.lua",
    num_elements = 100,
    gen_method = "cmem_buf",
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },

  -- try modifying nascent vector after eov 
  -- call get_chunk which sets open_mode to 1 ( read_only)
  -- modify with start_write(), which should fail
  {
    test_type = "nascent_vector",
    assert_fns = "nascent_vector3",
    name = "write_to_nascent_vector_read_only", 
    meta = "gm_create_nascent_vector3.lua", 
    num_elements = qconsts.chunk_size+4, 
    gen_method = "cmem_buf", 
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" },
    test_category = "error_testcase_1"
  },
  
  -- try modifying memo after chunk is full, operation should fail
  {
    test_type = "nascent_vector",
    assert_fns = "nascent_vector4",
    name = "update_memo_after_chunk_size", 
    meta = "gm_create_nascent_vector1.lua", 
    num_elements = qconsts.chunk_size, 
    gen_method = "cmem_buf", 
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" },
    test_category = "error_testcase_1"
  },
  
  -- nascent vector, try get_chunk() without passing chunk_num, it should return the current chunk
  {
    test_type = "nascent_vector",
    assert_fns = "nascent_vector7",
    name = "nascent_vec_get_chunk_without_chunk_num_argument",
    meta = "gm_create_nascent_vector5.lua",
    num_elements = qconsts.chunk_size+4,
    gen_method = "cmem_buf",
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },
  --[[
  -- TC Purpose: -- try modifying nascent vector after eov with start_write(), should success 
  -- This TC will fail for now
  -- when nascent_vector after eov() is opened ( open_mode = 0 ) for reading 
  -- ( here num_elements are > chunk_size )so it gets converted to materialized 
  -- as this vector was opened (open mode = 0) now start_write() will fail 
  -- as this vector was opened for read operation
  -- try modifying nascent vector after eov with start_write(), should success
  
  {
    test_type = "nascent_vector",
    assert_fns = "nascent_vector8_1",
    name = "nascent_vector_try_start_write()_after_eov",
    meta = "gm_create_nascent_vector5.lua",
    num_elements = qconsts.chunk_size+4,
    gen_method = "cmem_buf",
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },
  ]]
  -- nascent -> materialized vec (after eov)
  -- try consecutive get_chunk operation, should success 
  {
    test_type = "nascent_vector",
    assert_fns = "nascent_vector8_2",
    name = "nascent_vector_consecutive_get_chunk_operations",
    meta = "gm_create_nascent_vector5.lua",
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
    meta = "gm_create_nascent_vector5.lua",
    num_elements = qconsts.chunk_size+4,
    gen_method = "cmem_buf",
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" },
    test_category = "error_testcase_1"
  },  

  -- materialized vector
  {
    test_type = "materialized_vector",
    assert_fns = "materialized_vector1",
    name = "create_materialized_vector", 
    meta = "gm_create_materialized_vector1.lua",
    num_elements = qconsts.chunk_size+4,
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },
  
  -- materialized vector, set value at wrong index
  {
    test_type = "materialized_vector",
    assert_fns = "materialized_vector2",
    name = "materialized_vector_set_value_at_wrong_index", 
    meta = "gm_create_materialized_vector1.lua",
    num_elements = qconsts.chunk_size+4,
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" },
    test_category = "error_testcase_1"
  },    

  -- materialized vector, try eov
  {
    test_type = "materialized_vector",
    assert_fns = "materialized_vector3",
    name = "materialized_vector_eov", 
    meta = "gm_create_materialized_vector1.lua",
    num_elements = qconsts.chunk_size+4,
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },      

  -- read only materialized vector, try modifying value
  -- using start_write(), should fail
  {
    test_type = "materialized_vector",
    assert_fns = "materialized_vector4",
    name = "modify_read_only_materialized_vector", 
    meta = "gm_create_materialized_vector2.lua",
    num_elements = qconsts.chunk_size+4,
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" },
    test_category = "error_testcase_1"
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
  
  -- materialized vector, try modifying value
  -- with start_write() should success
  {
    test_type = "materialized_vector",
    assert_fns = "materialized_vector6",
    name = "modify_materialized_vector_with_start_write()",
    meta = "gm_create_materialized_vector2.lua",
    num_elements = qconsts.chunk_size+4,
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },
  
  -- materialized vector, try modifying value
  -- without start_write() should fail
  {
    test_type = "materialized_vector",
    assert_fns = "materialized_vector7",
    name = "modify_materialized_vector_without_start_write()",
    meta = "gm_create_materialized_vector2.lua",
    num_elements = qconsts.chunk_size+4,
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" },
    test_category = "error_testcase_1"
  },
  

  --[[
  -- try modifying nascent vector after eov with mmap_ptr (without start_write()), it should fail
  -- this testcase should segfault, how to catch it?
  {
    test_type = "nascent_vector",
    assert_fns = "nascent_vector9",
    name = "write_to_nascent_vector_after_eov_with_mmap_ptr",
    meta = "gm_create_nascent_vector5.lua",
    num_elements = 10,
    gen_method = "cmem_buf",
    qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
  },
  ]]
}
