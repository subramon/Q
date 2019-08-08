#!/bin/bash
INCS=-I../inc/ -I../gen_inc/
INCDIR=../gen_inc/

all : libutils.so ${hdr_files} 

#--- START FOR LOAD 
../gen_inc/_txt_to_B1.h : 
	mkdir -p ../gen_inc/
	lua ../lua/cli_extract_func_decl.lua txt_to_B1.c ${INCDIR}

../gen_inc/_txt_to_SC.h : 
	mkdir -p ../gen_inc/
	lua ../lua/cli_extract_func_decl.lua txt_to_SC.c ${INCDIR}

txt_to_B1.c : ../gen_inc/_txt_to_B1.h

txt_to_SC.c : ../gen_inc/_txt_to_SC.h
#----------------------------------
#----------------------------------
../gen_src/_txt_to_I1.c :
	lua gen_code_I.lua 
../gen_src/_txt_to_I2.c :
	lua gen_code_I.lua 
../gen_src/_txt_to_I4.c :
	lua gen_code_I.lua 
../gen_src/_txt_to_I8.c :
	lua gen_code_I.lua 
../gen_src/_txt_to_F4.c :
	lua gen_code_F.lua 
../gen_src/_txt_to_F8.c :
	lua gen_code_F.lua 
#----------------------------------
#----------------------------------
#--======= START FOR PRINT 0
../gen_inc/_B1_to_txt.h : 
	mkdir -p ../gen_inc/
	lua ../lua/cli_extract_func_decl.lua B1_to_txt.c ${INCDIR}

../gen_inc/_SC_to_txt.h : 
	mkdir -p ../gen_inc/
	lua ../lua/cli_extract_func_decl.lua SC_to_txt.c ${INCDIR}

B1_to_txt.c : ../gen_inc/_B1_to_txt.h

SC_to_txt.c : ../gen_inc/_SC_to_txt.h
#----------------------------------
../gen_src/_I1_to_txt.c :
	luajit print_generator.lua I1
../gen_src/_I2_to_txt.c :
	luajit print_generator.lua I2
../gen_src/_I4_to_txt.c :
	luajit print_generator.lua I4
../gen_src/_I8_to_txt.c :
	luajit print_generator.lua I8
../gen_src/_F4_to_txt.c :
	luajit print_generator.lua F4
../gen_src/_F8_to_txt.c :
	luajit print_generator.lua F8
#--======= STOP FOR PRINT 0

../gen_inc/_file_exists.h : 
	lua ../lua/cli_extract_func_decl.lua file_exists.c ${INCDIR}

../gen_inc/_generate_bin.h : 
	lua ../lua/cli_extract_func_decl.lua generate_bin.c ${INCDIR}

../gen_inc/_isfile.h :
	lua ../lua/cli_extract_func_decl.lua isfile.c ${INCDIR}

../gen_inc/_isdir.h :
	lua ../lua/cli_extract_func_decl.lua isdir.c ${INCDIR}

../gen_inc/_trim.h : 
	lua ../lua/cli_extract_func_decl.lua trim.c ${INCDIR}

../gen_inc/_rand_file_name.h : 
	lua ../lua/cli_extract_func_decl.lua rand_file_name.c ${INCDIR}

../gen_inc/_get_file_size.h : 
	lua ../lua/cli_extract_func_decl.lua get_file_size.c ${INCDIR}

../gen_inc/_get_time_usec.h : 
	lua ../lua/cli_extract_func_decl.lua get_time_usec.c ${INCDIR}
  
../gen_inc/_bits_to_bytes.h : 
	lua ../lua/cli_extract_func_decl.lua bits_to_bytes.c ${INCDIR}

../gen_inc/_bytes_to_bits.h : 
	lua ../lua/cli_extract_func_decl.lua bytes_to_bits.c ${INCDIR}

../gen_inc/_get_bit_u64.h :
	lua ../lua/cli_extract_func_decl.lua get_bit_u64.c ${INCDIR}

../gen_inc/_is_valid_chars_for_num.h : 
	lua ../lua/cli_extract_func_decl.lua is_valid_chars_for_num.c ${INCDIR}

../gen_inc/_q_omp_get_num_procs.h :
	lua ../lua/cli_extract_func_decl.lua q_omp_get_num_procs.c ${INCDIR}

../gen_inc/_rdtsc.h : 
	lua ../lua/cli_extract_func_decl.lua rdtsc.c ${INCDIR}

../gen_inc/_rs_mmap.h :
	lua ../lua/cli_extract_func_decl.lua rs_mmap.c ${INCDIR}

../gen_inc/_set_bit_u64.h :
	lua ../lua/cli_extract_func_decl.lua set_bit_u64.c ${INCDIR}

hdr_files = \
	../gen_inc/_bytes_to_bits.h   \
	../gen_inc/_bits_to_bytes.h   \
	../gen_inc/_B1_to_txt.h   \
	../gen_inc/_file_exists.h  \
	../gen_inc/_generate_bin.h  \
	../gen_inc/_get_bit_u64.h \
	../gen_inc/_get_file_size.h  \
	../gen_inc/_get_time_usec.h \
	../gen_inc/_isdir.h  \
	../gen_inc/_isfile.h  \
	../gen_inc/_is_valid_chars_for_num.h  \
	../gen_inc/_q_omp_get_num_procs.h \
	../gen_inc/_rand_file_name.h  \
	../gen_inc/_rdtsc.h \
	../gen_inc/_rs_mmap.h \
	../gen_inc/_SC_to_txt.h   \
	../gen_inc/_set_bit_u64.h \
	../gen_inc/_trim.h  \

#--------
src_files =  \
	bits_to_bytes.c \
	bytes_to_bits.c \
	B1_to_txt.c \
	file_exists.c \
	generate_bin.c \
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
	txt_to_SC.c \
	../gen_src/_I1_to_txt.c  \
	../gen_src/_I2_to_txt.c  \
	../gen_src/_I4_to_txt.c  \
	../gen_src/_I8_to_txt.c  \
	../gen_src/_F4_to_txt.c  \
	../gen_src/_F8_to_txt.c \
	../gen_src/_txt_to_I1.c \
	../gen_src/_txt_to_I2.c \
	../gen_src/_txt_to_I4.c \
	../gen_src/_txt_to_I8.c \
	../gen_src/_txt_to_F4.c \
	../gen_src/_txt_to_F8.c \
#----------------------------------


libutils.so : ${hdr_files} ${src_files} 
	gcc ${QC_FLAGS} ${Q_LINK_FLAGS} ${INCS} ${src_files} -o libutils.so
	mkdir -p ${Q_BUILD_DIR}/include/
	mkdir -p ${Q_BUILD_DIR}/src/
	cp ${src_files}      ${Q_BUILD_DIR}/src/
	cp ../inc/*          ${Q_BUILD_DIR}/include/

clean :
	rm -f ../gen_src/*
	rm -f ../gen_inc/*
	rm -f _*
	rm -f *.so
	rm -f *.o

