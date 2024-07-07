extern int
vctr_set_num_lives_kill(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    int num_lives_kill
    );
extern int 
vctr_get_num_lives_kill(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    bool *ptr_is_killable,
    int *ptr_num_lives_kill
    );
extern int
vctr_kill(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    bool *ptr_kill_success
    );
