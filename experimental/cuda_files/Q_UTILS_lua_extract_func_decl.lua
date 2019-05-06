#!/bin/lua
return function(infile, opdir)
local plpath = require 'pl.path'
local plstr  = require 'pl.stringx'
local plpath = require 'pl.path'
local opdir = plstr.strip(opdir)
assert(plpath.isfile(infile), "Input file not found")
assert(plpath.isdir(opdir), "Output directory not found")
io.input(infile)
code = io.read("*all")
--=========================================
incs = string.match(code, "//START_INCLUDES.*//STOP_INCLUDES")
if ( incs ) then 
  incs = string.gsub(incs, "//START_INCLUDES", "")
  incs = string.gsub(incs, "//STOP_INCLUDES", "")
end 
--=========================================
z = string.match(code, "//START_FUNC_DECL.*//STOP_FUNC_DECL")
assert(z ~= "", "Could not find stuff in START_FUNC_DECL .. STOP_FUNC_DECL")
z = string.gsub(z, "//START_FUNC_DECL", "")
z = string.gsub(z, "//STOP_FUNC_DECL", "")
z = plstr.strip(z)
--=========================================
fn = string.gsub(infile, "^.*/", "")
-- CUDA: updated regex, below regex replaces everything after last dot i.e "."
fn = string.gsub(fn, "\.[^.]*$", "")
if ( opdir ~= "" ) then 
  local basefile = string.gsub(infile, "^.*/", "") 
  opfile = opdir .. "/_" .. fn .. ".h"
  io.open(opfile, "w+")
  io.output(opfile)
end
if ( incs ) then 
  io.write(incs)
end
-- io.write("#ifndef __" .. fn .. "\n")
-- io.write("#define __" .. fn .. "\n")

io.write('extern ' .. z .. ';\n') 
-- io.write("#endif\n")
return true
end

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
 
