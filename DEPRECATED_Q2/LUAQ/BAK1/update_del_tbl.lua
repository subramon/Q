#!/home/subramon/lua-5.3.0/src/lua
function update_del_tbl (J)
  local tbl  = assert(J.tbl)
  local t    = T[tbl]
  if ( t == nil ) then return nil end
  --============================================
  local fields = assert(t.fields)
  if ( fields ~= nil ) then 
    for k, v in pairs(fields) do 
      -- delete meta data for each field in table
      fields[k] = nil 
    end
  end
  -- delete meta data for table
  T[tbl] = nil
end
