#!/home/subramon/lua-5.3.0/src/lua
function exec_add_tbl (J)
  local tbl  = assert(J.tbl)
  -- delete table if it exists
  local t = T[tbl]
  if ( t ~= nil ) then 
    exec_del_tbl(J) 
    update_del_tbl(J) 
  end
  -- create table
  assert(tostring(DOCROOT), "DOCROOT not specified")
  newdir = DOCROOT .. "/" .. tbl
  assert(g_lfs.mkdir(newdir), "Unable to mkdir " .. newdir)
end
