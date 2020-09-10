# For fast version, make -e DBGFLAGS="" -e OPTFLAGS=" -O4"
#
INCS=-I.  -I../../../UTILS/inc/ -I../gen_inc/ -I../../../UTILS/gen_inc/ 

DBGFLAGS= 
DBGFLAGS= -g -DDEBUG

OPTFLAGS= -O4
OPTFLAGS= 

CFLAGS = ${DBGFLAGS} ${OPTFLAGS} ${QC_FLAGS} -Werror

all : \
	f1f2opf3.lua \
	f1f2opf3_specializers  \
	

test : libf1f2opf3.so  \
	_concat_files _arith_files _bop_files _cmp_files 
	
f1f2opf3_specializers: \
  	vvadd_specialize.lua \
	vvsub_specialize.lua \
	vvmul_specialize.lua \
	vvdiv_specialize.lua  \
	\
	vvgeq_specialize.lua \
	vvleq_specialize.lua  \
	vvgt_specialize.lua \
	vvlt_specialize.lua \
	vveq_specialize.lua \
	vvneq_specialize.lua \
	\
	vvand_specialize.lua \
	vvor_specialize.lua  \
	vvxor_specialize.lua  \
	vvandnot_specialize.lua  \
	\
	vvrem_specialize.lua 


#----------------------------------
clean :
	rm -f f1f2opf3.lua
#-----------
	rm -f vvadd_specialize.lua
	rm -f vvsub_specialize.lua
	rm -f vvmul_specialize.lua
	rm -f vvdiv_specialize.lua 
#-------------
	rm -f vveq_specialize.lua
	rm -f vvneq_specialize.lua
	rm -f vvgeq_specialize.lua
	rm -f vvleq_specialize.lua
	rm -f vvgt_specialize.lua
	rm -f vvlt_specialize.lua
#-------------
	rm -f vvrem_specialize.lua
#-------------
	rm -f vvand_specialize.lua
	rm -f vvor_specialize.lua
	rm -f vvxor_specialize.lua
	rm -f vvandnot_specialize.lua
#-------------
	rm -r -f ../gen_src; 
	rm -r -f ../gen_inc; 
	rm -f _*
	rm -f *.so
		
#-------

libf1f2opf3.so : _concat_files _arith_files _bop_files 
	gcc ../gen_src/*.c ${CFLAGS} ${INCS} -shared -o libf1f2opf3.so

_concat_files : concat_specialize.lua
	luajit concat_generator.lua 

_f1f2opf3_files : f1f2opf3_specializers
	luajit f1f2opf3_generator.lua f1f2opf3_operators.lua

f1f2opf3.lua : 
	lua pkg_f1f2opf3.lua

