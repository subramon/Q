-- See if the file exists
function file_exists(file)
  assert(tostring(file))
  local f = io.open(file, "rb")
  if f then f:close() end
  -- print("Checking for file " .. file);
  return f ~= nil
end

function fsize (file)
  print("file = " .. file)
  local current = file:seek()      -- get current position
  local size = file:seek("end")    -- get file size
  file:seek("set", current)        -- restore position
  return size
end

function file_size (file)
  local xlfs = require "lfs"
  local sz = assert(xlfs.attributes(file, "size"))
  return sz
end

--=== Verify that op is supported
function chk_op_supported(supported_ops, actual_op)
  found = false
  for k, v in pairs(supported_ops) do 
    if ( v == actual_op ) then found = true; return true; end
  end
  print("OP not supported --> " , actual_op); return false;
end
--==============================================
function chk_mandatory_args(mandatory_args, actual_args)

  if ( mandatory_args == nil ) then
    -- Nothing to check 
    return true
  end
  for k, v in pairs(mandatory_args) do
    assert(actual_args[v], "Mandatory arg not found " .. v)
  end
  return true
end
--==============================================
--=== Verify that fldtype is supported
function chk_fldtype(supported_fldtypes, actual_fldtype)
  for k, v in pairs(supported_fldtypes) do
    if (  v == actual_fldtype ) then found = true; return true; end
  end
  print("FldType not supported --> " , actual_fldtype); return false
end
--======================================================
