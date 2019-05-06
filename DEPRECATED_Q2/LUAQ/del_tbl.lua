#!/home/subramon/lua-5.3.0/src/lua
function chk_del_tbl(J)
  assert(J ~= nil)
  assert(type(J) == "table")
  local tbl  = assert(J.tbl)
  assert(chk_tbl_name(tbl))
  -- silent return if table does not exist. 
  local t = T[tbl]
  if ( t == nil ) then return true end
  local properties = assert(t.Properties)
  local refcount = assert(properties.RefCount)
  assert (refcount == 0, "Cannot delete. ")
  return true
end
--==============================================================
function exec_del_tbl(J)
  local tbl  = assert(J.tbl, "ERROR")
  local t    = T[tbl]
  if ( t == nil ) then return true end 
  assert(tostring(DOCROOT))
  olddir = DOCROOT .. "/" .. tbl
  -- delete storage for table and all fields in table
  local command = "rm -r -f " .. olddir
  -- print(command)
  assert(os.execute(command), "cleanup of directory failed")
  return true
end
--==============================================================
function update_del_tbl (J)
  local tbl  = assert(J.tbl)
  local t    = T[tbl]
  if ( t == nil ) then return true end
  --============================================
  local fields = t.Fields
  if ( fields ~= nil ) then 
    for k, v in pairs(fields) do 
      -- delete meta data for each field in table
      fields[k] = nil 
    end
  end
  -- delete meta data for table
  T[tbl] = nil
  return true
end
