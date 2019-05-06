#!/home/subramon/lua-5.3.0/src/lua
function chk_f_to_s(J)
  assert(J ~= nil)
  assert(type(J) == "table")
  local tbl = assert(J.tbl)
  assert(chk_tbl_name(tbl))
  local t = assert(T[tbl], "Table not found" .. tbl)
  local fld = assert(J.fld)
  assert(chk_fld_name(fld))
  local f    = assert((t.Fields)[fld], "Field not found ".. fld)
  local jop   = assert(J.OP)
  local jargs = J.ARGS 
  if ( jargs ~= nil ) then 
    assert(type(jargs) == "table")
  end
  local jfldtype = f.FldType;
  
  --========================================================
  assert(chk_op_supported(f_to_s_IO.OP, jop));
  if ( jargs ~= nil ) then 
    assert(chk_mandatory_args((f_to_s_IO[jop].ARGS).Mandatory), jargs);
  end
  assert(chk_fldtype((f_to_s_IO[jop].ARGS).FldType, jfldtype))
  return true
end
--===========================================================
function exec_f_to_s(J)
  local op       = assert(J.OP)

  local tbl      = assert(J.tbl)
  local t        = assert(T[tbl])
  local nR       = assert(t.Properties.NumRows)

  local fld      = assert(J.fld)
  local f        = assert((t.Fields)[fld])

  local restrict = J.Restriction
  local args     = J.ARGS
  --===== field properties
  local fldtype      = assert(f.FldType)
  local has_null_fld = 0
  if ( f.HasNullFld == true ) then has_null_fld = 1 end
  local fldlen = 0
  if ( fldtype == "SC" ) then fldlen      = assert(tonumber(f.FldLen)) end
  --==========
  local where_type = "";
  local where_fld = "";
  local where_lb = 1
  local where_ub = 0
  if ( restrict ~= nil ) then 
    print("DBG: I SEE A RESTCITION")
    where_type = assert(restrict.RestrictionType)
    assert(( ( where_type == "Range" ) or
         ( where_type == "BooleanField" )), "Invalid Restriction")
    if ( where_type == "BooleanField" ) then 
      where_fld = assert(restrict.BooleanField)
      assert(tostring(where_fld))
      rf = assert((t.Fields)[where_fld], "Restriction Field not found")
    end
    if ( where_type == "Range" ) then 
      where_lb = assert(tonumber(restrict.LB), "LB not found or not number")
      where_ub = assert(tonumber(restrict.UB), "UB not found or not number")
      assert(where_lb >=  0, "LB must be non-negative")
      assert(where_ub <= nR, "UB cannot exceed number of rows = " .. nR)
      assert(where_lb <  where_ub, "LB cannot equal or exceed UB")
    end
  end

  local _t = {}
  cwd = assert(g_lfs.currentdir())
  tbldir = DOCROOT .. "/" .. tbl
  assert(g_lfs.chdir(tbldir, "ERROR: cd failed to directory " .. tbldir))
  if ( op == "Print" ) then 
    print("pronting....")
    -- if no filename provided, then print to stdout
    local filename = ""
    if ( args ~= nil ) then 
      local filename = args.FileName
      if ( filename == nil ) then filename = "" end
    end
    local x, err = assert(qglue.pr_fld(fld, nR,
    where_type, where_fld, where_lb, where_ub,
           fldtype, fldlen, cwd, filename, has_null_fld))
    if ( x == nil ) then print(err); assert(nil, err) end
  else 
    local val, err = assert(qglue.f_to_s(fld, tostring(nR), fldtype, 
      op, has_null_fld))
    if ( val == nil ) then print(err); assert(nil, err) end
    _t.Value    =  val
  end
  assert(g_lfs.chdir(cwd))
  if ( _t == nil ) then return true else return _t end
end
--===========================================================
function update_f_to_s (J)
  return true
end
