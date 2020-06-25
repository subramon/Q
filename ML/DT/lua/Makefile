# For fast version, make -e DBGFLAGS="" -e OPTFLAGS=" -O4"
#
INCS=-I.  \
	-I../../../UTILS/inc/ \
	-I../inc/ \
	-I../gen_inc/ \
	-I../../../UTILS/gen_inc/ 

DBGFLAGS= 
DBGFLAGS= -g -DDEBUG

OPTFLAGS= -O4
OPTFLAGS= 

CFLAGS = ${DBGFLAGS} ${OPTFLAGS} ${QC_FLAGS} 

all : libcum_for_dt.so

all_for_dc:
	cp ../src/*.c ${Q_BUILD_DIR}/src/
	cp ../inc/*.h ${Q_BUILD_DIR}/include/
	echo "Nothing to do"
	
#----------------------------------
clean :
	rm -r -f ../gen_src; 
	rm -r -f ../gen_inc; 
	rm -f _*
	rm -f *.so

libcum_for_dt.so : ${GEN_FILES} \
	cum_for_dt.tmpl
	luajit cum_for_dt_generator.lua
	luajit cum_for_evan_dt_generator.lua
	luajit generator_dt_benefit.lua
	gcc ${GEN_FILES} ${AUX_FILES} ${CFLAGS} ${INCS} ${Q_LINK_FLAGS} -o libcum_for_dt.so
	test -d ${Q_BUILD_DIR}
	cp ../gen_src/*.c ${Q_BUILD_DIR}/src/
	cp ../gen_inc/*.h ${Q_BUILD_DIR}/include/
	cp ../src/*.c ${Q_BUILD_DIR}/src/
	cp ../inc/*.h ${Q_BUILD_DIR}/include/

test_q : libcum_for_dt.so
	echo "TODO"

test_c :  libcum_for_dt.so
	echo "TODO"

test : test_q test_c

SRC_FILES = \
	    ../src/benefit.c 

GEN_FILES = \
	../gen_src/_cum_for_dt_F4_I1.c \
	../gen_src/_cum_for_dt_F8_I1.c \
	../gen_src/_cum_for_dt_I1_I1.c \
	../gen_src/_cum_for_dt_I2_I1.c \
	../gen_src/_cum_for_dt_I4_I1.c \
	../gen_src/_cum_for_dt_I8_I1.c \
	../gen_src/_cum_for_dt_F4_I2.c \
	../gen_src/_cum_for_dt_F8_I2.c \
	../gen_src/_cum_for_dt_I1_I2.c \
	../gen_src/_cum_for_dt_I2_I2.c \
	../gen_src/_cum_for_dt_I4_I2.c \
	../gen_src/_cum_for_dt_I8_I2.c \
	../gen_src/_cum_for_dt_F4_I4.c \
	../gen_src/_cum_for_dt_F8_I4.c \
	../gen_src/_cum_for_dt_I1_I4.c \
	../gen_src/_cum_for_dt_I2_I4.c \
	../gen_src/_cum_for_dt_I4_I4.c \
	../gen_src/_cum_for_dt_I8_I4.c \
	../gen_src/_cum_for_dt_F4_I8.c \
	../gen_src/_cum_for_dt_F8_I8.c \
	../gen_src/_cum_for_dt_I1_I8.c \
	../gen_src/_cum_for_dt_I2_I8.c \
	../gen_src/_cum_for_dt_I4_I8.c \
	../gen_src/_cum_for_dt_I8_I8.c \
	\
	../gen_src/_dt_benefit_I1_I4.c \
	../gen_src/_dt_benefit_I2_I4.c \
	../gen_src/_dt_benefit_I4_I4.c \
	../gen_src/_dt_benefit_I8_I4.c \
	../gen_src/_dt_benefit_F4_I4.c \
	../gen_src/_dt_benefit_F8_I4.c \
	\
	../gen_src/_cum_for_evan_dt_F4_F4.c \
	../gen_src/_cum_for_evan_dt_F4_F8.c \
	../gen_src/_cum_for_evan_dt_F4_I1.c \
	../gen_src/_cum_for_evan_dt_F4_I2.c \
	../gen_src/_cum_for_evan_dt_F4_I4.c \
	../gen_src/_cum_for_evan_dt_F4_I8.c \
	../gen_src/_cum_for_evan_dt_F8_F4.c \
	../gen_src/_cum_for_evan_dt_F8_F8.c \
	../gen_src/_cum_for_evan_dt_F8_I1.c \
	../gen_src/_cum_for_evan_dt_F8_I2.c \
	../gen_src/_cum_for_evan_dt_F8_I4.c \
	../gen_src/_cum_for_evan_dt_F8_I8.c \
	../gen_src/_cum_for_evan_dt_I1_F4.c \
	../gen_src/_cum_for_evan_dt_I1_F8.c \
	../gen_src/_cum_for_evan_dt_I1_I1.c \
	../gen_src/_cum_for_evan_dt_I1_I2.c \
	../gen_src/_cum_for_evan_dt_I1_I4.c \
	../gen_src/_cum_for_evan_dt_I1_I8.c \
	../gen_src/_cum_for_evan_dt_I2_F4.c \
	../gen_src/_cum_for_evan_dt_I2_F8.c \
	../gen_src/_cum_for_evan_dt_I2_I1.c \
	../gen_src/_cum_for_evan_dt_I2_I2.c \
	../gen_src/_cum_for_evan_dt_I2_I4.c \
	../gen_src/_cum_for_evan_dt_I2_I8.c \
	../gen_src/_cum_for_evan_dt_I4_F4.c \
	../gen_src/_cum_for_evan_dt_I4_F8.c \
	../gen_src/_cum_for_evan_dt_I4_I1.c \
	../gen_src/_cum_for_evan_dt_I4_I2.c \
	../gen_src/_cum_for_evan_dt_I4_I4.c \
	../gen_src/_cum_for_evan_dt_I4_I8.c \
	../gen_src/_cum_for_evan_dt_I8_F4.c \
	../gen_src/_cum_for_evan_dt_I8_F8.c \
	../gen_src/_cum_for_evan_dt_I8_I1.c \
	../gen_src/_cum_for_evan_dt_I8_I2.c \
	../gen_src/_cum_for_evan_dt_I8_I4.c \
	../gen_src/_cum_for_evan_dt_I8_I8.c \

