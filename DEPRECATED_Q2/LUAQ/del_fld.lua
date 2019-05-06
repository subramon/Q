#!/home/subramon/lua-5.3.0/src/lua
function chk_del_fld(J)
  return true
end
--==============================================================
function exec_del_fld(J)
  local tbl  = assert(J.tbl)
  -- silent return if table does not exist. 
  local t = T[tbl]
  if ( t == nil ) then return true end
  local fld  = assert(J.fld)
  local f = (t.Fields)[fld]
  -- silent return if field does not exist. 
  if ( f == nil ) then return true end
  cwd = assert(g_lfs.currentdir())
  assert(g_lfs.chdir(DOCROOT .. "/" .. tbl))
  os.execute("rm -f " .. fld) -- TODO improve
  if ( f.HasNullFld == true ) then 
    os.execute("rm -f .nn." .. fld) -- TODO improve
  end
  assert(g_lfs.chdir(cwd))
  return true
end
--==============================================================
function update_del_fld (J)
  local tbl  = assert(J.tbl)
  local t = T[tbl]
  if ( t == nil ) then return true end
  local fld  = assert(J.fld);
  local fields = assert(t.Fields)
  fields[fld] = nil
  return true
end
