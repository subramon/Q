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

command = ' t1 := OP=New ARGS={ "NumRows" : "4" }'
status, err = pcall(q, command)
if ( status == false ) then assert(nil, "error") end 
--========================================================
command = [[ 
t1.f1 := OP=LoadCSV ARGS={ 
  "FldType" : "I4",
  "DataFile" : "t1.csv", 
  "DataDirectory" : "/home/subramon/WORK/Q2/test/" } 
]]
status, err = pcall(q, command)
if ( status == false ) then assert(nil, err) end 
--========================================================
local _t = { "I1", "I2", "I4", "I8", "F4", "F8" }
fldval = 1
start = 1
incr = 1
for k, v in pairs(_t) do
  fldval = fldval + 10
  start = start + 1
  incr = incr + 1
  local fld = "f" .. v; local fldtype = v
  --===============================================
  command = ' t1.' .. fld .. ' := OP=Constant ARGS={ "FldType"  : "' 
  ..  fldtype .. '", "Value"   : "' .. tostring(fldval) .. '1" }'
  status, err = pcall(q, command)
  if ( status == false ) then assert(nil, err) end 
  command = 'OP=Print t1.' .. fld .. ' ARGS={ "FileName" : "_const_' 
  .. fld .. '.csv" }'
  print(command)
  status, err = pcall(q, command)
  if ( status == false ) then assert(nil, err) end 
end
command = 't1.fSC := OP=Constant ARGS={ "FldType"  : "SC", "Value"   : "1234567", "FldLen" : "7" } '
status, err = pcall(q, command)
if ( status == false ) then assert(nil, err) end 

command = 'OP=Print t1.fSC ARGS={ "FileName" : "_const_fSC.csv" } '
print(command)
status, err = pcall(q, command)
if ( status == false ) then assert(nil, err) end 
-- try printing to stdout 
command = 'OP=Print t1.fSC '
print(command)
status, err = pcall(q, command)
if ( status == false ) then assert(nil, err) end 
-- printing only a selected range
command = 'OP=Print t1|(1 3).fSC '
print(command)
status, err = pcall(q, command)
if ( status == false ) then assert(nil, err) end 


  --===============================================
-- T.f := OP=Cycle ARGS={ "FldType"  : "I4", "Start" : "1", "Increment" : "2, "Period" : " "8" } 
-- T.f := OP=Random ARGS={ "Fldtype"  : "I4", "Min"   : "1", "Max"  : "2, "Distribution" : "Uniform" }
dump_meta("_dump.json") 
os.execute("bash diff.sh")
print("Succesfully completed tests")
--========================================================
