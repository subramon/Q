
#ifndef __Q_HMAP_STRUCT_H
#define __Q_HMAP_STRUCT_H
typedef struct _q_hmap_t {
  bool is_locked; 

  void *hmap;
} q_hmap_t; 
#endif // __Q_HMAP_STRUCT_H
