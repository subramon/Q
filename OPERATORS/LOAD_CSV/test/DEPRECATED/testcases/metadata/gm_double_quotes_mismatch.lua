-- bad double quote mismatch
-- in the corresponding csv file
-- first column value of first row does not end with double quote
return { 
  { name = "col1", qtype ="SV",dict = "D1", is_dict = false, add=true, max_width= 1024 },
  { name = "col2", qtype ="I4" }
}