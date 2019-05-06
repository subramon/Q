
#include <stdio.h>
#include <stdbool.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <string.h>
#include <fcntl.h>
#include "q_macros.h"
extern int
rs_mmap(
	const char *file_name,
	char **ptr_mmaped_file,
	size_t *ptr_file_size,
	bool is_write
	);
