#!/bin/bash
INCS=-I../inc/ -I../gen_inc/
INCDIR=../gen_inc/
SRCDIR=../gen_src/


all : gen_src_files gen_inc_files src_files


gen_inc_files : \
	../gen_inc/_txt_to_B1.h \
	../gen_inc/_txt_to_SC.h \
	../gen_inc/_txt_to_I1.h \
	../gen_inc/_txt_to_I2.h \
	../gen_inc/_txt_to_I4.h \
	../gen_inc/_txt_to_I8.h \
	../gen_inc/_txt_to_F4.h \
	../gen_inc/_txt_to_F8.h \
	../gen_inc/_B1_to_txt.h \
	../gen_inc/_SC_to_txt.h \
	../gen_inc/_I1_to_txt.h \
	../gen_inc/_I2_to_txt.h \
	../gen_inc/_I4_to_txt.h \
	../gen_inc/_I8_to_txt.h \
	../gen_inc/_F4_to_txt.h \
	../gen_inc/_F8_to_txt.h \
	../gen_inc/_copy_file.h \
	../gen_inc/_file_exists.h \
	../gen_inc/_isfile.h \
	../gen_inc/_isdir.h \
	../gen_inc/_rand_file_name.h \
	../gen_inc/_get_file_size.h \
	../gen_inc/_get_time_usec.h \
	../gen_inc/_get_bit_u64.h \
	../gen_inc/_is_valid_chars_for_num.h \
	../gen_inc/_q_omp_get_num_procs.h \
	../gen_inc/_rdtsc.h \
	../gen_inc/_rs_mmap.h \
	../gen_inc/_set_bit_u64.h \
	../gen_inc/_trim.h 


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

# the purpose of test is to run a quick test on *all* the code here
test : libutils.so 
	
../gen_inc/_txt_to_B1.h : $(INCDIR)
	lua ../src/cli_extract_func_decl.lua txt_to_B1.c ${INCDIR}
../gen_inc/_txt_to_SC.h : $(INCDIR)
	lua ../src/cli_extract_func_decl.lua txt_to_SC.c ${INCDIR}
txt_to_B1.c : ../gen_inc/_txt_to_B1.h
txt_to_SC.c : ../gen_inc/_txt_to_SC.h
#----------------------------------
../gen_inc/_txt_to_I1.h : $(INCDIR)
	lua gen_code_I.lua 
../gen_inc/_txt_to_I2.h : $(INCDIR)
	lua gen_code_I.lua 
../gen_inc/_txt_to_I4.h : $(INCDIR)
	lua gen_code_I.lua 
../gen_inc/_txt_to_I8.h : $(INCDIR)
	lua gen_code_I.lua 
../gen_inc/_txt_to_F4.h : $(INCDIR)
	lua gen_code_F.lua 
../gen_inc/_txt_to_F8.h : $(INCDIR)
	lua gen_code_F.lua 
#----------------------------------
../gen_src/_txt_to_I1.c : $(INCDIR)
	lua gen_code_I.lua 
../gen_src/_txt_to_I2.c : $(INCDIR)
	lua gen_code_I.lua 
../gen_src/_txt_to_I4.c : $(INCDIR)
	lua gen_code_I.lua 
../gen_src/_txt_to_I8.c : $(INCDIR)
	lua gen_code_I.lua 
../gen_src/_txt_to_F4.c : $(INCDIR)
	lua gen_code_F.lua 
../gen_src/_txt_to_F8.c : $(INCDIR)
	lua gen_code_F.lua 
#----------------------------------
../gen_inc/_B1_to_txt.h :  $(INCDIR)
	lua ../src/cli_extract_func_decl.lua B1_to_txt.c ${INCDIR}
../gen_inc/_SC_to_txt.h :  $(INCDIR)
	lua ../src/cli_extract_func_decl.lua SC_to_txt.c ${INCDIR}
B1_to_txt.c : ../gen_inc/_B1_to_txt.h
SC_to_txt.c : ../gen_inc/_SC_to_txt.h
#----------------------------------
../gen_inc/_I1_to_txt.h : $(INCDIR)
	luajit print_generator.lua I1
../gen_inc/_I2_to_txt.h : $(INCDIR)
	luajit print_generator.lua I2
../gen_inc/_I4_to_txt.h : $(INCDIR)
	luajit print_generator.lua I4
../gen_inc/_I8_to_txt.h : $(INCDIR)
	luajit print_generator.lua I8
../gen_inc/_F4_to_txt.h : $(INCDIR)
	luajit print_generator.lua F4
../gen_inc/_F8_to_txt.h : $(INCDIR)
	luajit print_generator.lua F8
#----------------------------------
../gen_src/_I1_to_txt.c : $(INCDIR)
	luajit print_generator.lua I1
../gen_src/_I2_to_txt.c : $(INCDIR)
	luajit print_generator.lua I2
../gen_src/_I4_to_txt.c : $(INCDIR)
	luajit print_generator.lua I4
../gen_src/_I8_to_txt.c : $(INCDIR)
	luajit print_generator.lua I8
../gen_src/_F4_to_txt.c : $(INCDIR)
	luajit print_generator.lua F4
../gen_src/_F8_to_txt.c : $(INCDIR)
	luajit print_generator.lua F8

../gen_inc/_copy_file.h :  $(INCDIR)
	lua ../src/cli_extract_func_decl.lua copy_file.c ${INCDIR}

../gen_inc/_file_exists.h :  $(INCDIR)
	lua ../src/cli_extract_func_decl.lua file_exists.c ${INCDIR}

../gen_inc/_isfile.h : $(INCDIR)
	lua ../src/cli_extract_func_decl.lua isfile.c ${INCDIR}

../gen_inc/_isdir.h : $(INCDIR)
	lua ../src/cli_extract_func_decl.lua isdir.c ${INCDIR}

../gen_inc/_rand_file_name.h :  $(INCDIR)
	lua ../src/cli_extract_func_decl.lua rand_file_name.c ${INCDIR}

../gen_inc/_get_file_size.h :  $(INCDIR)
	lua ../src/cli_extract_func_decl.lua get_file_size.c ${INCDIR}

../gen_inc/_get_time_usec.h :  $(INCDIR)
	lua ../src/cli_extract_func_decl.lua get_time_usec.c ${INCDIR}
  
../gen_inc/_get_bit_u64.h : $(INCDIR)
	lua ../src/cli_extract_func_decl.lua get_bit_u64.c ${INCDIR}

../gen_inc/_is_valid_chars_for_num.h :  $(INCDIR)
	lua ../src/cli_extract_func_decl.lua is_valid_chars_for_num.c ${INCDIR}

../gen_inc/_q_omp_get_num_procs.h : $(INCDIR)
	lua ../src/cli_extract_func_decl.lua q_omp_get_num_procs.c ${INCDIR}

../gen_inc/_rdtsc.h :  $(INCDIR)
	lua ../src/cli_extract_func_decl.lua rdtsc.c ${INCDIR}

../gen_inc/_rs_mmap.h : $(INCDIR)
	lua ../src/cli_extract_func_decl.lua rs_mmap.c ${INCDIR}

../gen_inc/_set_bit_u64.h : $(INCDIR)
	lua ../src/cli_extract_func_decl.lua set_bit_u64.c ${INCDIR}

../gen_inc/_trim.h :  $(INCDIR)
	lua ../src/cli_extract_func_decl.lua trim.c ${INCDIR}

gen_inc_files = \
	../gen_inc/_B1_to_txt.h   \
	../gen_inc/_file_exists.h  \
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
	txt_to_SC.c \

gen_src_files = \
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


libutils.so : ${src_files} ${gen_src_files} ${gen_inc_files}
	gcc ${QC_FLAGS} ${Q_LINK_FLAGS} ${INCS} \
		${gen_src_files} \
		${src_files} -o libutils.so

clean :
	rm -f ../gen_src/*
	rm -f ../gen_inc/*
	rm -f _*
	rm -f *.so
	rm -f *.o

