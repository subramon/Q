local function diff (
  file1, 
  file2
  )
  local f1 = assert(io.open(file1, "r"))
  local s1 = f1:read("*a")
  f1:close()
  local f2 = assert(io.open(file2, "r"))
  local s2 = f2:read("*a")
  f2:close()

  if ( s1 == s2 ) then return true else return false end 
end
return diff
-- x = diff("dbl_out1.csv", "_dbl_out1.csv")
-- print(x)
