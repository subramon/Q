local fns = require 'Q/UTILS/lua/parser'


return function (
  infile, 
  outfile, 
  regex_list
  )
    local ifp = assert(io.open(infile, "r"), 
    "Unable to open input file " .. infile .. " for reading")
    local ofp = assert(io.open (outfile, "w"), 
    "Unable to open input file " .. outfile .. " for writing")
    assert(type(regex_list) == "table")

    local num_cols = #regex_list
    local num_bad_lines = 0

    local lno = 1
    for line in ifp:lines() do 
      local entry = fns["parse_csv_line"](line, ',')
      local skip = false 
      if #entry ~= num_cols then
        skip = true
      else
        -- now check for all the regex field by field here..
        for i, regex in pairs(regex_list) do
          -- skip regex checking for nil or empty string
          if regex ~= nil and regex ~= "" then 
            local start, stop = string.find(entry[i], regex) 
            if not ( ( start ) and ( start == 1 ) and 
              ( stop == string.len(entry[i]) ) ) then 
            -- if ( string.len(x) ~= string.len(entry[i]) ) then 
              skip = true 
              break
            else
              -- print(entry[i], " matches ", regex)
            end
          end 
        end
      end
      if skip == false then
        ofp:write(line, "\n") 
      else
        num_bad_lines = num_bad_lines + 1
      end 
      --[[
      if ( ( lno % 10000 ) == 0 )  then
        print("Line ", lno)
      end
      --]]
      lno = lno + 1
    end 
    ofp:close()
    print("Number of bad lines deleted = ", num_bad_lines, " out of ", lno-1)
end
