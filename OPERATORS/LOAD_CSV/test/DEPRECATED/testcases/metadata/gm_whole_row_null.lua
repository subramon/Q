-- whole row nil test .
-- check in the corresponding csv file, 3rd row is set to null.
-- load_csv api should return success for this case.

return { 
  { name = "col1", qtype = "SC" , size = 15, has_nulls = true, width = 16 },
  { name = "col2", qtype = "F8", has_nulls =true } 
}