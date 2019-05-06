# For fast version, make -e DBGFLAGS="" -e OPTFLAGS=" -O4"
#
INCS=-I.  -I../../../UTILS/inc/ -I../gen_inc/ -I../../../UTILS/gen_inc/ 

DBGFLAGS= 
DBGFLAGS= -g -DDEBUG

OPTFLAGS= -O4
OPTFLAGS= 

# CUDA: filtering the CFLAGS as it pops warnings on console
#CFLAGS = ${DBGFLAGS} ${OPTFLAGS} ${QC_FLAGS} -Werror
CFLAGS = -g -DDEBUG -Xcompiler -fPIC
all : libf1f2opf3.so all_for_dc

all_for_dc : \
  	_f1f2opf3.lua \
	arith_specializers  \
	cmp_specializers  \
	bop_specializers  \
	
arith_specializers: vvadd_specialize.lua vvsub_specialize.lua \
	vvmul_specialize.lua vvdiv_specialize.lua 
	luajit gen_specializers.lua arith

cmp_specializers: vvgeq_specialize.lua vvleq_specialize.lua  \
	vvgt_specialize.lua vvlt_specialize.lua \
	vveq_specialize.lua vvneq_specialize.lua 
	luajit gen_specializers.lua cmp

bop_specializers : vvand_specialize.lua vvor_specialize.lua  \
	vvxor_specialize.lua  vvandnot_specialize.lua  
	luajit gen_specializers.lua bop

#----------------------------------
clean :
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
	rm -f vvand_specialize.lua
	rm -f vvor_specialize.lua
	rm -f vvxor_specialize.lua
	rm -f vvandnot_specialize.lua
#-------------
	rm -r -f ../gen_src; 
	rm -r -f ../gen_inc; 
	rm -f _*
		
vvadd_specialize.lua : arith_specialize.tmpl
	lua gen_specializers.lua arith
vvsub_specialize.lua : arith_specialize.tmpl
	lua gen_specializers.lua arith
vvmul_specialize.lua : arith_specialize.tmpl
	lua gen_specializers.lua arith
vvdiv_specialize.lua : arith_specialize.tmpl
	lua gen_specializers.lua arith
vvand_specialize.lua  : bop_specialize.tmpl
	lua gen_specializers.lua bop
vvor_specialize.lua  : bop_specialize.tmpl
	lua gen_specializers.lua bop
vvxor_specialize.lua  : bop_specialize.tmpl
	lua gen_specializers.lua bop
vvandnot_specialize.lua  : bop_specialize.tmpl
	lua gen_specializers.lua bop
vveq_specialize.lua  : cmp_specialize.tmpl
	lua gen_specializers.lua cmp
vvneq_specialize.lua  : cmp_specialize.tmpl
	lua gen_specializers.lua cmp
vvgeq_specialize.lua  : cmp_specialize.tmpl
	lua gen_specializers.lua cmp
vvleq_specialize.lua   : cmp_specialize.tmpl
	lua gen_specializers.lua cmp
vvgt_specialize.lua  : cmp_specialize.tmpl
	lua gen_specializers.lua cmp
vvlt_specialize.lua  : cmp_specialize.tmpl
	lua gen_specializers.lua cmp

# CUDA: currently focus is on vvadd so using _arith_files only, also using nvcc compiler instead of gcc
libf1f2opf3.so : _arith_files
	nvcc ../gen_src/*.cu ${CFLAGS} ${INCS} -shared -o libf1f2opf3.so
	test -d ${Q_BUILD_DIR}
	cp ../gen_src/*.cu ${Q_BUILD_DIR}/src/
	cp ../gen_inc/*.h ${Q_BUILD_DIR}/include/

_concat_files : concat_specialize.lua
	luajit concat_generator.lua concat_operators.lua

_arith_files : arith_specializers
	luajit arith_generator.lua arith_operators.lua

_bop_files : bop_specializers
	luajit bop_generator.lua bop_operators.lua

_cmp_files : cmp_specializers
	luajit cmp_generator.lua cmp_operators.lua

_f1f2opf3.lua : 
	lua pkg_f1f2opf3.lua
	test -d   ${Q_TMPL_DIR}
	cp *.tmpl ${Q_TMPL_DIR}
