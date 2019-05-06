#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <malloc.h>
#include "macros.h"
#include "_approx_frequent_I4.h"

static int run_test(int32_t *x, uint64_t x_len, int32_t *freq_ids, uint64_t *freq_counts, uint64_t freq_len, uint64_t min_freq, uint64_t err) {
  int status = 0;

  int32_t *y = NULL;
  uint64_t *f = NULL;
  uint64_t out_len;
  status = approx_frequent_I4(x, x_len, min_freq, err, &y, &f, &out_len); cBYE(status);

  uint64_t j = 0, i = 0;
  while (i < freq_len && j < out_len) {
    if (freq_ids[i] == y[j]) {
      if (f[j] < min_freq - err || (uint64_t)abs(f[j] - freq_counts[i]) > err) {
        for (int ii = 0; ii < 10; ii++) {
          fprintf(stderr, "expected: (%d, %ld), output: (%d, %ld)\n", freq_ids[ii], freq_counts[ii], y[ii], f[ii]);
        }
        fprintf(stderr, "expected: (%d, %ld), output: (%d, %ld)\n", freq_ids[i], freq_counts[i], y[j], f[j]);
        go_BYE(2);
      } else {
        i++;
        j++;
      }
    } else if (freq_ids[i] < y[j]) {
      if (freq_counts[i] >= min_freq) {
        go_BYE(2);
      }
      i++;
    } else {
      go_BYE(2);
    }
  }
  if (j < out_len) {
    go_BYE(2);
  }
  for (; i < freq_len; i++) {
    if (freq_counts[i] >= min_freq) {
      go_BYE(2);
    }
  }

 BYE:
  free_if_non_null(y);
  free_if_non_null(f);
  return status;
}

static int test_very_freq() {
  int status = 0;

  uint64_t total_nums = 100000;
  uint64_t min_freq = 10000;
  uint64_t err = 10;
  uint64_t freq_len = total_nums - total_nums / 2 + 1;

  int32_t *freq_ids = NULL;
  uint64_t *freq_counts = NULL;
  int32_t *x = NULL;

  freq_ids = malloc(freq_len * sizeof(int32_t)); return_if_malloc_failed(freq_ids);
  freq_counts = malloc(freq_len * sizeof(uint64_t)); return_if_malloc_failed(freq_counts);
  x = malloc(total_nums * sizeof(int32_t)); return_if_malloc_failed(x);

  freq_ids[0] = 1;
  freq_counts[0] = total_nums / 2;
  for (uint64_t i = 1; i < freq_len; i++) {
    freq_ids[i] = i + 1;
    freq_counts[i] = 1;
  }

  for (uint64_t i = 0; i < total_nums; i+=2) {
    x[i] = freq_ids[0];
    x[i + 1] = freq_ids[i / 2 + 1];
  }

  status = run_test(x, total_nums, freq_ids, freq_counts, freq_len, min_freq, err);

 BYE:
  free_if_non_null(freq_ids);
  free_if_non_null(freq_counts);
  free_if_non_null(x);
  return status;
}

static int test_barely_freq() {
  int status = 0;

  uint64_t total_nums = 100000;
  uint64_t min_freq = 10000;
  uint64_t err = 10;
  uint64_t freq_len = total_nums - min_freq;

  int32_t *freq_ids = NULL;
  uint64_t *freq_counts = NULL;
  int32_t *x = NULL;

  freq_ids = malloc(freq_len * sizeof(int32_t)); return_if_malloc_failed(freq_ids);
  freq_counts = malloc(freq_len * sizeof(uint64_t)); return_if_malloc_failed(freq_counts);
  x = malloc(total_nums * sizeof(int32_t)); return_if_malloc_failed(x);

  freq_ids[0] = 1;
  freq_counts[0] = min_freq;
  for (uint64_t i = 1; i < freq_len; i++) {
    freq_ids[i] = i + 1;
    freq_counts[i] = 1;
  }

  uint64_t per = total_nums / min_freq;
  for (uint64_t i = 0; i < min_freq; i ++) {
    x[i * per] = freq_ids[0];
    for (uint64_t j = 1; j < per; j++) {
      x[i * per + j] = freq_ids[(per - 1) * i + (j - 1)];
    }
  }

  status = run_test(x, total_nums, freq_ids, freq_counts, freq_len, min_freq, err);

 BYE:
  free_if_non_null(freq_ids);
  free_if_non_null(freq_counts);
  free_if_non_null(x);
  return status;
}

static int test_many_freq() {
  int status = 0;

  uint64_t total_nums = 200000;
  uint64_t min_freq = 10000;
  uint64_t err = 10;
  uint64_t num_freq = 10;
  uint64_t freq_len = num_freq + (total_nums - min_freq * num_freq);

  int32_t *freq_ids = NULL;
  uint64_t *freq_counts = NULL;
  int32_t *x = NULL;

  freq_ids = malloc(freq_len * sizeof(int32_t)); return_if_malloc_failed(freq_ids);
  freq_counts = malloc(freq_len * sizeof(uint64_t)); return_if_malloc_failed(freq_counts);
  x = malloc(total_nums * sizeof(int32_t)); return_if_malloc_failed(x);

  for (uint64_t i = 0; i < num_freq; i++) {
    freq_ids[i] = i + 1;
    freq_counts[i] = min_freq;
  }
  for (uint64_t i = num_freq; i < freq_len; i++) {
    freq_ids[i] = i + 1;
    freq_counts[i] = 1;
  }

  uint64_t per = num_freq * 2;
  for (uint64_t i = 0; i < total_nums / per; i++) {
    for (uint64_t j = 0; j < num_freq; j++) {
      x[i * per + j * 2] = freq_ids[j];
      x[i * per + j * 2 + 1] = freq_ids[(i + 1) * num_freq + j];
    }
  }

  status = run_test(x, total_nums, freq_ids, freq_counts, freq_len, min_freq, err);

 BYE:
  free_if_non_null(freq_ids);
  free_if_non_null(freq_counts);
  free_if_non_null(x);
  return status;
}

static int test_no_freq() {
  int status = 0;

  uint64_t total_nums = 100000;
  uint64_t min_freq = 10000;
  uint64_t err = 10;
  uint64_t num_per = 10;
  uint64_t freq_len = total_nums / num_per;

  int32_t *freq_ids = NULL;
  uint64_t *freq_counts = NULL;
  int32_t *x = NULL;

  freq_ids = malloc(freq_len * sizeof(int32_t)); return_if_malloc_failed(freq_ids);
  freq_counts = malloc(freq_len * sizeof(uint64_t)); return_if_malloc_failed(freq_counts);
  x = malloc(total_nums * sizeof(int32_t)); return_if_malloc_failed(x);

  for (uint64_t i = 0; i < freq_len; i++) {
    freq_ids[i] = i + 1;
    freq_counts[i] = num_per;
  }

  for (uint64_t i = 0; i < freq_len; i ++) {
    for (uint64_t j = 0; j < num_per; j++) {
      x[j * freq_len + i] = freq_ids[i];
    }
  }

  status = run_test(x, total_nums, freq_ids, freq_counts, freq_len, min_freq, err);

 BYE:
  free_if_non_null(freq_ids);
  free_if_non_null(freq_counts);
  free_if_non_null(x);
  return status;
}

int main() {
  int num_tests = 4;

  int (*tests[num_tests])();
  const char *test_names[num_tests];
  tests[0] = test_very_freq; test_names[0] = "VERY_FREQ";
  tests[1] = test_barely_freq; test_names[1] = "BARELY_FREQ";
  tests[2] = test_many_freq; test_names[2] = "MANY_FREQ";
  tests[3] = test_no_freq; test_names[3] = "NO_FREQ";

  for (int i = 0; i < num_tests; i++) {
    int status = tests[i]();
    if (status != 0) {
      printf("ERROR on test %s\n", test_names[i]);
    } else {
      printf("great success on test %s!\n", test_names[i]);
    }
  }
}
