# For fast version, make -e DBGFLAGS="" -e OPTFLAGS=" -O4"
#
INCS=-I.  -I../../../UTILS/inc/ -I../gen_inc/ -I../../../UTILS/gen_inc/

DBGFLAGS= 
DBGFLAGS= -g -DDEBUG

OPTFLAGS= -O4
OPTFLAGS= 

CFLAGS = ${DBGFLAGS} ${OPTFLAGS} ${QC_FLAGS} 

all \
  	: f1s1opf2.lua \
	f1opf2_specializers \
	arith_specializers \
	cmp_specializers 
	
so : libf1s1opf2.so

f1opf2_specializers: f1opf2_specialize.tmpl \
	abs_specialize.lua \
	sqrt_specialize.lua \
	sqr_specialize.lua \
	log_specialize.lua exp_specialize.lua \
	logit_specialize.lua logit2_specialize.lua 
	luajit gen_specializers.lua f1opf2

arith_specializers: arith_specialize.tmpl \
	vsadd_specialize.lua vssub_specialize.lua \
	vsmul_specialize.lua vsdiv_specialize.lua \
	vsrem_specialize.lua vsxor_specialize.lua \
	vsand_specialize.lua vsor_specialize.lua   \
	pow_specialize.lua
	luajit gen_specializers.lua arith

cmp_specializers: vsgeq_specialize.lua vsleq_specialize.lua  \
	vsgt_specialize.lua vslt_specialize.lua \
	vseq_specialize.lua vsneq_specialize.lua 
	luajit gen_specializers.lua cmp


#----------------------------------
clean :
	rm -f libf1s1opf2.so f1s1opf2.lua
	rm -f vsadd_specialize.lua
	rm -f vssub_specialize.lua
	rm -f vsmul_specialize.lua
	rm -f vsdiv_specialize.lua 
#-------------
	rm -f vseq_specialize.lua
	rm -f vsneq_specialize.lua
	rm -f vsgeq_specialize.lua
	rm -f vsleq_specialize.lua
	rm -f vsgt_specialize.lua
	rm -f vslt_specialize.lua
#-------------
	rm -f vsrem_specialize.lua
	rm -f vsand_specialize.lua
	rm -f vsor_specialize.lua
	rm -f vsxor_specialize.lua
#-------------
	rm -f decr_specialize.lua
	rm -f exp_specialize.lua
	rm -f incr_specialize.lua
	rm -f log_specialize.lua
	rm -f sqrt_specialize.lua
	rm -f sqr_specialize.lua
	rm -f pow_specialize.lua
	rm -f logit_specialize.lua
	rm -f logit2_specialize.lua
#-------------
	rm -r -f ../gen_src; 
	rm -r -f ../gen_inc; 
	rm -f _*
		
vsadd_specialize.lua : arith_specialize.tmpl
	lua gen_specializers.lua arith
vssub_specialize.lua : arith_specialize.tmpl
	lua gen_specializers.lua arith
vsmul_specialize.lua : arith_specialize.tmpl
	lua gen_specializers.lua arith
vsdiv_specialize.lua : arith_specialize.tmpl
	lua gen_specializers.lua arith
#-------------------
vsand_specialize.lua  : rem_specialize.tmpl
	lua gen_specializers.lua bop
vsor_specialize.lua  : rem_specialize.tmpl
	lua gen_specializers.lua bop
vsxor_specialize.lua  : rem_specialize.tmpl
	lua gen_specializers.lua bop
vseq_specialize.lua  : cmp_specialize.tmpl
	lua gen_specializers.lua cmp
vsneq_specialize.lua  : cmp_specialize.tmpl
	lua gen_specializers.lua cmp
vsgeq_specialize.lua  : cmp_specialize.tmpl
	lua gen_specializers.lua cmp
vsleq_specialize.lua   : cmp_specialize.tmpl
	lua gen_specializers.lua cmp
vsgt_specialize.lua  : cmp_specialize.tmpl
	lua gen_specializers.lua cmp
vslt_specialize.lua  : cmp_specialize.tmpl
	lua gen_specializers.lua cmp
#---------------------
abs_specialize.lua  : f1opf2_specialize.tmpl
	lua gen_specializers.lua f1opf2
decr_specialize.lua  : f1opf2_specialize.tmpl
	lua gen_specializers.lua f1opf2
exp_specialize.lua  : f1opf2_specialize.tmpl
	lua gen_specializers.lua f1opf2
incr_specialize.lua  : f1opf2_specialize.tmpl
	lua gen_specializers.lua f1opf2
log_specialize.lua  : f1opf2_specialize.tmpl
	lua gen_specializers.lua f1opf2
logit_specialize.lua  : f1opf2_specialize.tmpl
	lua gen_specializers.lua f1opf2
logit2_specialize.lua  : f1opf2_specialize.tmpl
	lua gen_specializers.lua f1opf2
pow_specialize.lua  : arith_specialize.tmpl
	lua gen_specializers.lua arith
sqr_specialize.lua  : f1opf2_specialize.tmpl
	lua gen_specializers.lua f1opf2
sqrt_specialize.lua  : f1opf2_specialize.tmpl
	lua gen_specializers.lua f1opf2

libf1s1opf2.so : _arith_files  \
	_cum_cnt_files  \
	_is_prev_files \
	_cmp_files \
	_shift_files \
	_f1opf2_files \
	_convert_files \
	_vnot_files 
	gcc ../gen_src/*.c ${CFLAGS} ${INCS} -shared -o libf1s1opf2.so

_is_prev_files : is_prev_specialize.lua is_prev.tmpl
	luajit generator_is_prev.lua

_convert_files : convert_specialize.lua
	luajit generator_conv.lua

_cum_cnt_files : cum_cnt_specialize.lua
	luajit generator_cum_cnt.lua
		
_vnot_files : vnot_specialize.lua
	luajit generator_vnot.lua
		
_shift_files : shift_left_specialize.lua shift_right_specialize.lua
	luajit generator_shift.lua 

_cmp_files : cmp_specializers
	luajit generator1.lua cmp_operators.lua

_f1opf2_files : f1opf2_specializers
	luajit generator_unary_ops.lua unary_ops.lua

_arith_files : arith_specializers
	luajit generator1.lua operators1.lua

f1s1opf2.lua : 
	lua pkg_f1s1opf2.lua

