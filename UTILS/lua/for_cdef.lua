-- Given an input file
-- 1) Extract portion(s) between
-- //START_FOR_CDEF and
-- //STOP_FOR_CDEF and
-- 2) Write this to a temp file
-- 2) If incs provided in a table, create an appropriate string e.g., -I../inc/
-- 3) Run the temp file through the C pre-processor with a -I string if needed
-- 3)  Remove any line that starts with # This gets rid of
--    #ifdef
--    #ifndef
--    #endif
--    #define
-- 4) Return a string with the above

local qcfg   = require 'Q/UTILS/lua/qcfg'
local exec   = require 'RSUTILS/lua/exec_and_capture_stdout'
local c_exec = require 'RSUTILS/lua/c_exec'
local cutils = require 'libcutils'

-- Creates file with name cdef_file which contains
-- the function declaration for the function(s) specified in infile
-- which are enclosed between START_FOR_CDEF and STOP_FOR_CDEF
local function for_cdef(
  infile,
  incs,
  subs
  )
  -- Determine the input file 
  local src_root = qcfg.q_src_root
  assert(type(infile) == "string")
  -- TODO P4: What if no forward slash in infile?
  if ( string.find(infile, "/") ~= 1 ) then
    -- we do not have fully qualified path
    infile = src_root .. "/" .. infile
  end
  assert(cutils.isfile(infile), "File not found: " .. infile)
  -- START: make name of cdef file 
  -- Bit ugly but we assume that file to be cdef'd is either in Q or RSUTILS
  local n1, n2 = string.find(infile, "/Q/")
  if ( not n1 ) then 
    n1, n2 = string.find(infile, "/RSUTILS/")
  end
  assert(n1 >= 1)
  local str = string.sub(infile, n2)
  local cdef_file = 
    qcfg.q_root .. "/cdefs/" .. string.gsub(str, "/", "_")
  -- STOP : make name of cdef file 
  if ( cutils.isfile(cdef_file) ) then
    -- print("Using cached version", cdef_file)
    local rslt = cutils.file_as_str(cdef_file)
    return rslt
  end
  --============================================
  -- Determine the incs i.e., -I....
  local cmd
  if ( incs ) then
    assert(type(incs) == "table")
    local str_incs = {}
    for k, v in ipairs(incs) do
      local incdir 
      if ( string.find(v, "/") ~= 1 ) then
        -- we do not have fully qualified path
        incdir = src_root .. "/" .. v
      else
        incdir = v
      end 
      assert(cutils.isdir(incdir), "Missing directory " .. incdir)
      str_incs[k] = "-I" .. incdir
    end
    incs = table.concat(str_incs, " ")
  else
    incs = ""
  end
  --===================
  local X = {}
  local fp = assert(io.open(infile))
  local is_write = true
  local cnt = 0
  for line in fp:lines() do
    if ( string.find(line, "START_FOR_CDEF", 1) ) then
      assert(is_write == true)
      is_write = false
      cnt = cnt + 1
    end
    if ( not is_write ) then
      X[#X + 1] = line
    end
    if ( string.find(line, "STOP_FOR_CDEF", 1) ) then
      assert(is_write == false)
      is_write = true
      cnt = cnt - 1
    end
  end
  assert(cnt == 0, "Mismatch between start/stop of cdef markers")
  fp:close()
  local tmpfile = os.tmpname()
  fp = io.open(tmpfile, "w")
  fp:write(table.concat(X, "\n"))
  fp:close()
  --===================
  cmd = string.format(" cpp %s %s |grep -v '^#'",
      tmpfile, incs)
  -- OLD local  rslt = assert(exec(cmd), "Failed " .. cmd)
  local  rslt = assert(c_exec(cmd), "Failed " .. cmd)
  os.remove(tmpfile)

  -- check that you do not get back empty string
  local chk = string.gsub(rslt, "%s", "")
  assert(#chk > 0, "infile = " .. infile)
  --==============
  -- cache rslt in cdef_file
  local fp = io.open(cdef_file, "w")
  fp:write(rslt)
  fp:close()
  --==============
  return rslt
end
return for_cdef
-- x = for_cdef("RUNTIME/VCTR/inc/vctr_struct.h", { "UTILS/inc/" })
-- print(x)
