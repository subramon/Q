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

all : _s_to_f.lua \
  	$(TMPL_FILES) \
	$(SRC_FILES) \
	$(INC_FILES) \
	GEN_SRC_FILES \
	GEN_INC_FILES

test : libs_to_f.so 

all_for_dc : \
	_s_to_f.lua

#----------------------------------
clean :
	rm -r -f ../gen_src; 
	rm -r -f ../gen_inc; 
	rm -f _*
	rm -f *.so
		
SRC_FILES = \
	../src/rand_B1.c \
	../src/const_B1.c \

INC_FILES = \
	../inc/rand_B1.h \
	../inc/const_B1.h \
	../inc/const_struct.h \
	../inc/seq_struct.h \
	../inc/rand_struct.h \
	../inc/period_struct.h \

TMPL_FILES = period.tmpl rand.tmpl seq.tmpl const.tmpl

libs_to_f.so : GEN_SRC_FILES GEN_INC_FILES \
	${SRC_FILES} ${INC_FILES} ${TMPL_FILES}
	gcc ../gen_src/*.c  ${SRC_FILES} \
	  	${CFLAGS} ${INCS} -shared -o libs_to_f.so

_s_to_f.lua : 
	luajit pkg_s_to_f.lua

GEN_SRC_FILES : \
	../gen_src/const_I1.c \
	../gen_src/const_I2.c \
	../gen_src/const_I4.c \
	../gen_src/const_I8.c \
	../gen_src/const_F4.c \
	../gen_src/const_F8.c \
	\
	../gen_src/rand_I1.c \
	../gen_src/rand_I2.c \
	../gen_src/rand_I4.c \
	../gen_src/rand_I8.c \
	../gen_src/rand_F4.c \
	../gen_src/rand_F8.c \
	\
	../gen_src/seq_I1.c \
	../gen_src/seq_I2.c \
	../gen_src/seq_I4.c \
	../gen_src/seq_I8.c \
	../gen_src/seq_F4.c \
	../gen_src/seq_F8.c 


GEN_INC_FILES : \
	../gen_inc/const_F4.h \
	../gen_inc/const_F8.h \
	../gen_inc/const_I1.h \
	../gen_inc/const_I2.h \
	../gen_inc/const_I4.h \
	../gen_inc/const_I8.h \
	\
	../gen_inc/rand_F4.h \
	../gen_inc/rand_F8.h \
	../gen_inc/rand_I1.h \
	../gen_inc/rand_I2.h \
	../gen_inc/rand_I4.h \
	../gen_inc/rand_I8.h \
	\
	../gen_inc/seq_F4.h \
	../gen_inc/seq_F8.h \
	../gen_inc/seq_I1.h \
	../gen_inc/seq_I2.h \
	../gen_inc/seq_I4.h \
	../gen_inc/seq_I8.h 

../gen_src/const_I1.c : const.tmpl const_specialize.lua
	luajit generator.lua const I1
../gen_src/const_I2.c : const.tmpl const_specialize.lua
	luajit generator.lua const I2
../gen_src/const_I4.c : const.tmpl const_specialize.lua
	luajit generator.lua const I4
../gen_src/const_I8.c : const.tmpl const_specialize.lua
	luajit generator.lua const I8
../gen_src/const_F4.c : const.tmpl const_specialize.lua
	luajit generator.lua const F4
../gen_src/const_F8.c : const.tmpl const_specialize.lua
	luajit generator.lua const F8

../gen_src/seq_I1.c : seq.tmpl seq_specialize.lua
	luajit generator.lua seq I1
../gen_src/seq_I2.c : seq.tmpl seq_specialize.lua
	luajit generator.lua seq I2
../gen_src/seq_I4.c : seq.tmpl seq_specialize.lua
	luajit generator.lua seq I4
../gen_src/seq_I8.c : seq.tmpl seq_specialize.lua
	luajit generator.lua seq I8
../gen_src/seq_F4.c : seq.tmpl seq_specialize.lua
	luajit generator.lua seq F4
../gen_src/seq_F8.c : seq.tmpl seq_specialize.lua
	luajit generator.lua seq F8

../gen_src/rand_I1.c : rand.tmpl rand_specialize.lua
	luajit generator.lua rand I1
../gen_src/rand_I2.c : rand.tmpl rand_specialize.lua
	luajit generator.lua rand I2
../gen_src/rand_I4.c : rand.tmpl rand_specialize.lua
	luajit generator.lua rand I4
../gen_src/rand_I8.c : rand.tmpl rand_specialize.lua
	luajit generator.lua rand I8
../gen_src/rand_F4.c : rand.tmpl rand_specialize.lua
	luajit generator.lua rand F4
../gen_src/rand_F8.c : rand.tmpl rand_specialize.lua
	luajit generator.lua rand F8

../gen_src/_period_I1.c : period.tmpl period_specialize.lua
	luajit generator.lua period I1
../gen_src/_period_I2.c : period.tmpl period_specialize.lua
	luajit generator.lua period I2
../gen_src/_period_I4.c : period.tmpl period_specialize.lua
	luajit generator.lua period I4
../gen_src/_period_I8.c : period.tmpl period_specialize.lua
	luajit generator.lua period I8
../gen_src/_period_F4.c : period.tmpl period_specialize.lua
	luajit generator.lua period F4
../gen_src/_period_F8.c : period.tmpl period_specialize.lua
	luajit generator.lua period F8

