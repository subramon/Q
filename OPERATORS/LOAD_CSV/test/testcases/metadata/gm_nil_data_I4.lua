-- nil data in I4 column
-- check in the corresponding csv file, 
-- in the 3rd row, second field is set to null.
-- in the 4th row, first field is set to null.
-- load_csv api should return success for this case.
return { 
  { name = "col1", qtype="I4" ,has_nulls = true},
  { name = "col2", qtype = "I4", has_nulls =true } 
}