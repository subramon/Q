
#include <sys/stat.h>
#include <sys/mman.h>
#include <stdio.h>
#include <stdint.h>
#include <fcntl.h>
#include <unistd.h>
#include "q_macros.h"
extern int64_t 
get_file_size(
	const char * const file_name
	);
