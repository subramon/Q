#!/bin/bash
all : libvctr_rs_hmap.so

libvctr_rs_hmap.so : ./src/vctr_rs_hmap_custom_chk.c \
	./src/vctr_rs_hmap_key_cmp.c \
	./src/vctr_rs_hmap_pr_key.c \
	./src/vctr_rs_hmap_pr_val.c
	lua ${RSHMAP_SRC_ROOT}/RSHMAP/fixed_len_kv/utils/make_project.lua \
		"${RSHMAP_SRC_ROOT}" \
			"${RSUTILS_SRC_ROOT}" \
			"vctr" 

clean : 
	rm -f libvctr_rs_hmap.so
	rm -f gen_src/*.c
	rm -f gen_src/*.o
	rm -f gen_inc/*.h
