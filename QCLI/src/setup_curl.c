#include "q_incs.h"
#include "setup_curl.h"

static size_t write_data(
    void *buffer, 
    size_t size, 
    size_t nmemb, 
    void *userp
    )
{
  // basically do nothing with response
  return size * nmemb;
}

static size_t 
WriteMemoryCallback(
    void *contents, 
    size_t size, 
    size_t nmemb, 
    void *userp
    )
{
  int realsize = size * nmemb;
  if ( realsize > g_sz_ss_response ) { 
    for ( ; g_sz_ss_response < realsize; ) { 
      g_sz_ss_response *= 2 ;
    }
    g_ss_response = realloc(g_ss_response, g_sz_ss_response);
  }
  memcpy(userp, contents, realsize);
  return realsize;
}

int
setup_curl(
    char *write_buffer, // where output is saved 
    const char ** const in_hdrs,
    int num_in_hdrs,
    const char * const server,
    int port,
    const char * const url,
    uint32_t timeout_ms,
    CURL **ptr_ch, // OUTPUT 
    struct curl_slist **ptr_curl_hdrs // OUTPUT 
)
{
  int status = 0;
  char *full_url = NULL;
  CURL *ch = NULL;
  struct curl_slist *curl_hdrs = NULL;
  CURLcode res;

  *ptr_ch = NULL;
  *ptr_curl_hdrs = NULL;
  //---------------------------------
  if ( server == NULL ) { go_BYE(-1); } 
  if ( url  == NULL ) { go_BYE(-1); } 
  if ( port  == 0 ) { go_BYE(-1); } 
  if ( timeout_ms <= 0 ) { timeout_ms = 1000; } // default 
  //---------------------------------


  ch = curl_easy_init();
  if ( ch == NULL ) { go_BYE(-1); }
  // TODO P3 Test the slist_append properly
  for ( int i = 0; i < num_in_hdrs; i++ ) { 
    curl_hdrs = curl_slist_append(curl_hdrs, in_hdrs[i]);
  }
  //----------------------------------------
  int len = strlen(server) + 32 + strlen(url); 
  full_url = malloc(len); return_if_malloc_failed(full_url);
  int nw = snprintf(full_url, len-1, "http://%s:%d/%s", server, port, url);
  if ( nw >= len-1 ) { go_BYE(-1); }

  // set curl options 
  res = curl_easy_setopt(ch, CURLOPT_URL, full_url);
  if ( res != CURLE_OK ) { go_BYE(-1);  }
  res = curl_easy_setopt(ch, CURLOPT_VERBOSE, 0);
  if ( res != CURLE_OK ) { go_BYE(-1);  }
  res = curl_easy_setopt(ch, CURLOPT_TIMEOUT_MS,     timeout_ms);
  if ( res != CURLE_OK ) { go_BYE(-1);  }
  res = curl_easy_setopt(ch, CURLOPT_DNS_CACHE_TIMEOUT,     100);
  if ( res != CURLE_OK ) { go_BYE(-1);  }
  res = curl_easy_setopt(ch, CURLOPT_POST, 1L);
  if ( res != CURLE_OK ) { go_BYE(-1);  }
  res = curl_easy_setopt(ch, CURLOPT_WRITEFUNCTION, WriteMemoryCallback);
  if ( res != CURLE_OK ) { go_BYE(-1);  }
  res = curl_easy_setopt(ch, CURLOPT_WRITEDATA, (void *)write_buffer);
  if ( res != CURLE_OK ) { go_BYE(-1);  }
  /* set our custom set of headers */ 
  if ( curl_hdrs != NULL ) {
    res = curl_easy_setopt(ch, CURLOPT_HTTPHEADER, curl_hdrs);
    if ( res != CURLE_OK ) { go_BYE(-1);  }
  }
  //-------
  *ptr_ch = ch;
  *ptr_curl_hdrs = curl_hdrs;
BYE:
  free_if_non_null(full_url);
  return status;
}
