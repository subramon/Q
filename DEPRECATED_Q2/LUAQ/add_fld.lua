#!/home/subramon/lua-5.3.0/src/lua
function chk_add_fld(J)
  assert(J ~= nil)
  assert(type(J) == "table")
  local t = assert(J.tbl)
  assert(chk_tbl_name(t))
  assert(is_tbl(t), "Table not found" .. t)
  local f = assert(J.fld)
  assert(chk_fld_name(f), "Invalid field name: " .. f)
  local op = assert(J.OP)
  local args = assert(J.ARGS)
  assert(type(args) == "table")
  local fldtype = assert(args.FldType, "FldType not specified")
  local datafile = assert(args.DataFile, "DataFile not specified")
  local datadir  = assert(args.DataDirectory) -- null > use cwd
  local sz = 0
  -- if directory specified, check that it exists and file exists in it
  if ( datadir == nil ) then
    sz = assert(g_lfs.attributes(DataFile, "size"))
  else
    cwd = g_lfs.currentdir()
    assert(g_lfs.chdir(datadir), 
    "Unable to change to directory " .. datadir)
    sz = assert(g_lfs.attributes(datafile, "size"))
    g_lfs.chdir(cwd)
  end
  assert(sz > 0, "ERROR: File is empty: " .. datafile)
  --===================================================
  -- Verify size of file if 
  if ( op == "LoadBin" )  then 
    local nR    = assert(t.Properties.NumRows)
    local fldsz = assert(T_fldsz[fldtype])
    assert ( ( ( fldsz * nR ) == sz ), 
  "ERROR: File size is wrong. Expected " .. tostring(nR*fldsz) .. " got " .. sz)
  end
  return true
end
--==============================================================
function exec_add_fld (J)
  local tbl  = assert(J.tbl)
  local fld  = assert(J.fld)
  local op   = assert(J.OP)
  local t    = assert(T[tbl])
  local args = assert(J.ARGS)
  local width = 0
  if ( args.Width ~= nil ) then 
    width = tonumber(args.Width, "Width not a number")
  end
  local nR       = assert(tonumber(t.Properties.NumRows))
  local fldtype  = assert(args.FldType)
  local datafile = assert(args.DataFile)
  local datadir  = assert(args.DataDirectory)
  local t    = assert(T[tbl], "ERROR: Table does not exit -> " .. tbl)
  cwd  = g_lfs.currentdir()
  tbldir = DOCROOT .. "/" .. tbl
  assert(g_lfs.chdir(tbldir, "ERROR: cd failed to directory " .. tbldir))
  -- following not needed. Will be done by C code
  -- if ( file_exists(fld) ) then remove(fld)

  _f = {}
  _f.FldType = fldtype
  if ( width ~= 0 ) then _f.Width   = toint(width) end

  if ( op == "LoadBin") then 
    assert(nil, "LoadBin not implemented")
    -- qglue.add_fld(fld, datafile, datadir, fldtype)

  elseif ( op == "LoadCSV" ) then 
    local x, y = assert(
    qglue.add_fld(fld, nR, fldtype, width, datafile, datadir))
    if ( x ~= nil ) then 
      if ( y ) then 
        print("DBG: has null values")
        _f.HasNullFld = true
      end
    end
  else
    assert(nil, "ERROR")
  end
  J.f   = _f
  assert(g_lfs.chdir(cwd, "ERROR: failed to cd to original directory "))
  return true
end
--==========================================================
function update_add_fld(J)
  update_s_to_f(J)
  return true
end
