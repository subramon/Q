function chk_tbl_name(t)
  assert(t ~= nil, "Table name is nil")
  assert ( tostring(t), "Table name not a string")
  assert(#t < 32, "Table name too long")
  assert(#t >= 1, "Table name too short")
  assert(string.sub(t, 1, 1) ~= "_", "Table name starts with underscore")
  return true
end

function chk_fld_name(t)
  assert(t ~= nil, "Field name is nil")
  assert ( tostring(t), "Field name not a string")
  assert(#t < 32, "Field name too long")
  assert(#t >= 1, "Field name too short")
  assert(string.sub(t, 1, 1) ~= "_", "Field name starts with underscore")
  return true
end


-- ===============================================================
function exec_tbl_meta(J)
  print("in exec_tbl_meta")
  local tbl = assert(J.tbl)
  local t   = assert ( T[tbl], "Table not found " .. tbl)
  local property = assert(J.property, "ERROR")
  local propval = assert(t[property], "Property not found " .. property)
  print(propval)
  return nil
end
-- ============================================================a===
--[[
function del_tbl (t)
  -- Is this too defensive? assert ( DOCROOT ~= nil ) 
  -- Is this too defensive? assert ( T       ~= nil ) 
  if ( T[t]    == nil ) then return end
  T[t] = nil;
  local command = "rm -r -f " .. DOCROOT .. "/" .. t
  -- print(command)
  os.execute(command)
end
--]]
-- ===============================================================
function is_tbl(t)
  assert(tostring(t))
  if ( T[t] == nil ) then return false else return true end 
end
-- ===============================================================
function add_fld ( t, f, json_str)
  json = (loadfile "../../../LUA/json.lua")() -- TOOD: FIX
 
  chk_tbl_name(t)
  assert(is_tbl(t), "Table " .. t .. " does not exist")
  chk_fld_name(f)
  if ( (T[t])[f] ) then
    print("Field " .. f .. " in table " .. t .. " exists. Deleting..")
    -- TODO Fill in the blanks
  end
  assert(tostring(json_str))
  local json_t = json:decode(json_str)
  _f = {}
  for k, v in pairs(json_t) do
    print(k, v)
    _f["_" .. k] = v
  end
  assert(json_t["FldType"]) 


  local cwd = assert(g_lfs.currentdir());
  assert(g_lfs.chdir(DOCROOT .. "/" .. t));
  local fp = assert(io.open(f, "w"));
  fp:close();
  assert(g_lfs.chdir(cwd));
  (T[t])[f] = _f
end
-- ===============================================================
function is_fld(t, f)
  assert ( t ~= nil) 
  assert ( f ~= nil) 
  assert (type(t) == "string")
  assert (type(f) == "string")
  if ( T[t] == nil ) then return false end 
  if ( (T[t])[f] == nil ) then return false end 
  return true
end
-- ===============================================================
function exec_show_tables (J)
  nT = 0
  for k, v in pairs(T) do
    print(k);
    nT = nT + 1
  end
  if ( nT == 0 ) then print ("No tables exist") end 
  return nil
end
-- ===============================================================
function list_flds (t)
  if ( is_tbl(t) == false ) then return nil end
  for k, v in pairs(T[t]) do
    if ( type(v) == "table" ) then 
       print(k);
     end
  end
end

function reset_docroot(d)
  local x  = lfs.attributes(d);
  if ( x == nil ) then
    print("DOCROOT does not exist. No need to delete");
  else
    print("DOCROOT exists. Deleting...");
    os.execute("rm -r -f " .. DOCROOT);
    --[[
    Unfortunately, rmdir does not do a recursive delete
    TODO: Consider implementing this in Lua
    status = lfs.rmdir(d)
    if ( status == nil ) then
      print("Unable to delete DOCROOT = " .. d)
      os.exit();
    end
    --]]
  end
  status = lfs.mkdir(d)
  if ( status == nil ) then
    print("Unable to make DOCROOT = " .. d)
    os.exit();
  end
end
-- ==============================================

function dump_to_file(tbl_file, fld_file)

  assert(tbl_file ~= nil)
  assert(tostring(tbl_file))

  assert(fld_file ~= nil)
  assert(tostring(fld_file))
  assert(tbl_file ~= fld_file)

  -- write entries for tbl file 
  assert(io.output(tbl_file))
  for k1, v1 in pairs(T) do
    for k2, v2 in pairs(v1) do
      if ( type(v2) ~= "table" ) then 
        io.write(string.format("tbl=%s,%s=%s\n", k1,k2, v2))
      end
    end
  end
  -- write entries for fld file 
  assert(io.output(fld_file))
  for k1, v1 in pairs(T) do
    for k2, v2 in pairs(v1) do
      if ( type(v2) == "table" ) then 
        for k3, v3 in pairs(v2) do
          io.write(string.format("tbl=%s,fld=%s,%s=%s\n", k1, k2, k3, v3))
        end
      end
    end
  end

end
--=======================================================

function file_to_json_tbl(json_file)
  local json = (loadfile "../../../LUA/json.lua")() -- TOOD: FIX
  assert(file_exists(json_file))
  assert(io.input(json_file))
  local json_str = assert(io.read("*all"))
  assert(json_str ~= "")
  local jT = assert(json:decode(json_str))
  return jT
end

function load_meta_from_file(json_file)

  local sz = file_size(json_file)
  assert(sz > 0)
  local jT = assert(file_to_json_tbl(json_file))
  xT = nil
  xT = {}
  for k1, v1 in pairs(jT) do -- for each table
    print("k1  = " .. k1)
    _t = {}
    for k2, v2 in pairs(v1) do 
      if ( type(v2) ~= "table" ) then 
        _t[k2] = v2
      else
        -- for each field in table
        print("adding field " .. k2 .. " to table " .. k1)
       _f = {}
        for k3, v3 in pairs(v2) do
         _f[k3] = v3
       end
       _t[k2] = _f
       -- (_t).[k2] = _f
       -- (T[t])[f] = _f
      end
    end
    xT[k1] = _t;
  end
  T = xT
end
