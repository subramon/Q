local lu = require('luaunit')
local Dictionary = require "Q/OPERATORS/DATA_LOAD/lua/dictionary_dataload"

test_dictionary = {}

function test_dictionary:setUp()
  -- all created dictionaries are stored inside this global variables,
end

function test_dictionary:tearDown()
end


function test_dictionary:test_create() 
  local dictionary = Dictionary({dict = "testDictionary", is_dict = false, add=true})
  lu.assertNotNil(dictionary)
  lu.assertEquals(type(dictionary), "Dictionary")
end

function test_dictionary:test_create_null_metadata_error()
  lu.assertError(Dictionary)
  lu.assertErrorMsgContains("Dictionary metadata should not be empty", Dictionary ) 
end

function test_dictionary:test_create_null_name_error()
  lu.assertError(Dictionary, { is_dict = false, add=true})
  lu.assertErrorMsgContains("Metadata is incorrect", Dictionary, {dict = "", is_dict = false, add=true} ) 
end

function test_dictionary:test_add()
  local dictionary = Dictionary({dict = "D1", is_dict = false, add=true})
  local entry1 = dictionary:add_with_condition("Entry1", true)
  local entry2 =  dictionary:add_with_condition("Entry2")
  
  lu.assertNumber(entry1)
  lu.assertNumber(entry2)
  lu.assertEquals("Entry1", dictionary:get_string_by_index(entry1))
  lu.assertEquals("Entry2", dictionary:get_string_by_index(entry2))
  lu.assertEquals(entry1, dictionary:get_index_by_string("Entry1"))
  lu.assertEquals(entry2, dictionary:get_index_by_string("Entry2"))  
  lu.assertEquals(2, dictionary:get_size())
end

function test_dictionary:test_add_nil()
  local dictionary = Dictionary({dict = "D1", is_dict = false, add=true})
  lu.assertError(dictionary.add_with_condition,self,"")
  lu.assertErrorMsgContains("Cannot add nil or empty string in dictionary", dictionary.add_with_condition, self,"")
  lu.assertErrorMsgContains("Cannot add nil or empty string in dictionary", dictionary.add_with_condition, self, "", false)
  lu.assertErrorMsgContains("Cannot add nil or empty string in dictionary", dictionary.add_with_condition, self, "", true)  
end

function test_dictionary:test_add_multiple_with_add_false()  
  local dictionary = Dictionary({dict = "D1", is_dict = false, add=true})
  local entry1 = dictionary:add_with_condition("Entry1", true)
   
  lu.assertNumber(entry1)
  lu.assertErrorMsgContains("Text does not exist in dictionary", dictionary.add_with_condition, dictionary, "Entry2", false)  
end

function test_dictionary:test_add_mutiple_with_tdd_true()
  local dictionary = Dictionary({dict = "D1", is_dict = false, add=true})
  local entry1 = dictionary:add_with_condition("Entry1", true)
  local entry2 = dictionary:add_with_condition("Entry1", true)
  
  lu.assertNumber(entry1)
  lu.assertNumber(entry2)
  lu.assertEquals(entry1,entry2)
end

function test_dictionary:test_store_dictionary()
  local dictionary = Dictionary({dict = "D1", is_dict = false, add=true})
  dictionary:add_with_condition("Entry1")
  dictionary:add_with_condition("Entry2")
  dictionary:save_to_file("./serializedD1")
  
  local f = io.open("./serializedD1", "r")
  local line1 = f:read("*l")
  local line2 = f:read("*line")
  local line3 = f:read("*line")
  lu.assertEquals(line1, "Entry1,1")
  lu.assertEquals(line2, "Entry2,2")
  lu.assertNil(line3)      
  
  f:close()
  os.remove("./serializedD1")
end

function test_dictionary:test_read_dictionary_from_file()
  local dictionary = Dictionary({dict = "D1", is_dict = false, add=true})
  dictionary:add_with_condition("Entry1")
  dictionary:add_with_condition("Entry2")
  dictionary:save_to_file("./serializedD2")
  
  local restored_dictionary = Dictionary({dict = "D2", is_dict = false, add=true})
  restored_dictionary:restore_from_file("./serializedD2")
  
  local val = restored_dictionary:get_index_by_string("Entry1")
  
  lu.assertEquals( restored_dictionary:get_string_by_index(1), "Entry1")
  lu.assertEquals( restored_dictionary:get_index_by_string("Entry2"), 2)
  
  os.remove("./serializedD2")
end

function test_dictionary:test_increment_number_addition()
  local dictionary = Dictionary({dict = "D1", is_dict = false, add=true})
  dictionary:add_with_condition("e1")
  dictionary:add_with_condition("e2")
  dictionary:add_with_condition("e3")
  dictionary:add_with_condition("e4")
  
  lu.assertEquals(dictionary:get_string_by_index(1), "e1")
  lu.assertEquals(dictionary:get_string_by_index(2), "e2")
  lu.assertEquals(dictionary:get_string_by_index(3), "e3")
  lu.assertEquals(dictionary:get_string_by_index(4), "e4")
end

function test_dictionary:test_dictionary_add()
  local dictionary = Dictionary({dict = "D1", is_dict = false, add=true})
  dictionary:add_with_condition("e1")
  dictionary:add_with_condition("e2")
  dictionary:add_with_condition("e3")
  dictionary:add_with_condition("e4")
  lu.assertEquals(dictionary:get_size(), 4)
  
  dictionary:add_with_condition("e5")
  dictionary:add_with_condition("e6")
  lu.assertEquals(dictionary:get_size(), 6)    
end


function test_dictionary:test_dictionary_add_backslash()
  local dictionary = Dictionary({dict = "D1", is_dict = false, add=true})
  local slash_num = dictionary:add_with_condition("\\")
  lu.assertEquals(dictionary:get_size(), 1)
  lu.assertEquals(slash_num, 1)
  lu.assertEquals(dictionary:get_string_by_index(1), "\\")    
end

os.exit( lu.LuaUnit.run() )
