g_q_core_h = os.getenv("Q_ROOT") .. "/include/q_core.h"
--===========================
g_max_width_SC = 1024 -- 1 char reserved for nullc
g_max_width_SV = 1024 -- 1 char reserved for nullc
g_chunk_size = 64
--===========================
g_width = {}
g_width["I1"]  = 8;
g_width["I2"] = 16;
g_width["I4"] = 32;
g_width["I8"] = 64;
g_width["F4"]   = 32;
g_width["F8"]  = 64;
--===========================
g_iwidth_to_fld = {}
g_iwidth_to_fld[1] = "I1"
g_iwidth_to_fld[2] = "I2"
g_iwidth_to_fld[4] = "I4"
g_iwidth_to_fld[8] = "I8"
g_fwidth_to_fld = {}
g_fwidth_to_fld[4] = "F4"
g_fwidth_to_fld[8] = "F8"
--===========================
g_iorf = {}
g_iorf["I1"]  = "fixed";
g_iorf["I2"] = "fixed";
g_iorf["I4"] = "fixed";
g_iorf["I8"] = "fixed";
g_iorf["F4"]   = "floating_point";
g_iorf["F8"]  = "floating_point";
--===========================

g_qtypes = {}
g_qtypes.I1 = { short_code = "I1", max_txt_width  = 32, width = 1, ctype = "int8_t", txt_to_ctype = "txt_to_I1", ctype_to_txt = "I1_to_txt", max_length="6"}
g_qtypes.I2 = { short_code = "I2", max_txt_width  = 32, width = 2, ctype = "int16_t", txt_to_ctype = "txt_to_I2", ctype_to_txt = "I2_to_txt", max_length="8" }
g_qtypes.I4 = { short_code = "I4", max_txt_width = 32, width = 4, ctype = "int32_t", txt_to_ctype = "txt_to_I4", ctype_to_txt = "I4_to_txt", max_length="13" }
g_qtypes.I8 = { short_code = "I8", max_txt_width = 32, width = 8, ctype = "int64_t", txt_to_ctype = "txt_to_I8", ctype_to_txt = "I8_to_txt", max_length="22" }
g_qtypes.F4 = { short_code = "F4", max_txt_width = 32, width = 4, ctype = "float", txt_to_ctype = "txt_to_F4", ctype_to_txt = "F4_to_txt", max_length="33" }
g_qtypes.F8 = { short_code = "F8", max_txt_width = 32, width = 8, ctype = "double", txt_to_ctype = "txt_to_F8", ctype_to_txt = "F8_to_txt", max_length="65" }
g_qtypes.SV = { short_code = "SV", width = 4, ctype = "int32_t", txt_to_ctype = "txt_to_I4", ctype_to_txt = "I4_to_txt", max_length="13"}
g_qtypes.SC = { short_code = "SC", width = 8, ctype = "char", txt_to_ctype = "txt_to_SC", ctype_to_txt = "SC_to_txt" }
g_qtypes.TM = { short_code = "TM", max_txt_width = 64, ctype = "struct tm", txt_to_ctype = "txt_to_TM", ctype_to_txt = "TBD" }
g_qtypes.B1 = { short_code = "B1", max_txt_width = 2, width = 1/8, ctype = "unsigned char", txt_to_ctype = "", ctype_to_txt = "TBD" }


g_valid_types = {}
g_valid_types['I1'] = "int8_t"
g_valid_types['I2'] = "int16_t"
g_valid_types['I4'] = "int32_t"
g_valid_types['I8'] = "int64_t"
g_valid_types['F4'] = "float"
g_valid_types['F8'] = "double"
g_valid_types['SV'] = "int32_t"
g_valid_types['SC'] = "char"
g_valid_types['B1'] = "uint64_t"
