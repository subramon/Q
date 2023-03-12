extern int
rconnect(
    const char * const server, 
    int portnum, 
    int snd_timeout_sec,
    int rcv_timeout_sec,
    int *ptr_sock
    );
