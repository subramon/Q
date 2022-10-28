#ifndef __Q_CONFIH
#define __Q_CONFIH
typedef struct  _q_config_t {
  bool restore_session;
  //-----------------------
  bool is_webserver;
  bool is_out_of_band;
  bool is_mem_mgr;
  //-----------------------
  char *data_dir_root;
  char *meta_dir_root;

  uint64_t mem_allowed;
  uint64_t dsk_allowed;

  int web_port;
  int out_of_band_port;

  uint32_t vctr_hmap_min_size;
  uint32_t vctr_hmap_max_size;

  uint32_t chnk_hmap_min_size;
  uint32_t chnk_hmap_max_size;
} q_config_t;
#endif // __Q_CONFIH
