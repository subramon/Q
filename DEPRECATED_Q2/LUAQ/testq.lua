#!/home/subramon/LUA/lua-5.3.0/src/lua
dofile "qinit.lua"
qinit()

--============================================
DOCROOT = "/home/subramon/DATA_STORE"
T = {}
g_lfs = require "lfs"
--
reset_docroot(DOCROOT)
local status = ""
local err = ""

status, y = pcall(q, " ?")
print("x = ", x)
if ( not status ) then print("ERROR: ", y) end 
if not y then for k, v in (y) do print(v) end end
--========================================================
---- should fail nR not positive
status, err = pcall(q, ' t1 := OP=new ARGS={ "NumRows" : "-12345678" }')
if ( status ~= false ) then assert(nil, "error"); end
--========================================================
--should fail: name too long
command = ' x012345678901234567890123456789012 := OP=new ARGS={ "NumRows" : "-12345678" }'
local x, err = pcall(q, command)
if ( x ~= false ) then assert(nil, "error"); else print("ERR = ", err) end
--========================================================
--should fail: name empty
command = [==[
JSON:{
    "verb": "add_tbl",
    "tbl": "", 
    "ARGS" : { "NumRows" : "-12345678" }
  }
]==]
status, err = pcall(q, command)
if ( status ~= false ) then assert(nil, "error"); else print("ERR = ", err) end
--========================================================
-- should fail, name starts with underscore
command = ' _t1 := OP=new ARGS={ "NumRows" : "12345678" }'
status, err = pcall(q, command)
if ( status ~= false ) then assert(nil, "error"); else print("ERR = ", err) end
--========================================================
-- should succeed
command = ' t1 := OP=New ARGS={ "NumRows" : "12345678" }'
status, err = pcall(q, command)
if ( status == false ) then assert(nil, "error") else print(err) end 
--========================================================
-- should succeed even though table already exists
command = ' t1 := OP=New ARGS={ "NumRows" : "12345678" }'
status, err = pcall(q, command)
if ( status == false ) then assert(nil, "error") end 
--========================================================
-- okay to delete table that does not exist.
command = ' - xxxx ';
status, err = pcall(q, command)
if ( status == false ) then assert(nil, "error") end 
--========================================================
-- delete table 
command = ' - t1 ';
status, err = pcall(q, command)
if ( status == false ) then assert(nil, "error") end 
--========================================================
--  check that table got deleted; TODO
--========================================================
-- re-create the deleted table
command = ' t1 := OP=New ARGS={ "NumRows" : "11" }'
status, err = pcall(q, command)
if ( status == false ) then assert(nil, "error") end 
--========================================================
-- create another table 
command = ' t2 := OP=New ARGS={ "NumRows" : "22" }'
status, err = pcall(q, command)
if ( status == false ) then assert(nil, "error") end 
--========================================================
command = [[ 
t1.f1 := OP=LoadCSV ARGS={ 
  "FldType" : "I4",
  "DataFile" : "t1.csv", 
  "DataDirectory" : "/home/subramon/WORK/Q2/LUAQ/TESTDATA/" } 
]]
status, err = pcall(q, command)
if ( status == false ) then assert(nil, err) end 
--========================================================
command = ' ? '
status, x = pcall(q, command)
if ( not status) then print("ERROR: ", x) end
if ( not x ) then for k, v in x do print(v) end end
--========================================================
command = ' ? t1 '
status, err = pcall(q, command)
if ( status == false ) then assert(nil, "error") end 
--========================================================
command = ' # t1 '
status, err = pcall(q, command)
if ( status == false ) then assert(nil, "error") end 
--========================================================
command = ' * t1 '
status, err = pcall(q, command)
if ( status == false ) then assert(nil, "error") end 
--========================================================
command = ' OP=Print t1.f1 '
status, err = pcall(q, command)
if ( status == false ) then assert(nil, "error") end 
--========================================================
command = ' t2 := OP=New ARGS={ "NumRows" : "22" }'
status, err = pcall(q, command)
if ( status == false ) then assert(nil, "error") end 
os.exit()
--========================================================
command = [[ 
t2.f2 := OP=LoadCSV ARGS={ 
  "FldType" : "I4",
  "DataFile" : "t2.csv", 
  "DataDirectory" : "/home/subramon/WORK/Q2/LUAQ/TESTDATA/" } 
]]
status, err = pcall(q, command)
if ( status == false ) then assert(nil, err) end 
--========================================================
command = ' ? t1.f1 PROP=FldType'
status, err = pcall(q, command)
if ( status == false ) then assert(nil, "error") end 
command = ' ? t1.f1 PROP=HasNullFld'
status, err = pcall(q, command)
if ( status == false ) then assert(nil, "error") end 
command = ' ? t2.f2 PROP=HasNullFld'
status, err = pcall(q, command)
if ( status == false ) then assert(nil, "error") end 
command = ' ? t2.f2 '
status, err = pcall(q, command)
if ( status == false ) then assert(nil, "error") end 
command = ' ? t2.f1 '
status, err = pcall(q, command)
if ( status == false ) then assert(nil, "error") end 
--========================================================
command = ' - t2.f2 '
status, err = pcall(q, command)
if ( status == false ) then assert(nil, "error") end 
--========================================================
dump_meta("_dump.json") 
load_meta("_dump.json")
dump_meta("_dump2.json") 
assert(os.execute("diff _dump.json _dump2.json 1>/dev/null 2>&1"), "File mismatch")
--========================================================
local x = json:encode_pretty(T)
assert(io.output("_dump.json")) -- TOOD Don't hardcode the path
assert(io.write(x))
assert(io.close())
--========================================================
command = ' + t2.f2 PROP=Sum 12345678 '
status, err = pcall(q, command)
if ( status == false ) then assert(nil, "error") else print(error) end 

command = ' ? t2.f2 PROP=Sum  '
status, err = pcall(q, command)
if ( status == false ) then assert(nil, "error") end 
print("PREMATURE"); os.exit()

--========================================================
--
local status, err = pcall(add_fld, "t0", "f1", "junk")
if ( status ~= false ) then print("ERR"); os.exit() else print(err) end
local status, err = pcall(add_fld, "t1", "", "junk")
if ( status ~= false ) then print("ERR"); os.exit() else print(err) end
local status, err = pcall(add_fld, "t1", "_x", "junk")
if ( status ~= false ) then print("ERR"); os.exit() else print(err) end
add_fld("t1", "f1I1", '{ "FldType" : "I1" }')
add_fld("t1", "f11", '{ "FldType" : "I4" }')
add_fld("t1", "f11", '{ "FldType" : "I8" }')
add_fld("t1", "f12", '{ "FldType" : "F8" }')
add_fld("t2", "f21", '{ "FldType" : "F4" }')
print("Does t1 exist? " .. tostring(is_tbl("t1")))
print("Does t3 exist? " .. tostring(is_tbl("t3")))
exec_show_tables();
print("Listing fields in t1");
list_flds("t1")
print("Listing fields in t2");
list_flds("t2");
print("Listing fields in t3");
list_flds("t3");
-- Checking single quote vs double quote
-- print("All's well that ends well")
-- sample of string with funny characters in it 
x = [===[ 
<![CDATA[
Hello world
]]>
]===]
-- print(x)

--

--=======================================================
command = [==[
JSON:{
    "verb": "add_tbl",
    "tbl": "t3",
    "ARGS" : { "NumRows" : "12345678" }
  }
]==]
x = q(command)
--=======================================================
command = [==[
JSON:{
    "verb": "tbl_meta",
    "tbl": "t3",
    "property": "NumRows"
  }
  ]==]
x = q(command); print(x)
--=======================================================
command = [==[
JSON:{
    "verb": "tbl_meta",
    "tbl": "t3",
    "property": "_RefCount"
  }
  ]==]
x = q(command); print(x)
--=======================================================
command = [==[
JSON:{
    "verb": "tbl_meta",
    "tbl": "t4",
    "property": "_Exists"
  }
  ]==]
x = q(command); print(x)
--=======================================================
command = [==[
JSON:{
    "verb": "tbl_meta",
    "tbl": "t3",
    "property": "_All"
  }
  ]==]
x = q(command); print(x)
--=======================================================
command = [==[
JSON:{
    "verb": "s_to_f",
    "tbl": "t1",
    "fld": "f13",
    "op": "Constant",
    "ARGS" : { "FldType" : "I4", "Value" : "111" }
  }
]==]
x = q(command)
--=======================================================
command = [==[
JSON:{
    "verb": "s_to_f",
    "tbl": "t1",
    "fld": "f14",
    "op": "Constant",
    "ARGS" : { "FldType" : "SC", "Value" : "ABCD", "Width" : "4"  }
  }
]==]
x = q(command)
--=======================================================
command = [==[
JSON:{
    "verb": "s_to_f",
    "tbl": "t1",
    "fld": "f13",
    "op": "Sequence",
    "ARGS" : { "FldType" : "I4", "Start" : "1", "Increment" : "2" }
  }
]==]
x = q(command)
--=======================================================
command = [==[
JSON:{
    "verb": "s_to_f",
    "tbl": "t1",
    "fld": "f15",
    "op": "Period",
    "ARGS" : { "FldType" : "I8", "Start" : "1", "Increment" : "2", "Period" : "10" }
  }
]==]
x = q(command)
--=======================================================
command = [==[
JSON:{
    "verb": "s_to_f",
    "tbl": "t1",
    "fld": "f16",
    "op": "Random",
    "ARGS" : { "FldType" : "I8", "Distribution" : "Uniform", "MinVal" : "1", "MaxVal" : "10" }
  }
]==]
x = q(command)
--=======================================================
command = [==[
JSON:{
    "verb": "show_tables"
  }
]==]
x = q(command);  print(x)
--=======================================================
command = [==[
JSON:{
    "verb": "fld_meta",
    "tbl": "t1",
    "fld": "f13",
    "property": "_FldType"
  }
  ]==]
x = q(command); print(x)
--=======================================================
command = [==[
JSON:{
    "verb": "fld_meta",
    "tbl": "t1",
    "fld": "f13",
    "property": "SortType"
  }
  ]==]
x = q(command); print(x)
--=======================================================
command = [==[
JSON:{
    "verb": "fld_meta",
    "tbl": "t1",
    "fld": "f13",
    "property": "HasLenFld"
  }
  ]==]
x = q(command); print(x)
--=======================================================
command = [==[
JSON:{
    "verb": "fld_meta",
    "tbl": "t1",
    "fld": "f13",
    "property": "HasNullFld"
  }
  ]==]
x = q(command); print(x)
--=======================================================
-- Now we set a number of field properties
-- Then we will query for them
-- Then we will unset them
-- Then we will query for them again
command = [==[
JSON:{
    "verb": "set_meta",
    "action" : "set",
    "tbl": "t1",
    "fld": "f13",
    "property": "Max",
    "value" : "200"
  }
  ]==]
x = q(command); 
--=======================================================
command = [==[
JSON:{
    "verb": "set_meta",
    "action" : "set",
    "tbl": "t1",
    "fld": "f13",
    "property": "NDV",
    "value": "100"
  }
  ]==]
x = q(command); 
--=======================================================
command = [==[
JSON:{
    "verb": "fld_meta",
    "tbl": "t1",
    "fld": "f13",
    "property": "Max"
  }
  ]==]
x = q(command);  print(x)
--=======================================================
command = [==[
JSON:{
    "verb": "fld_meta",
    "tbl": "t1",
    "fld": "f13",
    "property": "NDV"
  }
  ]==]
x = q(command);  print(x)
--=======================================================
command = [==[
JSON:{
    "verb": "set_meta",
    "action" : "unset",
    "tbl": "t1",
    "fld": "f13",
    "property": "Max"
  }
  ]==]
x = q(command); 
--=======================================================
command = [==[
JSON:{
    "verb": "set_meta",
    "action" : "unset",
    "tbl": "t1",
    "fld": "f13",
    "property": "NDV"
  }
  ]==]
x = q(command); 
--=======================================================
command = [==[
JSON:{
    "verb": "fld_meta",
    "tbl": "t1",
    "fld": "f13",
    "property": "Max"
  }
  ]==]
x = q(command);  print(x)
--=======================================================
command = [==[
JSON:{
    "verb": "fld_meta",
    "tbl": "t1",
    "fld": "f13",
    "property": "NDV"
  }
  ]==]
x = q(command);  print(x)
--=======================================================
command = [==[
JSON: { 
  "verb" : "f1opf2", 
  "tbl" : "t1", 
  "f1" : "f11", 
  "f2" : "f2", 
  "OP" : "Cast"
} 
]==]
x = q(command)
command = [==[
JSON:{ 
  "verb" : "f1opf2", 
  "tbl" : "t1", 
  "f1" : "f11", 
  "f2" : "f2", 
  "OP" : "Convert", 
  "ARGS" : {"NewFldType" : "F8" } 
} 
]==]
x = q(command)
command = [==[
JSON:{ 
  "verb" : "f1opf2", 
  "tbl" : "t1", 
  "f1" : "f11", 
  "f2" : "f2", 
  "OP" : "BitCount"
} 
]==]
x = q(command)
command = [==[
JSON:{ 
  "verb" : "f1opf2", 
  "tbl" : "t1", 
  "f1" : "f12", 
  "f2" : "f2", 
  "OP" : "Sqrt"
} 
]==]
x = q(command)
command = [==[
JSON:{ 
  "verb" : "f1opf2", 
  "tbl" : "t1", 
  "f1" : "f11", 
  "f2" : "f2", 
  "OP" : "Abs" 
} 
]==]
x = q(command)
command = [==[
JSON:{ 
  "verb" : "f1opf2", 
  "tbl" : "t1", 
  "f1" : "f11", 
  "f2" : "f2", 
  "OP" : "CRC32"
} 
]==]
x = q(command)
command = [==[
JSON:{ 
  "verb" : "f1opf2", 
  "tbl" : "t1", 
  "f1" : "f12", 
  "f2" : "f2", 
  "OP" : "Reciprocal"
} 
]==]
x = q(command)
command = [==[
JSON:{ 
  "verb" : "f1opf2", 
  "tbl" : "t1", 
  "f1" : "f12", 
  "f2" : "f2", 
  "OP" : "Accumulate"
} 
]==]
x = q(command)
command = [==[
JSON:{ 
  "verb" : "f1opf2", 
  "tbl" : "t1", 
  "f1" : "f11", 
  "f2" : "f2", 
  "OP" : "Accumulate",
  "ARGS" : { "NewFldType" : "I8" } 
} 
]==]
x = q(command)
command = [==[
JSON:{ 
  "verb" : "f1opf2", 
  "tbl" : "t1", 
  "f1" : "f1I1", 
  "f2" : "f2", 
  "OP" : "Smear",
  "ARGS" : { "Up" : "1", "Down" : "0" } 
} 
]==]
x = q(command)
command = [==[
JSON:{ 
  "verb" : "f1opf2", 
  "tbl" : "t1", 
  "f1" : "f11", 
  "f2" : "f2", 
  "OP" : "Mix"
} 
]==]
x = q(command)
command = [==[
JSON:{ 
  "verb" : "f1opf2", 
  "tbl" : "t1", 
  "f1" : "f1I1", 
  "f2" : "f2", 
  "OP" : "IdxWithReset"
} 
]==]
x = q(command)
command = [==[
JSON:{ 
  "verb" : "f1opf2", 
  "tbl" : "t1", 
  "f1" : "f1I1", 
  "f2" : "f2", 
  "OP" : "IdxWithReset",
  "ARGS" : { "NewFldType" : "I2" } 
} 
]==]
x = q(command)

print("Succesfully completed tests")
