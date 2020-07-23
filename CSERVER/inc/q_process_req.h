#include "q_types.h"
#include "q_server_struct.h"
extern int 
q_process_req(
    Q_REQ_TYPE req_type,
    const char * const api,
    char *const args,
    q_server_t *ptr_sinfo
    );
