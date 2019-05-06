-- escape character in SV field is missing 
-- double quotes.
-- In the corresponding csv file
-- in the first line one backlash character 
-- which is used for escaping double quotes is missing
return { 
  { name = "col1", qtype ="SV",dict = "D1", is_dict = false, add=true, max_width= 1024}
}