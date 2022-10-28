externally callable routines are
hmap_instantiate
hmap_put
hmap_get
hmap_chk
hmap_destroy
hmap_row_bindmp
hmap_col_bindmp -- still to be written
hmap_freeze

instantiate and unfreeze are specical because they are called before
rs_hmap_t struct is created.
Others are called using  function pointers inside rs_hmap_t struct 
