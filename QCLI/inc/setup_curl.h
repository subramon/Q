extern int
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
);
