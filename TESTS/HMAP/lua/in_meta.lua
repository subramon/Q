-- Describe the columns. 
local M = {}
M[#M+1] = { name = "tcin",       qtype = "I4", has_nulls = false}
M[#M+1] = { name = "dist_loc_i", qtype = "I2", has_nulls = false}

M[#M+1] = { name = "num_rows_read",    qtype = "I4", has_nulls = false }
M[#M+1] = { name = "num_rows_dropped", qtype = "I4", has_nulls = false }

M[#M+1] = { name = "t_plp1", qtype = "I8", has_nulls = false }
M[#M+1] = { name = "t_plp2", qtype = "I8", has_nulls = false }

M[#M+1] = { name = "plp2_err_bmask", qtype = "I8", has_nulls = false }

M[#M+1] = { name = "plp1_error",           qtype = "I2", has_nulls = false }
M[#M+1] = { name = "skip_frmla_bmask",     qtype = "I2", has_nulls = false }
M[#M+1] = { name = "succ_frmla_bmask",     qtype = "I2", has_nulls = false }
M[#M+1] = { name = "num_models_attempted", qtype = "I2", has_nulls = false }

M[#M+1] = { name = "t_model_building", qtype = "I4", has_nulls = false }
M[#M+1] = { name = "server_idx",       qtype = "I4", has_nulls = false }
M[#M+1] = { name = "t_data_created",   qtype = "I4", has_nulls = false }
M[#M+1] = { name = "t_model_created",  qtype = "I4", has_nulls = false }
return M
