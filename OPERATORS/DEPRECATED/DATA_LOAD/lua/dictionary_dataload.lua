local fns = require 'Q/UTILS/lua/utils'
local parser = require 'Q/UTILS/lua/parser'

--_G["Q_DICTIONARIES"] = _G["Q_DICTIONARIES"] or {}
_G["Q_DICTIONARIES"] = {}
local Dictionary = {}
Dictionary.__index = Dictionary

setmetatable(Dictionary, {
        __call = function (cls, ...)
            return cls.get_instance(...)
        end,
})

local original_type = type  -- saves `type` function
-- monkey patch type function
type = function( obj )
    local otype = original_type( obj )
    if  otype == "table" and getmetatable( obj ) == Dictionary then
        return "Dictionary"
    end
    return otype
end

function Dictionary.get_instance(dict_metadata)
  local self = setmetatable({}, Dictionary)
  assert(type(dict_metadata) == "table" , "Dictionary metadata should not be empty")
  assert(dict_metadata.dict ~= "", "Metadata is incorrect")
 
  self.dict_name = dict_metadata.dict
  -- default value is false, dictionary does not exist.. create one
  if dict_metadata.is_dict then
    self.is_dict = dict_metadata.is_dict
  else
    self.is_dict = false
  end
  
  -- default value is true, add null values  
  if dict_metadata.is_dict then 
    self.add_new_value = dict_metadata.add
  else
    self.add_new_value = true
  end
   
  local dict;
  if self.is_dict == true then
    local dict = _G["Q_DICTIONARIES"][self.dict_name] 
    assert(dict ~= nil, "Dictionary does not exist. Aborting the operation")
    --dictionary found in globals, return that dictionary 
    return dict
  else
    local dict = _G["Q_DICTIONARIES"][self.dict_name] 
    assert(dict == nil, "Dictionary with the same name exists, cannot create new dictionary")
  end
  
  -- Two tables are used here, so that bidirectional lookup becomes easy 
  -- and whole table scan is not required for one side
  self.text_to_index = {}
  self.index_to_text = {}  
  
    --put newly created dictionary into global variable
  _G["Q_DICTIONARIES"][self.dict_name] = self
  
  return self
end
  
-- If the text exists in the dictionary
function Dictionary:does_string_exists(text) 
    if self.text_to_index[text] ~= nil then
      return true 
    else 
      return false
    end
end


-- Given a index, if that index exists in dictionary then the string corresponding to that index is returned, null otherwise
function Dictionary:get_string_by_index(index)
  local num = self.index_to_text[index]
  return num
end
        
-- Given a string, if that string  exists in dictionary then the corresponding index to that string, null otherwise        
function Dictionary:get_index_by_string(text) 
  return self.text_to_index[text]
end

  
-- --------------------------------------------------
-- Adds the string into dictionary and returns index corresponding to the string 
--     add_if_not_exists = true (default) :  If string exists in the dictionary then returns index corresponding to that string 
--                                      otherwise adds the string into dictionary and returns the index at which string was added
--     add_if_not_exists = false : If string exists in the dictionary then returns the index corresponding to that string 
--                                        otherwise error out
-- -------------------------------------------------
function Dictionary:add_with_condition(text, add_if_not_exists)

 assert(text ~= "", "Cannot add nil or empty string in dictionary") 

  -- default to true for addIfExists condition
 if add_if_not_exists == nil then
  add_if_not_exists = true 
 end
 
 if self:does_string_exists(text) then 
  return self:get_index_by_string(text)
 else
  if add_if_not_exists then
    local next_value = #self.index_to_text + 1
    self.text_to_index[text] = next_value
    self.index_to_text[next_value] = text
    return next_value
  else
    error("Text does not exist in dictionary")
  end
 end
 
end
  
function Dictionary:get_size()
  return #self.index_to_text
end  

-- --------------------------------------
-- save all dictionary content to the file specified by the filePath.   
--     Currently only one table text_to_index is dumped into file as csv content. 
--     CSV writing is the very basic function, which just escapes (  ) and writes the output. This function can be evolved if required
-- -------------------------------------- 
function Dictionary:save_to_file(file_path)
  local file = assert(io.open (file_path, "w"))
  local separator = ","
  for k,v in pairs(self.text_to_index) do 
    local s = fns["escape_csv"](k) .. separator  .. v
    -- print("S is : " .. s)
    -- store the line in the file
     file:write(s, "\n")
  end    
  assert(file:close()) 
end

-- ----------------------------------------------
-- reads the dictionary back from the file 
--   It will read each line from the csv file and add entry in both table (text_to_index and index_to_text ) 
-- -------------------------------------------

function Dictionary:restore_from_file(file_path)
  local file = assert(io.open(file_path, "r"))
  for line in file:lines() do 
    local entry= parser["parse_csv_line"](line, ',')
    -- each entry is the form string, index
    self.text_to_index[entry[1]] = tonumber(entry[2])
    self.index_to_text[tonumber(entry[2])] = entry[1]
  end  
  assert(file:close())
end
 

return Dictionary
