# Why are we depending on print and load csv?
INCS=-I. -I../inc/ \
	-I../../../UTILS/inc/ \
	-I../../CMEM/inc/ \
	-I../../SCLR/inc/ \
	-I/usr/include/lua5.1/ \


all: libvctr.so 
	cp libvctr.so ${Q_ROOT}/lib/

clean:
	rm -f *.so *.o _*
	rm -f ${Q_ROOT}/lib/libvctr.so

GEN_INC_FILES =  \
	../../../UTILS/inc/I1_to_txt.h  \
	../../../UTILS/inc/I2_to_txt.h  \
	../../../UTILS/inc/I4_to_txt.h  \
	../../../UTILS/inc/I8_to_txt.h  \
	../../../UTILS/inc/F4_to_txt.h  \
	../../../UTILS/inc/F8_to_txt.h  \
	../../../UTILS/inc/txt_to_I1.h  \
	../../../UTILS/inc/txt_to_I2.h  \
	../../../UTILS/inc/txt_to_I4.h  \
	../../../UTILS/inc/txt_to_I8.h  \
	../../../UTILS/inc/txt_to_F4.h  \
	../../../UTILS/inc/txt_to_F8.h  \

GEN_SRC_FILES = \
	../../../UTILS/src/I1_to_txt.c \
	../../../UTILS/src/I2_to_txt.c \
	../../../UTILS/src/I4_to_txt.c \
	../../../UTILS/src/I8_to_txt.c \
	../../../UTILS/src/F4_to_txt.c \
	../../../UTILS/src/F8_to_txt.c \
	../../../UTILS/src/txt_to_I1.c  \
	../../../UTILS/src/txt_to_I2.c  \
	../../../UTILS/src/txt_to_I4.c  \
	../../../UTILS/src/txt_to_I8.c  \
	../../../UTILS/src/txt_to_F4.c  \
	../../../UTILS/src/txt_to_F8.c  \

UTILS_INC_FILES = \
	../../../UTILS/inc/B1_to_txt.h \
	../../../UTILS/inc/copy_file.h \
	../../../UTILS/inc/file_exists.h \
	../../../UTILS/inc/get_file_size.h \
	../../../UTILS/inc/get_time_usec.h \
	../../../UTILS/inc/is_valid_chars_for_num.h \
	../../../UTILS/inc/isdir.h \
	../../../UTILS/inc/isfile.h \
	../../../UTILS/inc/rdtsc.h \
	../../../UTILS/inc/rs_mmap.h \

UTILS_SRC_FILES = \
	../../../UTILS/src/B1_to_txt.c \
	../../../UTILS/src/copy_file.c \
	../../../UTILS/src/file_exists.c \
	../../../UTILS/src/get_file_size.c \
	../../../UTILS/src/is_valid_chars_for_num.c \
	../../../UTILS/src/get_time_usec.c \
	../../../UTILS/src/isdir.c \
	../../../UTILS/src/isfile.c \
	../../../UTILS/src/rdtsc.c \
	../../../UTILS/src/rs_mmap.c \

vector.o : vector.c \
	../inc/vctr_struct.h \
	../../../UTILS/inc/txt_to_I4.h \
	${UTILS_INC_FILES}
	gcc -c $(INCS) ${QCFLAGS} -Wno-discarded-qualifiers vector.c -o vector.o

core_vec.o : core_vec.c \
  	../inc/vctr_struct.h \
	../inc/core_vec.h \
	${UTILS_INC_FILES}
	gcc -c $(INCS) ${QCFLAGS} -Wno-discarded-qualifiers core_vec.c -o core_vec.o

aux_qmem.o : aux_qmem.c \
	../inc/vctr_struct.h \
	../inc/aux_qmem.h \
	${UTILS_INC_FILES} 
	gcc -c $(INCS) ${QCFLAGS} -Wno-discarded-qualifiers aux_qmem.c -o aux_qmem.o

aux_core_vec.o : aux_core_vec.c \
	../inc/vctr_struct.h \
	../inc/aux_core_vec.h \
	${UTILS_INC_FILES} 
	gcc -c $(INCS) ${QCFLAGS} aux_core_vec.c -o aux_core_vec.o

libvctr.so: vector.o core_vec.o aux_qmem.o aux_core_vec.o \
	${GEN_INC_FILES} \
	${GEN_SRC_FILES} \
	${UTILS_SRC_FILES} \
	${UTILS_INC_FILES} 
	gcc ${QCFLAGS} $(INCS) \
	  	${GEN_SRC_FILES} \
	  	${UTILS_SRC_FILES} \
		vector.o \
		../../CMEM/src/cmem.c \
		../../CMEM/src/aux_lua_to_c.c \
		core_vec.o \
		aux_core_vec.o \
		aux_qmem.o \
		-shared -o libvctr.so ${QLDFLAGS}

#------------------------------------------------------
_eval_arith.c: gen_arith.lua
	luajit gen_arith.lua
_outer_eval_arith.c: gen_arith.lua
	luajit gen_arith.lua
_eval_cmp.c: gen_cmp.lua
	luajit gen_cmp.lua
_outer_eval_cmp.c: gen_cmp.lua
	luajit gen_cmp.lua

