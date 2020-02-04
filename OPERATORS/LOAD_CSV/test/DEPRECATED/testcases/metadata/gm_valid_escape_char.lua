-- valid escape character in SV column
-- added double quotes as data in SV column value
-- backslash is used for escaping doublequotes and comma 
return { 
  { name = "col1", qtype ="SV",dict = "D1", is_dict = false, add=true, max_width= 1024}
}