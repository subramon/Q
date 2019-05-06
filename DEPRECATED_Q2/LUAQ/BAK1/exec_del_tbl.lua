#!/home/subramon/lua-5.3.0/src/lua
function exec_del_tbl(J)
  print(" in exec_del_tbl")
  local tbl  = assert(J.tbl, "ERROR")
  local t    = T[tbl]
  if ( t == nil ) then return end 
  assert(tostring(DOCROOT))
  olddir = DOCROOT .. "/" .. tbl
  -- delete storage for table and all fields in table
  local command = "rm -r -f " .. olddir
  print(command)
  os.execute(command)
end
