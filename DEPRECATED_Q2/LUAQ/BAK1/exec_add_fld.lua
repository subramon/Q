#!/home/subramon/lua-5.3.0/src/lua
function exec_add_fld (J)
  local tbl  = assert(J.tbl)
  local fld  = assert(J.fld)
  local op   = assert(J.OP)
  local t    = assert(T[tbl])
  local args = assert(J.ARGS)
  local width = ""
  if ( args.Width ~= nil ) then 
    width = args.Width
  end
  local nR       = assert(t.Properties.NumRows)
  local fldtype  = assert(args.FldType)
  local datafile = assert(args.DataFile)
  local datadir  = assert(args.DataDirectory)
  local t    = assert(T[tbl], "ERROR: Table does not exit -> " .. tbl)
  cwd  = g_lfs.currentdir()
  tbldir = DOCROOT .. "/" .. tbl
  assert(g_lfs.chdir(tbldir, "ERROR: cd failed to directory " .. tbldir))
  if ( file_exists(fld) ) then
    remove(fld)
  end
  local str_nR = assert(tostring(nR))

  _f = {}
  _f.FldType = fldtype
  if ( width ~= "" ) then _f.Width   = width end

  if ( op == "LoadBin") then 
    assert(nil, "LoadBin not implemented")
    -- qglue.add_fld(fld, datafile, datadir, fldtype)

  elseif ( op == "LoadCSV" ) then 
    local x, err = assert(
    qglue.add_fld(fld, tostring(nR), fldtype, width, datafile, datadir))
  else
    assert(nil, "ERROR")
  end
  J.f   = _f
  assert(g_lfs.chdir(cwd, "ERROR: failed to cd to original directory "))
end
