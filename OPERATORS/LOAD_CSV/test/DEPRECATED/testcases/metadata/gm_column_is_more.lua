-- column count in csv file does not match with column count in metadata ( col_meta > col_csv )
return { 
  { name = "col1", qtype = "I4", has_nulls =true },
  { name = "col2", qtype ="I2" },
  { name = "col3", qtype ="SV",dict = "D1", is_dict = false, add=true, max_width= 1024},
  { name = "extrac_column", qtype ="I2" }
}