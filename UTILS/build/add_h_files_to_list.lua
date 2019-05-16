local clean_defs   = require 'Q/UTILS/build/clean_defs'
 local function add_h_files_to_list(
   list, 
   file_list
   )
   assert(list      and ( type(list)      == "table") )
   assert(file_list and ( type(file_list) == "table" ) ) 
   for i = 1, #file_list do
      list[#list + 1] = clean_defs(file_list[i])
   end
   return list
 end
 return add_h_files_to_list
