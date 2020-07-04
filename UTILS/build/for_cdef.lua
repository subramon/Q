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

local qconsts = require 'Q/UTILS/lua/q_consts'
local exec    = require 'Q/UTILS/lua/exec_and_capture_stdout'
local cutils = require 'libcutils'

local function for_cdef(
  infile,
  incs
  )
  print("infile = ", infile)
  local src_root = qconsts.Q_SRC_ROOT
  assert(type(infile) == "string")
  if ( string.find(infile, "/") == 1 ) then 
    -- we already have fully qualified path
  else
    infile = src_root .. "/" .. infile
  end
  assert(cutils.isfile(infile), infile)
  local cmd
  local xincs = {}
  if ( incs ) then
    assert(type(incs) == "table")
    local str_incs = {}
    for k, v in ipairs(incs) do 
      local incdir = src_root .. "/" .. v
      assert(cutils.isdir(incdir))
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
  cmd = string.format( "cpp %s %s |grep -v '^#'",
      tmpfile, incs)
  local  rslt = assert(exec(cmd))
  os.remove(tmpfile)

  -- check that you do not get back empty string 
  local chk = string.gsub(rslt, "%s", "")
  assert(#chk > 0, tmpfile, infile)
  --==============
  return rslt
end
return for_cdef
-- x = for_cdef("RUNTIME/VCTR/inc/core_vec_struct.h", { "UTILS/inc/" })
-- print(x)
