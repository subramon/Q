# For fast version, make -e DBGFLAGS="" -e OPTFLAGS=" -O4"
#
INCS= -I.  -I../../../UTILS/inc/ -I../gen_inc/  -I../../../UTILS/gen_inc 

INCDIR = ../gen_inc/

UDIR= ${Q_SRC_ROOT}/UTILS/lua/

DBGFLAGS= 
DBGFLAGS= -g -DDEBUG

OPTFLAGS= -O4
OPTFLAGS= 

CFLAGS = ${DBGFLAGS} ${OPTFLAGS} ${QC_FLAGS} 

all : libprint_csv.so 
	
../../UTILS/gen_inc/_is_valid_chars_for_num.h :
	make -C ../../../UTILS/src/ 

../gen_inc/_B1_to_txt.h : 
	mkdir -p ../gen_inc/
	lua ${UDIR}/cli_extract_func_decl.lua ../src/B1_to_txt.c ${INCDIR}

../gen_inc/_SC_to_txt.h : 
	mkdir -p ../gen_inc/
	lua ${UDIR}/cli_extract_func_decl.lua ../src/SC_to_txt.c ${INCDIR}
#----------------------------------
../gen_src/_I1_to_txt.c :
	luajit generator.lua I1
../gen_src/_I2_to_txt.c :
	luajit generator.lua I2
../gen_src/_I4_to_txt.c :
	luajit generator.lua I4
../gen_src/_I8_to_txt.c :
	luajit generator.lua I8
../gen_src/_F4_to_txt.c :
	luajit generator.lua F4
../gen_src/_F8_to_txt.c :
	luajit generator.lua F8
#----------------------------------
clean :
	rm -r -f ../gen_src; 
	rm -r -f ../gen_inc; 
	rm -f _*
	rm -f *.so

../src/B1_to_txt.c : ../gen_inc/_B1_to_txt.h

../src/SC_to_txt.c : ../gen_inc/_SC_to_txt.h

SRC_FILES =  \
	../src/SC_to_txt.c \
	../src/B1_to_txt.c \

GEN_FILES = \
	../gen_src/_I1_to_txt.c \
	../gen_src/_I2_to_txt.c  \
	../gen_src/_I4_to_txt.c  \
	../gen_src/_I8_to_txt.c  \
	../gen_src/_F4_to_txt.c  \
	../gen_src/_F8_to_txt.c  

libprint_csv.so : ${SRC_FILES} ${GEN_FILES} 
	gcc ${QC_FLAGS} ${Q_LINK_FLAGS} ${SRC_FILES} ${GEN_FILES} ${CFLAGS} ${INCS} -shared -o libprint_csv.so
	# test -d  ${Q_BUILD_DIR}/
	# cp ${SRC_FILES}      ${Q_BUILD_DIR}/src/
	# cp ../gen_inc/_SC_to_txt.h ${Q_BUILD_DIR}/include/
	# cp ../gen_inc/_B1_to_txt.h ${Q_BUILD_DIR}/include/
	# cp ../gen_src/*.c ${Q_BUILD_DIR}/src/
	# cp ../gen_inc/*.h ${Q_BUILD_DIR}/include/

test_q : libprint_csv.so
	echo "TODO"

test_c :  libprint_csv.so
	echo "TODO"

test : test_q test_c

