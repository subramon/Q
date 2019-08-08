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
	
clean :
	rm -r -f ../gen_src; 
	rm -r -f ../gen_inc; 
	rm -f _*
	rm -f *.so

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

