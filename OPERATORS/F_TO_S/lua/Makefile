# For fast version, make -e DBGFLAGS="" -e OPTFLAGS=" -O4"
#
INCS=-I.  \
	-I../../../UTILS/inc/ \
	-I../../../UTILS/gen_inc/ \
	-I../gen_inc/ \
	-I../inc/

DBGFLAGS= 
DBGFLAGS= -g -DDEBUG

OPTFLAGS= -O4
OPTFLAGS= 

CFLAGS = ${DBGFLAGS} ${OPTFLAGS} ${QC_FLAGS} 

all : _f_to_s.lua \
  	${TMPL_FILES} \
  	${SRC_FILES} \
  	${INC_FILES} \
	GEN_SRC_FILES \
	GEN_INC_FILES
	
test : libf_to_s.so 

SRC_FILES : 

INC_FILES : 

#----------------------------------
clean :
	rm -r -f ../gen_src; 
	rm -r -f ../gen_inc; 
	rm -f _*
	rm -f *.so

libf_to_s.so : GEN_SRC_FILES GEN_INC_FILES SRC_FILES INC_FILES ${TMPL_FILES}
	gcc ../src/*.c ../gen_src/*.c ${CFLAGS} ${INCS} -shared -o libf_to_s.so 

_f_to_s.lua : 
	lua pkg_f_to_s.lua

TMPL_FILES = minmax.tmpl sum.tmpl

SRC_FILES = \
	    ../src/sum_B1.c 

INC_FILES = \
	    ../inc/sum_B1.h

GEN_SRC_FILES : \
	../gen_src/_sum_I1.c \
	../gen_src/_sum_I2.c \
	../gen_src/_sum_I4.c \
	../gen_src/_sum_I8.c \
	../gen_src/_sum_F4.c \
	../gen_src/_sum_F8.c \
	\
	../gen_src/_min_I1.c \
	../gen_src/_min_I2.c \
	../gen_src/_min_I4.c \
	../gen_src/_min_I8.c \
	../gen_src/_min_F4.c \
	../gen_src/_min_F8.c \
	\
	../gen_src/_max_I1.c \
	../gen_src/_max_I2.c \
	../gen_src/_max_I4.c \
	../gen_src/_max_I8.c \
	../gen_src/_max_F4.c \
	../gen_src/_max_F8.c \
	\

GEN_INC_FILES : \
	../gen_inc/_sum_F4.h \
	../gen_inc/_sum_F8.h \
	../gen_inc/_sum_I1.h \
	../gen_inc/_sum_I2.h \
	../gen_inc/_sum_I4.h \
	../gen_inc/_sum_I8.h \
	\
	../gen_inc/_min_F4.h \
	../gen_inc/_min_F8.h \
	../gen_inc/_min_I1.h \
	../gen_inc/_min_I2.h \
	../gen_inc/_min_I4.h \
	../gen_inc/_min_I8.h \
	\
	../gen_inc/_max_F4.h \
	../gen_inc/_max_F8.h \
	../gen_inc/_max_I1.h \
	../gen_inc/_max_I2.h \
	../gen_inc/_max_I4.h \
	../gen_inc/_max_I8.h 

../gen_src/_sum_I1.c : sum.tmpl sum_specialize.lua
	luajit generator.lua sum I1
../gen_src/_sum_I2.c : sum.tmpl sum_specialize.lua
	luajit generator.lua sum I2
../gen_src/_sum_I4.c : sum.tmpl sum_specialize.lua
	luajit generator.lua sum I4
../gen_src/_sum_I8.c : sum.tmpl sum_specialize.lua
	luajit generator.lua sum I8
../gen_src/_sum_F4.c : sum.tmpl sum_specialize.lua
	luajit generator.lua sum F4
../gen_src/_sum_F8.c : sum.tmpl sum_specialize.lua
	luajit generator.lua sum F8

../gen_src/_min_I1.c : minmax.tmpl min_specialize.lua
	luajit generator.lua min I1
../gen_src/_min_I2.c : minmax.tmpl min_specialize.lua
	luajit generator.lua min I2
../gen_src/_min_I4.c : minmax.tmpl min_specialize.lua
	luajit generator.lua min I4
../gen_src/_min_I8.c : minmax.tmpl min_specialize.lua
	luajit generator.lua min I8
../gen_src/_min_F4.c : minmax.tmpl min_specialize.lua
	luajit generator.lua min F4
../gen_src/_min_F8.c : minmax.tmpl min_specialize.lua
	luajit generator.lua min F8

../gen_src/_max_I1.c : minmax.tmpl max_specialize.lua
	luajit generator.lua max I1
../gen_src/_max_I2.c : minmax.tmpl max_specialize.lua
	luajit generator.lua max I2
../gen_src/_max_I4.c : minmax.tmpl max_specialize.lua
	luajit generator.lua max I4
../gen_src/_max_I8.c : minmax.tmpl max_specialize.lua
	luajit generator.lua max I8
../gen_src/_max_F4.c : minmax.tmpl max_specialize.lua
	luajit generator.lua max F4
../gen_src/_max_F8.c : minmax.tmpl max_specialize.lua
	luajit generator.lua max F8

