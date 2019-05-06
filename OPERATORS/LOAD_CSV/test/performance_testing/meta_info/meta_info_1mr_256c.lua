--testcase for 1000000 rows and 256 cols with no varchar
return {
    { qtype= 'SC', width = 16, column_count= 1, has_nulls= false }, 
    { qtype= 'I1', column_count= 66, has_nulls= false }, {qtype= 'I2', column_count= 63, has_nulls= false },
    { qtype= 'I4', column_count= 63, has_nulls= false }, {qtype= 'F4', column_count= 63, has_nulls= false }
  }