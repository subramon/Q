Entry{
  qtype = "I1",
  fn = 'txt_to_I1',
  out_type_displ = 'I1',
  out_type = 'int8_t',
  big_out_type = 'int64_t',
  min_val = 'SCHAR_MIN',
  max_val = 'SCHAR_MAX',
  converter = 'strtoll',
}
    
Entry{
  qtype = "I2",
  fn = 'txt_to_I2',
  out_type_displ = 'I2',
  out_type = 'int16_t',
  big_out_type = 'int64_t',
  min_val = 'SHRT_MIN',
  max_val = 'SHRT_MAX',
  converter = 'strtoll',
}
    
Entry{
  qtype = "I4",
  fn = 'txt_to_I4',
  out_type_displ = 'I4',
  out_type = 'int32_t',
  big_out_type = 'int64_t',
  min_val = 'INT_MIN',
  max_val = 'INT_MAX',
  converter = 'strtoll',
}
    
Entry{
  qtype = "I8",
  fn = 'txt_to_I8',
  out_type_displ = 'I8',
  out_type = 'int64_t',
  big_out_type = 'int64_t',
  min_val = 'LLONG_MIN',
  max_val = 'LLONG_MAX',
  converter = 'strtoll',
}
