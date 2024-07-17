extern int
vctr_set_num_kill_ignore(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    int num_kill_ignore
    );
extern int 
vctr_get_num_kill_ignore(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    bool *ptr_is_killable,
    int *ptr_num_kill_ignore
    );
extern int
vctr_kill(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    bool *ptr_kill_success
    );
