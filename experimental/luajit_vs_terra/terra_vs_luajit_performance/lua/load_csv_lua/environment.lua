require 'dictionary'

function set_environment()
-- check Q_DATA_DIR, Q_META_DATA_DIR variable exists
  if _G["Q_DATA_DIR"] == nil then
    _G["Q_DATA_DIR"] = "./out/"     
  end
  
  if _G["Q_META_DATA_DIR"] == nil then
    _G["Q_META_DATA_DIR"] = "./metadata/"
  end

-- create dictionary table if it does not exists
  if _G["Q_DICTIONARIES"] == nil then
    _G["Q_DICTIONARIES"] = {}
  end
end

-- save all dictionaries in the medatadata directory.. this should be called before system shuts down, so that all dictionaries are saved
function save_all_dictionaries()
   for dict_name, dictionary in pairs(_G["Q_DICTIONARIES"]) do
      local file_path =  _G["Q_META_DATA_DIR"] .. dict_name
      dictionary:save_to_file(file_path)
   end
end 
