#include "q_client.h"

int
request_server(
    CURL *ch,
    char * input,
    const char * url
    )
{
  int status = 0;
  CURLcode curl_res;
  if( ch ) {
    curl_easy_setopt(ch, CURLOPT_POSTFIELDS, input);
    curl_res = curl_easy_perform(ch);
    if(curl_res != CURLE_OK) {
      status = -1;
      fprintf(stderr, "curl_easy_perform() failed: %s\n",
              curl_easy_strerror(curl_res));
    }
  }
  else {
    status = -1;
  }
BYE:
  return status;
}


int main(
    int argc, 
    char* argv[]
    )
{
  char *input	= NULL;
  char *host	= NULL;
  char *port	= NULL;
  char *url	= NULL;
  int status	= 0;

  if ( argc != 3 ) {
    printf("Please provide the appropriate arguments\n");
    printf("Usage\n");
    printf("./q_client <ip/hostname> <port>\n");
    go_BYE(-1);
  }

  host = argv[1];
  port = argv[2];
  int u_len = strlen(host) + strlen(port) + 32;
  url = malloc(u_len);
  if ( url == NULL ) { go_BYE(-1); }
  int len = snprintf(url, u_len-1, "http://%s:%s/%s", host, port, "DoString");
  if ( len >= u_len-1 ) { go_BYE(-1); }
  // Prepare CURL utility object
  CURL *ch = NULL;
  curl_global_init(CURL_GLOBAL_ALL);
  ch = curl_easy_init();
  if ( !ch ) {
    printf("Failed to prepare CURL object\n");
    go_BYE(-1);
  }
  curl_easy_setopt(ch, CURLOPT_URL, url);

  while ( 1 )
  {
    input = readline("Enter text: ");
    add_history(input);
    // printf("%s", input);
    if ( strcmp(input, "os.exit()") == 0 ) {
      break;
    }
    status = request_server(ch, input, url);
    printf("\n");
  }
  curl_easy_cleanup(ch);
  curl_global_cleanup();
BYE:
  if ( url ) { free(url); }
  return status;
}
