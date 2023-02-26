# For fast version, make -e DBGFLAGS="" -e OPTFLAGS=" -O4"
#
INCS=-I.  -I../../../UTILS/inc/ -I../gen_inc/ -I../../../UTILS/gen_inc/

DBGFLAGS= 
DBGFLAGS= -g -DDEBUG

OPTFLAGS= -O4
OPTFLAGS= 

CFLAGS = ${DBGFLAGS} ${OPTFLAGS} ${QC_FLAGS} 

all : \
  	f1s1opf2.lua \
	
so : libf1s1opf2.so

#----------------------------------
clean :
	rm -f libf1s1opf2.so f1s1opf2.lua
#-------------
	rm -r -f ../gen_src; 
	rm -r -f ../gen_inc; 
	rm -f _*
		
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

_cmp_files : 
	luajit generator1.lua cmp_operators.lua

_f1opf2_files : 
	luajit generator_unary_ops.lua unary_ops.lua

_arith_files : 
	luajit generator1.lua operators1.lua

f1s1opf2.lua : 
	lua pkg_f1s1opf2.lua

