-- testing whether load is successfully running or not
return { 
  { name = "empid", has_nulls=true, qtype = "I4" },
  { name = "yoj", qtype ="I2" },
  { name = "empname", qtype ="SV",dict = "D1", is_dict = false, add=true, max_width= 1024} 
}