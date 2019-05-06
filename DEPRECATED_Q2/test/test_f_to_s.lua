#!/home/subramon/LUA/lua-5.3.0/src/lua
dofile "../LUAQ/qinit.lua"
qinit()

--============================================
DOCROOT = "/home/subramon/DATA_STORE"
T = {}
g_lfs = require "lfs"
--
reset_docroot(DOCROOT)
local status = ""
local err = ""

command = ' t2 := OP=New ARGS={ "NumRows" : "10" }'
status, err = pcall(q, command)
if ( status == false ) then assert(nil, "error") end 
--========================================================
--========================================================
local _outer = { "Min", "Max", "Sum" }
for k1, v1 in pairs(_outer) do
  op = v1
  local _inner = { "I1", "I2", "I4", "I8", "F4", "F8" }
  fldval = 1
  start = 1
  incr = 1
  for k2, v2 in pairs(_inner) do
    fldtype = v2
    command = ' t2.f' .. fldtype .. ' := OP=LoadCSV ARGS={ ' ..
    ' "FldType" : "' .. fldtype .. '", ' ..
    ' "DataFile" : "t2.csv", ' ..
    ' "DataDirectory" : "/home/subramon/WORK/Q2/test/" } ';
    status, err = pcall(q, command)
    if ( status == false ) then assert(nil, err) end 
  
    command = ' OP=' .. op .. ' t2.f' .. fldtype 
    print(command)
    x, y = pcall(q, command)
    if ( x == false ) then 
      assert(nil, "error") 
    else 
      print(op, " = ", y.Value) 
    end
  end
end
dump_meta("_dump.json") 
os.execute("bash diff.sh")
print("Succesfully completed tests")
--========================================================
