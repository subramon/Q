#include "q_incs.h"
#include <jansson.h>
#include "mk_custom1.h"

const char *json_plural(size_t count) { return count == 1 ? "" : "s"; }

int
mk_custom1(
    char * X,
    uint32_t nX,
    uint32_t width,
    const char ** const keys, // [n_keys[...]]
    uint32_t n_keys,
    custom1_t *Y
    )
{
  int status = 0;
  json_t *root = NULL;
  json_error_t error;
  size_t size = 0;
  const char *key = NULL;
  json_t *value = NULL;

  for ( uint32_t i = 0; i < nX; i++ ) { 
    root = json_loads(X+(i*width), 0, &error);
    if ( root == NULL ) { go_BYE(-1); } 
    /* TEST 
    size = json_object_size(root);
    printf("JSON Object of %lld pair%s:\n", (long long)size, json_plural(size));
    json_object_foreach(root, key, value) {
      printf("JSON Key: \"%s\"\n", key);
    }
    */
    memset(Y+i, 0, sizeof(custom1_t)); // TODO FAKE 
    for ( uint32_t j = 0; j < n_keys; j++ ) { 
      printf("%u:%s\t", j, keys[j]);
      json_t *contrib = json_object_get(root, keys[j]);
      if ( contrib == NULL ) { printf("Missing key\n"); continue;  }
      float fval;
      if ( json_is_real(contrib ) ) { 
        double dval = json_real_value(contrib); 
        fval = (float)dval;
      }
      else if ( json_is_integer(contrib ) ) { 
        int  ival = json_integer_value(contrib); 
        fval = (float)ival;
      }
      else {
        go_BYE(-1); 
      }
      printf("%lf \n", fval);
    }
  }

BYE:
  if ( root != NULL ) { json_decref(root); }
  return status;
}
