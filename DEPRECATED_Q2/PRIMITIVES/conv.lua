#!/home/subramon/LUA/lua-5.3.0/src/lua
dofile "../LUAQ/aux.lua"
json = (loadfile "../../../LUA/json.lua")() -- TOOD: FIX

infile = assert(tostring(arg[1]))

--
assert(io.input(infile))
--
lfs = require("lfs")
cwd = assert(lfs.currentdir())

local x = assert(io.read("*all"))
local t  = json:decode(x)
for k, v in pairs(t) do 
  infile = k .. ".c"
  print("Processing input file ", infile)
  assert(io.input(infile))
  str = assert(io.read("*all"))
  bak_str = str

  for k2, v2 in pairs(v) do 
    str = bak_str
    outfile = assert("./src/" .. v2.OUTFILE .. ".c")
    hdrfile = assert("./inc/" .. v2.OUTFILE .. ".h")

    for k3, v3 in pairs(v2) do
      if ( k3 ~= "OUTFILE" ) then
        print("Substituting ", k3, " with ", v3)
        str = string.gsub(str, k3, v3)
      end
    end
    -- now print the output file
    code = string.gsub(str, "//<hdr>", "")
    code = string.gsub(code, "//</hdr>", "")

    --
    assert(io.output(outfile))
    assert(io.write(code))
    assert(io.close())
    -- now print the header file
    -- gsub was not working. Hence resorted to following
    pos1 = string.find(str, "//<hdr>")
    assert(pos1, "Could not find opening of hdr")
    pos2 = string.find(str, "//</hdr>")
    assert(pos2, "Could not find closing of hdr")
    prototype = string.sub(str, pos1+8, pos2-1);
    assert( prototype ~= "" ) 
    hdr = "extern " .. prototype .. ";\n"
    assert(io.output(hdrfile))
    assert(io.write(hdr))
    assert(io.close())
    --
    print("Produced ", hdrfile, " and ", outfile)
  end
end
print("Completed all file creation")
--
