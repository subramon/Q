#!/bin/ballsh

CC = gcc 
INCS=-I../inc/ -I../inc/
INCDIR=../inc/

MYSO = libutils.so

EXTSO=${Q_ROOT}/lib/${MYSO}

all : ${MYSO} ${EXTSO} cli_shard_file

gen_inc_files : \
	../inc/txt_to_BL.h \
	../inc/txt_to_SC.h \
	../inc/txt_to_I1.h \
	../inc/txt_to_I2.h \
	../inc/txt_to_I4.h \
	../inc/txt_to_I8.h \
	../inc/txt_to_UI1.h \
	../inc/txt_to_UI2.h \
	../inc/txt_to_UI4.h \
	../inc/txt_to_UI8.h \
	../inc/txt_to_F4.h \
	../inc/txt_to_F8.h \
	../inc/BL_to_txt.h \
	../inc/SC_to_txt.h \
	../inc/I1_to_txt.h \
	../inc/I2_to_txt.h \
	../inc/I4_to_txt.h \
	../inc/I8_to_txt.h \
	../inc/F4_to_txt.h \
	../inc/F8_to_txt.h \
	../inc/copy_file.h \
	../inc/file_exists.h \
	../inc/isdir.h \
	../inc/isfile.h \
	../inc/is_file_in_dir.h \
	../inc/rand_file_name.h \
	../inc/get_bit_u64.h \
	../inc/get_file_size.h \
	../inc/file_as_str.h \
	../inc/mem_info.h \
	../inc/get_time_usec.h \
	../inc/get_bit_u64.h \
	../inc/is_valid_chars_for_num.h \
	../inc/mk_file.h \
	../inc/q_omp_get_num_procs.h \
	../inc/rdtsc.h \
	../inc/rs_mmap.h \
	../inc/set_bit_u64.h \
	../inc/tm2time.h  \
	../inc/trim.h 

#----------------------------------

../inc/txt_to_BL.h : 
	luajit ../src/cli_extract_func_decl.lua txt_to_BL.c ${INCDIR}
../inc/txt_to_SC.h :
	luajit ../src/cli_extract_func_decl.lua txt_to_SC.c ${INCDIR}
txt_to_BL.c : ../inc/txt_to_BL.h
txt_to_SC.c : ../inc/txt_to_SC.h
#----------------------------------
../inc/txt_to_I1.h :
	luajit gen_code_I.lua 
../inc/txt_to_I2.h :
	luajit gen_code_I.lua 
../inc/txt_to_I4.h :
	luajit gen_code_I.lua 
../inc/txt_to_I8.h :
	luajit gen_code_I.lua 
../inc/txt_to_F4.h :
	luajit gen_code_F.lua 
../inc/txt_to_F8.h :
	luajit gen_code_F.lua 
#----------------------------------
../src/txt_to_I1.c :
	luajit gen_code_I.lua 
../src/txt_to_I2.c :
	luajit gen_code_I.lua 
../src/txt_to_I4.c :
	luajit gen_code_I.lua 
../src/txt_to_I8.c :
	luajit gen_code_I.lua 
../src/txt_to_F4.c :
	luajit gen_code_F.lua 
../src/txt_to_F8.c :
	luajit gen_code_F.lua 
#----------------------------------
../inc/BL_to_txt.h : 
	lua ../src/cli_extract_func_decl.lua BL_to_txt.c ${INCDIR}
../inc/SC_to_txt.h : 
	lua ../src/cli_extract_func_decl.lua SC_to_txt.c ${INCDIR}
BL_to_txt.c : ../inc/BL_to_txt.h
SC_to_txt.c : ../inc/SC_to_txt.h
#----------------------------------
../inc/I1_to_txt.h :
	luajit print_generator.lua I1
../inc/I2_to_txt.h :
	luajit print_generator.lua I2
../inc/I4_to_txt.h :
	luajit print_generator.lua I4
../inc/I8_to_txt.h :
	luajit print_generator.lua I8
../inc/F4_to_txt.h :
	luajit print_generator.lua F4
../inc/F8_to_txt.h :
	luajit print_generator.lua F8
#----------------------------------
../src/I1_to_txt.c :
	luajit print_generator.lua I1
../src/I2_to_txt.c :
	luajit print_generator.lua I2
../src/I4_to_txt.c :
	luajit print_generator.lua I4
../src/I8_to_txt.c :
	luajit print_generator.lua I8
../src/F4_to_txt.c :
	luajit print_generator.lua F4
../src/F8_to_txt.c :
	luajit print_generator.lua F8

../inc/copy_file.h : 
	luajit ../src/cli_extract_func_decl.lua copy_file.c ${INCDIR}

../inc/file_exists.h : 
	luajit ../src/cli_extract_func_decl.lua file_exists.c ${INCDIR}

../inc/isfile.h :
	luajit ../src/cli_extract_func_decl.lua isfile.c ${INCDIR}

../inc/isdir.h :
	luajit ../src/cli_extract_func_decl.lua isdir.c ${INCDIR}

../inc/rand_file_name.h : 
	luajit ../src/cli_extract_func_decl.lua rand_file_name.c ${INCDIR}

../inc/get_file_size.h : 
	luajit ../src/cli_extract_func_decl.lua get_file_size.c ${INCDIR}

../inc/file_as_str.h : 
	luajit ../src/cli_extract_func_decl.lua file_as_str.c ${INCDIR}

../inc/mem_info.h : 
	luajit ../src/cli_extract_func_decl.lua mem_info.c ${INCDIR}

../inc/get_time_usec.h : 
	luajit ../src/cli_extract_func_decl.lua get_time_usec.c ${INCDIR}
  
../inc/get_bit_u64.h :
	luajit ../src/cli_extract_func_decl.lua get_bit_u64.c ${INCDIR}

../inc/is_valid_chars_for_num.h : 
	luajit ../src/cli_extract_func_decl.lua is_valid_chars_for_num.c ${INCDIR}

../inc/mk_file.h :
	luajit ../src/cli_extract_func_decl.lua mk_file.c ${INCDIR}

../inc/q_omp_get_num_procs.h :
	luajit ../src/cli_extract_func_decl.lua q_omp_get_num_procs.c ${INCDIR}

../inc/rdtsc.h : 
	luajit ../src/cli_extract_func_decl.lua rdtsc.c ${INCDIR}

../inc/rs_mmap.h :
	luajit ../src/cli_extract_func_decl.lua rs_mmap.c ${INCDIR}

../inc/set_bit_u64.h :
	luajit ../src/cli_extract_func_decl.lua set_bit_u64.c ${INCDIR}

../inc/trim.h : 
	luajit ../src/cli_extract_func_decl.lua trim.c ${INCDIR}

../inc/tm2time.h : 
	luajit ../src/cli_extract_func_decl.lua tm2time.c ${INCDIR}

GEN_INC_FILES = \
	../inc/BL_to_txt.h   \
	../inc/file_exists.h  \
	../inc/get_bit_u64.h \
	../inc/get_file_size.h  \
	../inc/file_as_str.h  \
	../inc/mem_info.h  \
	../inc/get_time_usec.h \
	../inc/isdir.h  \
	../inc/isfile.h  \
	../inc/is_valid_chars_for_num.h  \
	../inc/mk_file.h \
	../inc/q_omp_get_num_procs.h \
	../inc/rand_file_name.h  \
	../inc/rdtsc.h \
	../inc/rs_mmap.h \
	../inc/SC_to_txt.h   \
	../inc/set_bit_u64.h \
	../inc/trim.h  \
#--------

.c.o :
	$(CC) -c -o $@ $< $(QCFLAGS)  $(INCS)

spooky_hash.o : QCFLAGS += -Wno-implicit-fallthrough -Wno-cast-qual

SRCS := cat_to_buf.c 
SRCS += copy_file.c 
SRCS += BL_to_txt.c 
SRCS += file_exists.c 
SRCS += get_bit_u64.c  
SRCS += get_file_size.c 
SRCS += file_as_str.c 
SRCS += get_cli_arg.c 
SRCS += get_time_usec.c 
SRCS += is_valid_chars_for_num.c 
SRCS += isdir.c 
SRCS += is_file_in_dir.c 
SRCS += isfile.c 
SRCS += lookup8.c 
SRCS += mem_info.c 
SRCS += mk_file.c 
SRCS += q_omp_get_num_procs.c  
SRCS += qtypes.c 
SRCS += rand_file_name.c 
SRCS += rdtsc.c 
SRCS += rmtree.c 
SRCS += rs_mmap.c 
SRCS += SC_to_txt.c 
SRCS += set_bit_u64.c  
SRCS += spooky_hash.c 
SRCS += tm2time.c 
SRCS += shard_file.c 
SRCS += str_as_file.c 
SRCS += trim.c 
SRCS += txt_to_BL.c 
SRCS += txt_to_SC.c 
SRCS += update_lua_path.c 

OBJS = $(SRCS:.c=.o)

GEN_SRCS := ../src/I1_to_txt.c  
GEN_SRCS += ../src/I2_to_txt.c  
GEN_SRCS += ../src/I4_to_txt.c 
GEN_SRCS += ../src/I8_to_txt.c
GEN_SRCS += ../src/F4_to_txt.c
GEN_SRCS += ../src/F8_to_txt.c
GEN_SRCS += ../src/txt_to_I1.c
GEN_SRCS += ../src/txt_to_I2.c
GEN_SRCS += ../src/txt_to_I4.c
GEN_SRCS += ../src/txt_to_I8.c
GEN_SRCS += ../src/txt_to_UI1.c # TODO need to be auto-generated
GEN_SRCS += ../src/txt_to_UI2.c # TODO need to be auto-generated
GEN_SRCS += ../src/txt_to_UI4.c # TODO need to be auto-generated
GEN_SRCS += ../src/txt_to_UI8.c # TODO need to be auto-generated
GEN_SRCS += ../src/txt_to_F4.c
GEN_SRCS += ../src/txt_to_F8.c

GEN_OBJS = $(GEN_SRCS:.c=.o)
#----------------------------------

cli_shard_file : cli_shard_file.o lookup8.o
	gcc ${QCFLAGS} cli_shard_file.o $ lookup8.o ${MYSO} -o cli_shard_file

${EXTSO} : ${MYSO}
	cp ${MYSO} ${EXTSO}

${MYSO} : ${GEN_OBJS} ${OBJS}  
	gcc -shared ${QCFLAGS} ${QLDFLAGS} ${INCS} \
		${GEN_OBJS} ${OBJS} -o ${MYSO}

clean :
	rm -f _*
	rm -f *.so
	rm -f *.o
	rm -f  ${EXTSO} ${MYSO}


# do not use following unless you absolutely need to
# else, it breaks the build from UTILS/build/
hardclean :
	rm -f ${GEN_SRCS} ${GEN_INC_FILES}
