
all : vseq_specialize.lua \
	vsneq_specialize.lua \
	vsleq_specialize.lua \
	vsgeq_specialize.lua \
	vslt_specialize.lua \
	vsgt_specialize.lua  \
	shift_left_specialize.lua  \
	shift_right_specialize.lua  


vseq_specialize.lua : cmp_specialize.tmpl gen_cmp_specializers.lua
	lua gen_cmp_specializers.lua

vsneq_specialize.lua : cmp_specialize.tmpl gen_cmp_specializers.lua
	lua gen_cmp_specializers.lua

vsleq_specialize.lua : cmp_specialize.tmpl gen_cmp_specializers.lua
	lua gen_cmp_specializers.lua

vsgeq_specialize.lua : cmp_specialize.tmpl gen_cmp_specializers.lua
	lua gen_cmp_specializers.lua

vslt_specialize.lua : cmp_specialize.tmpl gen_cmp_specializers.lua
	lua gen_cmp_specializers.lua

vsgt_specialize.lua : cmp_specialize.tmpl gen_cmp_specializers.lua
	lua gen_cmp_specializers.lua

shift_left_specialize.lua : cmp_specialize.tmpl gen_cmp_specializers.lua
	lua gen_cmp_specializers.lua

shift_right_specialize.lua : cmp_specialize.tmpl gen_cmp_specializers.lua
	lua gen_cmp_specializers.lua

clean : 
	rm -f vseq_specialize.lua \
	vsneq_specialize.lua \
	vsleq_specialize.lua \
	vsgeq_specialize.lua \
	vslt_specialize.lua \
	vsgt_specialize.lua  \
	shift_left_specialize.lua  \
	shift_right_specialize.lua 

