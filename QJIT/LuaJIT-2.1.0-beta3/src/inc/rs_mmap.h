#include "q_incs.h"
#ifndef __RS_MMAP_H
#define __RS_MMAP_H
extern int
rs_mmap(
	const char *file_name,
	char **ptr_mmaped_file,
	size_t *ptr_file_size,
	bool is_write
	);
#endif
