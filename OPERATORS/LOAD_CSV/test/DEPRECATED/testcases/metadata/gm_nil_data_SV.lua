-- test valid nil data in null allowed SV column 
-- check in the corresponding csv file, 
-- in the 3rd row and 4th row, first field is set to null.
-- load_csv api should return success for this case.
return { 
  { name = "col1", qtype ="SV",dict = "D1", is_dict = false, add=true, has_nulls =true, max_width= 1024 },
  { name = "col2", qtype = "I4", has_nulls =true } 
}