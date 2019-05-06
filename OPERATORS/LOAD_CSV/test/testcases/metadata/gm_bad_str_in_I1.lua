-- test invalid data ( string in I1 field ) 
-- in the corresponding csv file string is present instead of I1
-- load_csv api should return fail for this case
return { 
  { name = "col1", qtype = "I1", has_nulls =true }
}