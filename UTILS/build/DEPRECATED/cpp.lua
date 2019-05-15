-- Acts like the C pre-processor in terms of dealing with ifndef statements
--
--
local function cpp(
  infile,
  outfile
  )

  local plpath = require 'pl.path'
  assert(plpath.isfile(infile), "Input file not found" .. infile)
  assert(infile ~= outfile, "Input file same as output")

  local outlines = {}
  local seen = {}
  local in_ifndef = false
  local lno = 1
  local label = ""
  for line in io.lines(infile) do 
    local pr = true
    --=========================================
    start, stop = string.find(line, "#define[ ]*__")
    if ( start ) then
      pr = false
    end
    --=========================================
    start, stop = string.find(line, "#ifndef ")
    if ( start ) then 
      in_ifndef = true
      label = string.gsub(line, "#ifndef[ ]*__", "")
      print("Saw label", label)
      pr = false
    end
    --=========================================
    start, stop = string.find(line, "#endif")
    if ( start ) then
      assert(in_ifndef, "No matching ifndef on Line " .. lno)
      seen.label = true
      label = ""
      pr = false
    end
    --=========================================
    if ( ( in_ifndef ) and ( seen.label ) ) or ( pr == false ) then
      print("Skipping .. ", line)
    else
      outlines[#outlines+1] = line
    end

    lno = lno + 1
  end
  io.output(outfile)
  io.write(table.concat(outlines, "\n"), "\n")
end
return cpp
