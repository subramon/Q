// Similar to test4b but stand alone 
// compile: g++ -std=c++17 -O3 perf_new.cpp
// usage: ./a.out <Num of insertions> <max_keys>
// eg: ./a.out 4194304 2048

#include <cassert>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <float.h>
#include <limits.h>
#include <string.h>

#include <unordered_map>
#include <iostream>

#include <sys/time.h>
#include <time.h>

#define free_if_non_null(x) { if ( (x) != NULL ) { free((x)); (x) = NULL; } }

static uint64_t get_time_usec( void)
{
  struct timeval Tps; 
  struct timezone Tpf;
  gettimeofday (&Tps, &Tpf);
  return ((uint64_t )Tps.tv_usec + 1000000* (uint64_t )Tps.tv_sec);
}
/*-------------------------------------------------------*/
typedef int   key_t;
typedef float in_val_t;

typedef struct _val_t { 
  int cnt = 0;
  float minval = std::numeric_limits<float>::max();
  float maxval = std::numeric_limits<float>::min();
  double sumval = 0;
} val_t;

int
main(
    int argc,
    char **argv
    )
{
  
  if ( argc != 3 ) { return -1; }
  int N = std::stoi(argv[1]); // number of insertions performed 
  int num_items = std::stoi(argv[2]);
 
  int status = 0;
 
  val_t *chk_agg = NULL;
  key_t   *keys = NULL; int key_len = sizeof(key_t);
  in_val_t *vals = NULL; int val_len = sizeof(in_val_t);

  keys = (key_t*)malloc(N * sizeof(key_t));
  vals = (in_val_t*)malloc(N * sizeof(in_val_t));

  srandom(get_time_usec());
  srand48(random());
  for ( int i = 0; i < N; i++ ) { 
    keys[i] = (int)(random() % num_items);
    vals[i] = drand48();
  }

  chk_agg = (val_t*)malloc(num_items * sizeof(val_t));
  memset(chk_agg, 0,  (num_items * sizeof(val_t)));
  for ( int i = 0; i < num_items;  i++ ) { 
    chk_agg[i].minval = std::numeric_limits<float>::max();
    chk_agg[i].maxval = std::numeric_limits<float>::min();
  }

  //-----------------------------
  //-- START: independent calculation of aggregation
  for ( int i = 0; i < N; i++ ) {
    int key = keys[i];
    float val = vals[i];
    if ( chk_agg[key].minval > val ) { chk_agg[key].minval = val; }
    if ( chk_agg[key].maxval < val ) { chk_agg[key].maxval = val; }
    chk_agg[key].sumval += val;
    chk_agg[key].cnt++;
  }
  //-- STOP : independent calculation of aggregation
  // TODO: HERE IS WHERE THE C++ code goes
  std::unordered_map<int, val_t> agg;
  agg.reserve(num_items); // Reserve space

  uint64_t t1 = get_time_usec();
  for ( int i = 0; i < N; i++ ) {
    auto key = keys[i];
    auto val = vals[i];

    if(agg.find(key) != agg.end()){
      agg[key].sumval += val;
      agg[key].cnt++;
      agg[key].minval = std::min(agg[key].minval,val);
      agg[key].maxval = std::max(agg[key].maxval,val);
    }
    else{
      val_t def = {1, val, val, val};
      agg.emplace(key, def);
    }
  }
  uint64_t t2 = get_time_usec();
  fprintf(stdout, "Time taken = %lf \n", (t2-t1)/1000000.0);

  //-- START: Check against independent calculation 
  for ( int i = 0; i < num_items; i++ ) {
    key_t key_i = keys[i];
    assert( ( key_i >= 0 ) && ( key_i < num_items ) );
    assert ( agg[key_i].cnt == chk_agg[key_i].cnt ); 
    assert ( agg[key_i].minval == chk_agg[key_i].minval );
    assert ( agg[key_i].maxval == chk_agg[key_i].maxval );
    assert ( agg[key_i].sumval == chk_agg[key_i].sumval );
    
  }

  free_if_non_null(chk_agg);
  free_if_non_null(keys);
  free_if_non_null(vals);
  return status;
}
