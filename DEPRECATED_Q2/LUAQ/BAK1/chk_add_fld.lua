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
end
