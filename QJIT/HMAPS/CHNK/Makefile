#!/bin/bash
all : libchnk_rs_hmap.so

libchnk_rs_hmap.so : ./src/chnk_rs_hmap_custom_chk.c \
	./src/chnk_rs_hmap_key_cmp.c \
	./src/chnk_rs_hmap_pr_key.c \
	./src/chnk_rs_hmap_pr_val.c
	lua ${RSHMAP_SRC_ROOT}/fixed_len_kv/utils/make_project.lua \
		"${RSHMAP_SRC_ROOT}" \
		"${RSUTILS_SRC_ROOT}" \
		"chnk" 

clean : 
	rm -f libchnk_rs_hmap.so
