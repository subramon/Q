#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <malloc.h>
#include "macros.h"
#include "_qsort_asc_I2.h"

struct frequent_persistent_data_I2 {
  int16_t *packet_space;
  int16_t *cntr_id;
  uint64_t *cntr_freq;
  uint64_t cntr_siz;
  uint64_t active_cntr_siz;
  int16_t *bf_id;
  uint64_t *bf_freq;
  uint64_t siz;
  uint64_t min_freq;
  uint64_t err;
  uint64_t max_chunk_size;
};

int
allocate_frequent_persistent_data_I2(
    uint64_t siz, // number of elements to be processed
    uint64_t min_freq,
    uint64_t err,
    uint64_t max_chunk_size, // larges number of elements to be processed at once
    struct frequent_persistent_data_I2 *data); // caller should allocate

extern int
frequent_process_chunk_I2(
    int16_t *chunk,
    uint64_t chunk_siz,
    struct frequent_persistent_data_I2 *data);

extern int
frequent_process_output_I2(
    struct frequent_persistent_data_I2 *data,
    int16_t **y,
    uint64_t **f,
    uint32_t *out_len);

extern void free_frequent_persistent_data_I2(struct frequent_persistent_data_I2 *data);

#define STATUS_HIGH_MEMORY 1
#define STATUS_GOOD 0
#define STATUS_ERROR -1
#define STATUS_INVALID_INPUT -2

extern int
approx_frequent_I2(
    int16_t *x,
    uint64_t siz,
    uint64_t min_freq,
    uint64_t err,
    int16_t **y,
    uint64_t **f,
    uint32_t *out_len
    );
