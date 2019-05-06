all : f_to_s.c

incl_f_to_s_min.x : tmpl_inner_f_to_s.x
	cat tmpl_inner_f_to_s.x | sed s'/OP/min/'g > incl_f_to_s_min.x

incl_f_to_s_max.x : tmpl_inner_f_to_s.x
	cat tmpl_inner_f_to_s.x | sed s'/OP/max/'g > incl_f_to_s_max.x

f_to_s.c : tmpl_inner_f_to_s.x incl_f_to_s_min.x incl_f_to_s_max.x


clean : 
	rm incl_f_to_s_min.x incl_f_to_s_max.x
