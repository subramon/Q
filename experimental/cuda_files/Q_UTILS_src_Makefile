#!/bin/bash
INCS=-I../inc/ -I../gen_inc/
INCDIR=../gen_inc/

# CUDA: filtering the QC_FLAGS as it pops warnings on console
QC_FLAGS = -g -DDEBUG -Xcompiler -fPIC

all : libutils.so ${hdr_files} asc2bin

../gen_inc/_file_exists.h : 
	lua ../lua/cli_extract_func_decl.lua file_exists.c ${INCDIR}

../gen_inc/_isfile.h :
	lua ../lua/cli_extract_func_decl.lua isfile.c ${INCDIR}

../gen_inc/_isdir.h :
	lua ../lua/cli_extract_func_decl.lua isdir.c ${INCDIR}

../gen_inc/_trim.h : 
	lua ../lua/cli_extract_func_decl.lua trim.c ${INCDIR}

../gen_inc/_rand_file_name.h : 
	lua ../lua/cli_extract_func_decl.lua rand_file_name.c ${INCDIR}

../gen_inc/_c_copy.h : 
	lua ../lua/cli_extract_func_decl.lua c_copy.c ${INCDIR}

../gen_inc/_c_free.h : 
	lua ../lua/cli_extract_func_decl.lua c_free.c ${INCDIR}

../gen_inc/_get_file_size.h : 
	lua ../lua/cli_extract_func_decl.lua get_file_size.c ${INCDIR}

../gen_inc/_buf_to_file.h : 
	lua ../lua/cli_extract_func_decl.lua buf_to_file.c ${INCDIR}

../gen_inc/_mix_UI4.h : 
	lua ../lua/cli_extract_func_decl.lua mix_UI4.c ${INCDIR}

../gen_inc/_mix_UI8.h : 
	lua ../lua/cli_extract_func_decl.lua mix_UI8.c ${INCDIR}

../gen_inc/_f_mmap.h : 
	lua ../lua/cli_extract_func_decl.lua f_mmap.c ${INCDIR}

../gen_inc/_f_munmap.h : 
	lua ../lua/cli_extract_func_decl.lua f_munmap.c ${INCDIR}

../gen_inc/_mmap.h : 
	lua ../lua/cli_extract_func_decl.lua mmap.c ${INCDIR}
  
../gen_inc/_munmap.h : 
	lua ../lua/cli_extract_func_decl.lua munmap.c ${INCDIR}

../gen_inc/_bytes_to_bits.h : 
	lua ../lua/cli_extract_func_decl.lua bytes_to_bits.c ${INCDIR}

#CUDA: Included cuda_malloc and cuda_free in build process
../gen_inc/_cuda_malloc.h :
	lua ../lua/cli_extract_func_decl.lua cuda_malloc.cu ${INCDIR}

../gen_inc/_cuda_free.h :
	lua ../lua/cli_extract_func_decl.lua cuda_free.cu ${INCDIR}

../gen_inc/_bits_to_bytes.h : 
	lua ../lua/cli_extract_func_decl.lua bits_to_bytes.c ${INCDIR}

../gen_inc/_write_bits_to_file.h : 
	lua ../lua/cli_extract_func_decl.lua write_bits_to_file.c ${INCDIR}

../gen_inc/_get_bit.h :
	lua ../lua/cli_extract_func_decl.lua get_bit.c ${INCDIR}

../gen_inc/_get_bit_u64.h :
	lua ../lua/cli_extract_func_decl.lua get_bit_u64.c ${INCDIR}

../gen_inc/_set_bit.h :
	lua ../lua/cli_extract_func_decl.lua set_bit.c ${INCDIR}

../gen_inc/_set_bit_u64.h :
	lua ../lua/cli_extract_func_decl.lua set_bit_u64.c ${INCDIR}

../gen_inc/_copy_file.h :
	lua ../lua/cli_extract_func_decl.lua copy_file.c ${INCDIR}

../gen_inc/_is_valid_chars_for_num.h : 
	lua ../lua/cli_extract_func_decl.lua is_valid_chars_for_num.c ${INCDIR}

../gen_inc/_generate_bin.h :
	lua ../lua/cli_extract_func_decl.lua generate_bin.c ${INCDIR}

../gen_src/_bin_search_I1.c : bin_search.tmpl bin_search_generator.lua
	lua bin_search_generator.lua I1
../gen_src/_bin_search_I2.c : bin_search.tmpl bin_search_generator.lua
	lua bin_search_generator.lua I2
../gen_src/_bin_search_I4.c : bin_search.tmpl bin_search_generator.lua
	lua bin_search_generator.lua I4
../gen_src/_bin_search_I8.c : bin_search.tmpl bin_search_generator.lua
	lua bin_search_generator.lua I8 
../gen_src/_bin_search_F4.c : bin_search.tmpl bin_search_generator.lua
	lua bin_search_generator.lua F4
../gen_src/_bin_search_F8.c : bin_search.tmpl bin_search_generator.lua
	lua bin_search_generator.lua F8

bin_search_files = \
	../gen_src/_bin_search_I1.c  \
	../gen_src/_bin_search_I2.c  \
	../gen_src/_bin_search_I4.c \
	../gen_src/_bin_search_I8.c  \
	../gen_src/_bin_search_F4.c \
	../gen_src/_bin_search_F8.c 

hdr_files = \
	../gen_inc/_mix_UI4.h  \
	../gen_inc/_mix_UI8.h  \
	../gen_inc/_rand_file_name.h  \
	../gen_inc/_file_exists.h  \
        ../gen_inc/_isfile.h  \
        ../gen_inc/_isdir.h  \
	../gen_inc/_trim.h  \
	../gen_inc/_c_copy.h  \
	../gen_inc/_c_free.h  \
	../gen_inc/_get_file_size.h  \
	../gen_inc/_buf_to_file.h  \
	../gen_inc/_f_mmap.h \
	../gen_inc/_f_munmap.h \
	../gen_inc/_mmap.h \
	../gen_inc/_munmap.h \
	../gen_inc/_write_bits_to_file.h \
        ../gen_inc/_get_bit.h \
        ../gen_inc/_get_bit_u64.h \
        ../gen_inc/_set_bit.h \
        ../gen_inc/_set_bit_u64.h \
        ../gen_inc/_copy_file.h \
        ../gen_inc/_generate_bin.h \
	../gen_inc/_is_valid_chars_for_num.h  \
	../gen_inc/_bytes_to_bits.h   \
        ../gen_inc/_cuda_malloc.h \
        ../gen_inc/_cuda_free.h \
	../gen_inc/_bits_to_bytes.h   \

#--------
SRC_FILES=  \
	mix_UI4.c \
	mix_UI8.c \
	rand_file_name.c \
	file_exists.c \
        isfile.c \
        isdir.c \
	trim.c \
	c_copy.c \
	c_free.c \
	get_file_size.c \
	buf_to_file.c \
	f_mmap.c  \
	f_munmap.c \
	mmap.c \
	munmap.c \
	bytes_to_bits.c \
	bits_to_bytes.c \
	write_bits_to_file.c  \
        get_bit.c  \
        get_bit_u64.c  \
        set_bit.c  \
        set_bit_u64.c  \
        copy_file.c  \
        generate_bin.c  \
        cuda_malloc.cu  \
        cuda_free.cu  \
	is_valid_chars_for_num.c \

# CUDA: using nvcc compiler
libutils.so : ${bin_search_files} ${hdr_files}
	nvcc ${QC_FLAGS} ${Q_LINK_FLAGS} ${INCS} ${SRC_FILES} ../gen_src/*.c -o libutils.so
	mkdir -p ${Q_BUILD_DIR}/include/
	mkdir -p ${Q_BUILD_DIR}/src/
	cp ${INCDIR}/*.h         ${Q_BUILD_DIR}/include/
	echo "Done copying ${INCDIR} files"
	cp ${SRC_FILES}      ${Q_BUILD_DIR}/src/
	echo "Done copying src files"
	cp ../inc/*          ${Q_BUILD_DIR}/include/
	echo "Done copying ../inc/*  files"

clean :
	rm -f ../gen_src/*
	rm -f ../gen_inc/*
	rm -f _*
	rm -f *.so
	rm -f *.o

asc2bin : 
	echo TODO
	

bin2asc :
	echo TODO

