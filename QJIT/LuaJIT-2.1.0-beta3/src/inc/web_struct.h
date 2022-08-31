#include "evhttp.h"
#ifndef __WEB_STRUCT_H 
#define __WEB_STRUCT_H 

#define MAX_LEN_FILE_NAME 63
typedef struct _img_info_t { 
  char file_name[MAX_LEN_FILE_NAME+1];
  char suffix[8]; // png, jpg, ...
  bool is_set; // default false
} img_info_t;

typedef struct _web_info_t { 
  struct event_base *base;
  int port;
} web_info_t;

#endif //  __WEB_STRUCT_H 
