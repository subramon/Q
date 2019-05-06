#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <malloc.h>
#include "macros.h"
#include "_qsort_asc_I1.h"

struct frequent_persistent_data_I1 {
  int8_t *packet_space;
  int8_t *cntr_id;
  uint64_t *cntr_freq;
  uint64_t cntr_siz;
  uint64_t active_cntr_siz;
  int8_t *bf_id;
  uint64_t *bf_freq;
  uint64_t siz;
  uint64_t min_freq;
  uint64_t err;
  uint64_t max_chunk_size;
};

int
allocate_frequent_persistent_data_I1(
    uint64_t siz, // number of elements to be processed
    uint64_t min_freq,
    uint64_t err,
    uint64_t max_chunk_size, // larges number of elements to be processed at once
    struct frequent_persistent_data_I1 *data); // caller should allocate

extern int
frequent_process_chunk_I1(
    int8_t *chunk,
    uint64_t chunk_siz,
    struct frequent_persistent_data_I1 *data);

extern int
frequent_process_output_I1(
    struct frequent_persistent_data_I1 *data,
    int8_t **y,
    uint64_t **f,
    uint32_t *out_len);

extern void free_frequent_persistent_data_I1(struct frequent_persistent_data_I1 *data);

#define STATUS_HIGH_MEMORY 1
#define STATUS_GOOD 0
#define STATUS_ERROR -1
#define STATUS_INVALID_INPUT -2

extern int
approx_frequent_I1(
    int8_t *x,
    uint64_t siz,
    uint64_t min_freq,
    uint64_t err,
    int8_t **y,
    uint64_t **f,
    uint32_t *out_len
    );
