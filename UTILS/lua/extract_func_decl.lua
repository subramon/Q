local plpath = require 'pl.path'
local plstr  = require 'pl.stringx'
-- Assumption that only one function declared in "infile"
local function extract_func_decl(
  infile,
  opdir
  )
  assert(plpath.isfile(infile), "Input file not found" .. infile)
  assert(plpath.isdir(opdir), "Output directory not found" .. opdir)
  io.input(infile)
  local code = io.read("*all")
  --=========================================
  local incs = string.match(code, "//START_INCLUDES.*//STOP_INCLUDES")
  if ( incs ) then
    incs = string.gsub(incs, "//START_INCLUDES", "")
    incs = string.gsub(incs, "//STOP_INCLUDES", "")
  end
  --=========================================
  local z = string.match(code, "//START_FUNC_DECL.*//STOP_FUNC_DECL")
  assert(type(z) == "string", "Could not find decl marker in " .. infile)
  assert(z ~= "", "Could not find stuff in START_FUNC_DECL .. STOP_FUNC_DECL")
  -- Currently, we do not allow more than one decl, hence following 
  local n1, n2 = string.find(z, "START_FUNC_DECL")
  assert(n1 >= 1)
  local m1, m2 = string.find(string.sub(z, n1+n2), "START_FUNC_DECL")
  assert(m1 == nil)
  --======
  z = string.gsub(z, "//START_FUNC_DECL", "")
  z = string.gsub(z, "//STOP_FUNC_DECL", "")
  z = plstr.strip(z)
  --=========================================
  local fn = string.gsub(infile, "^.*/", "")
  fn = string.gsub(fn, ".c$", "")
  if ( opdir ~= "" ) then
    local opfile = opdir .. "/" .. fn .. ".h"
    io.open(opfile, "w+")
    io.output(opfile)
  end
  if ( incs ) then
    io.write(incs)
  end
  io.write("#ifndef __" .. fn .. "_H\n")
  io.write("#define __" .. fn .. "_H\n")
  io.write('extern ' .. z .. ';\n')
  io.write("#endif\n")
  return true
end
return extract_func_decl

--[[
foreach
z = string.match(x, "//START.*//STOP")
> z
//START abc def //STOP
> x = "foo bar //START abc def //STOP hoo hah"
> z = string.match(x, "//START.*//STOP")
> z
//START abc def //STOP
> z = string.gsub(x, "//START", ""0
stdin:1: ')' expected near '0'
> z = string.gsub(x, "//START", "")
> z
foo bar  abc def //STOP hoo hah
> z = string.match(x, "//START.*//STOP")
> z
 abc def //STOP
 ]]

