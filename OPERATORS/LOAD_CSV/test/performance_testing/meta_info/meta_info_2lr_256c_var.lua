--testcase for 200000 rows and 256 cols with varchar
return {
    { qtype= 'SC',  width = 16, column_count= 1, has_nulls= false }, 
    { qtype= "SV",  max_width= 20, column_count= 1, max_unique_values = 200, has_nulls= true, is_dict= false, add= true },
    { qtype= 'I1', column_count= 65, has_nulls= false }, {qtype= 'I2', column_count= 63, has_nulls= false },
    { qtype= 'I4', column_count= 63, has_nulls= false }, {qtype= 'F4', column_count= 63, has_nulls= false }
  }