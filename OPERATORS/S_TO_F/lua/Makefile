# For fast version, make -e DBGFLAGS="" -e OPTFLAGS=" -O4"
#
INCS=-I.  \
     -I../../../UTILS/inc/ \
     -I../../../UTILS/gen_inc/ \
     -I../gen_inc/  \
     -I../inc/

DBGFLAGS= 
DBGFLAGS= -g -DDEBUG

OPTFLAGS= -O4
OPTFLAGS= 

CFLAGS = ${DBGFLAGS} ${OPTFLAGS} ${QC_FLAGS} 

all : _s_to_f.lua $(TMPL_FILES) $(SRC_FILES) $(INCL_FILES) $(GEN_FILES)
	luajit generator.lua operators.lua

so : libs_to_f.so 

all_for_dc : \
	_s_to_f.lua

#----------------------------------
clean :
	rm -r -f ../gen_src; 
	rm -r -f ../gen_inc; 
	rm -f _*
	rm -f *.so
		
GEN_FILES = \
	../gen_src/_const_F4.c \
	../gen_src/_period_F4.c \
	../gen_src/_rand_F4.c \
	../gen_src/_seq_F4.c \

SRC_FILES = \
	../src/rand_B1.c \
	../src/const_B1.c \

INC_FILES = \
	../inc/rand_B1.h \
	../inc/const_B1.h \

TMPL_FILES = period.tmpl rand.tmpl seq.tmpl const.tmpl

libs_to_f.so : ${GEN_FILES} ${SRC_FILES} ${INC_FILES} ${TMPL_FILES}
	luajit generator.lua operators.lua
	gcc ../gen_src/*.c ${SRC_FILES} ${CFLAGS} ${INCS} -shared -o libs_to_f.so
	test -d ${Q_BUILD_DIR}
	cp ../gen_src/*.c ${Q_BUILD_DIR}/src/
	cp ../gen_inc/*.h ${Q_BUILD_DIR}/include/
	cp ${SRC_FILES} ${Q_BUILD_DIR}/src/
	cp ${INC_FILES} ${Q_BUILD_DIR}/include/
	test -d ${Q_BUILD_DIR}

# _s_to_f.lua : $(TMPL_FILES) # $(SRC_FILES) $(INCL_FILES
# 	luajit generator.lua operators.lua
# 	lua pkg_s_to_f.lua

_s_to_f.lua : 
	lua pkg_s_to_f.lua

test_q : libs_to_f.so
	luajit ../test/test_s_to_f.lua

test_c :  libs_to_f.so
	bash ../test/test_rand.sh

test : test_q test_c

GEN_FILES = \
	_const_F4.c \
	_const_F8.c \
	_const_I1.c \
	_const_I2.c \
	_const_I4.c \
	_const_I8.c \
	_rand_F4.c \
	_rand_F8.c \
	_rand_I1.c \
	_rand_I2.c \
	_rand_I4.c \
	_rand_I8.c \
	_seq_F4.c \
	_seq_F8.c \
	_seq_I1.c \
	_seq_I2.c \
	_seq_I4.c \
	_seq_I8.c \

