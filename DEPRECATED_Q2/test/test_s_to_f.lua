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
period = 2
for k, v in pairs(_t) do
  fldval = fldval + 10
  start = start + 1
  incr = incr + 1
  if ( period == 2 ) then period = 3 end
  if ( period == 3 ) then period = 2 end
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
  --===============================================
  if ( ( fldtype ~= "F4" ) and ( fldtype ~= "F8" ) )  then
    command = ' t1.seq' .. fld .. ' := OP=Period ARGS={ ' ..
    '"FldType"  : "' ..  fldtype .. 
    '", "Start"   : "' .. tostring(start) .. 
    '", "Period"   : "' .. tostring(period) .. 
    '", "Increment" : "' .. tostring(incr) .. '" }'
    status, err = pcall(q, command)
    print(command)
    if ( status == false ) then assert(nil, err) end 
  end
  --===============================================
  command = ' t1.seq' .. fld .. ' := OP=Sequence ARGS={ ' ..
  '"FldType"  : "' ..  fldtype .. 
  '", "Start"   : "' .. tostring(start) .. 
  '", "Increment" : "' .. tostring(incr) .. '" }'
  status, err = pcall(q, command)
  print(command)
  if ( status == false ) then assert(nil, err) end 
  command = 'OP=Print t1.seq' .. fld .. ' ARGS={ "FileName" : "_seq_' 
  .. fld .. '.csv" }'
  status, err = pcall(q, command)
  if ( status == false ) then assert(nil, err) end 
end
command = 't1.fSC := OP=Constant ARGS={ "FldType"  : "SC", "Value"   : "711", "Width" : "7" } '
  --===============================================
-- T.f := OP=Cycle ARGS={ "FldType"  : "I4", "Start" : "1", "Increment" : "2, "Period" : " "8" } 
-- T.f := OP=Random ARGS={ "Fldtype"  : "I4", "Min"   : "1", "Max"  : "2, "Distribution" : "Uniform" }
dump_meta("_dump.json") 
os.execute("bash diff.sh")
print("Succesfully completed tests")
--========================================================
