#!/bin/ballsh
INCS=-I../inc/ -I../inc/
INCDIR=../inc/


all : libutils.so gen_src_files src_files gen_inc_files


gen_inc_files : \
	../inc/txt_to_B1.h \
	../inc/txt_to_SC.h \
	../inc/txt_to_I1.h \
	../inc/txt_to_I2.h \
	../inc/txt_to_I4.h \
	../inc/txt_to_I8.h \
	../inc/txt_to_F4.h \
	../inc/txt_to_F8.h \
	../inc/B1_to_txt.h \
	../inc/SC_to_txt.h \
	../inc/I1_to_txt.h \
	../inc/I2_to_txt.h \
	../inc/I4_to_txt.h \
	../inc/I8_to_txt.h \
	../inc/F4_to_txt.h \
	../inc/F8_to_txt.h \
	../inc/copy_file.h \
	../inc/file_exists.h \
	../inc/isfile.h \
	../inc/isdir.h \
	../inc/rand_file_name.h \
	../inc/get_bit_u64.h \
	../inc/get_file_size.h \
	../inc/get_time_usec.h \
	../inc/get_bit_u64.h \
	../inc/is_valid_chars_for_num.h \
	../inc/q_omp_get_num_procs.h \
	../inc/rdtsc.h \
	../inc/rs_mmap.h \
	../inc/set_bit_u64.h \
	../inc/trim.h 


src_files :  \
	copy_file.c \
	B1_to_txt.c \
	file_exists.c \
	get_bit_u64.c  \
	get_file_size.c \
	get_time_usec.c \
	is_valid_chars_for_num.c \
	isfile.c \
	isdir.c \
	q_omp_get_num_procs.c  \
	rand_file_name.c \
	rdtsc.c \
	rs_mmap.c \
	SC_to_txt.c \
	set_bit_u64.c  \
	spooky_hash.c \
	trim.c \
	txt_to_B1.c \
	txt_to_SC.c 

gen_src_files : \
	../src/I1_to_txt.c  \
	../src/I2_to_txt.c  \
	../src/I4_to_txt.c  \
	../src/I8_to_txt.c  \
	../src/F4_to_txt.c  \
	../src/F8_to_txt.c \
	../src/txt_to_I1.c \
	../src/txt_to_I2.c \
	../src/txt_to_I4.c \
	../src/txt_to_I8.c \
	../src/txt_to_F4.c \
	../src/txt_to_F8.c \
#----------------------------------

# the purpose of test is to run a quick test on *all* the code here
test : libutils.so 
	
../inc/txt_to_B1.h : 
	luajit ../src/cli_extract_func_decl.lua txt_to_B1.c ${INCDIR}
../inc/txt_to_SC.h :
	luajit ../src/cli_extract_func_decl.lua txt_to_SC.c ${INCDIR}
txt_to_B1.c : ../inc/txt_to_B1.h
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
../inc/B1_to_txt.h : 
	lua ../src/cli_extract_func_decl.lua B1_to_txt.c ${INCDIR}
../inc/SC_to_txt.h : 
	lua ../src/cli_extract_func_decl.lua SC_to_txt.c ${INCDIR}
B1_to_txt.c : ../inc/B1_to_txt.h
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

../inc/get_time_usec.h : 
	luajit ../src/cli_extract_func_decl.lua get_time_usec.c ${INCDIR}
  
../inc/get_bit_u64.h :
	luajit ../src/cli_extract_func_decl.lua get_bit_u64.c ${INCDIR}

../inc/is_valid_chars_for_num.h : 
	luajit ../src/cli_extract_func_decl.lua is_valid_chars_for_num.c ${INCDIR}

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

GEN_INC_FILES = \
	../inc/B1_to_txt.h   \
	../inc/file_exists.h  \
	../inc/get_bit_u64.h \
	../inc/get_file_size.h  \
	../inc/get_time_usec.h \
	../inc/isdir.h  \
	../inc/isfile.h  \
	../inc/is_valid_chars_for_num.h  \
	../inc/q_omp_get_num_procs.h \
	../inc/rand_file_name.h  \
	../inc/rdtsc.h \
	../inc/rs_mmap.h \
	../inc/SC_to_txt.h   \
	../inc/set_bit_u64.h \
	../inc/trim.h  \

#--------
SRC_FILES =  \
	copy_file.c \
	B1_to_txt.c \
	file_exists.c \
	get_bit_u64.c  \
	get_file_size.c \
	get_time_usec.c \
	is_valid_chars_for_num.c \
	isfile.c \
	isdir.c \
	q_omp_get_num_procs.c  \
	qtypes.c \
	rand_file_name.c \
	rdtsc.c \
	rs_mmap.c \
	SC_to_txt.c \
	set_bit_u64.c  \
	spooky_hash.c \
	trim.c \
	txt_to_B1.c \
	txt_to_SC.c \

GEN_SRC_FILES = \
	../src/I1_to_txt.c  \
	../src/I2_to_txt.c  \
	../src/I4_to_txt.c  \
	../src/I8_to_txt.c  \
	../src/F4_to_txt.c  \
	../src/F8_to_txt.c \
	../src/txt_to_I1.c \
	../src/txt_to_I2.c \
	../src/txt_to_I4.c \
	../src/txt_to_I8.c \
	../src/txt_to_F4.c \
	../src/txt_to_F8.c \
#----------------------------------


libutils.so : src_files gen_src_files gen_inc_files
	gcc -shared ${QC_FLAGS} ${Q_LINK_FLAGS} ${INCS} \
		${GEN_SRC_FILES} \
		${SRC_FILES} -o libutils.so
	cp libutils.so ${Q_ROOT}/lib/

clean :
	rm -f _*
	rm -f *.so
	rm -f *.o
	rm -f  ${Q_ROOT}/lib/libutils.so 


# do not use following unless you absolutely need to
# else, it breaks the build from UTILS/build/
hardclean :
	rm -f ${GEN_SRC_FILES} ${GEN_INC_FILES}
