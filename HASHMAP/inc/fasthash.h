#include <stdint.h>
#include <stdlib.h>
extern  uint64_t 
fasthash64(
    const void *buf, 
    size_t len, 
    uint64_t seed
    );
extern uint32_t 
fasthash32(
    const void *buf, 
    size_t len, 
    uint32_t seed
    );
