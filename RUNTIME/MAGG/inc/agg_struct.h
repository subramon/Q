#ifndef __AGG_STRUCT_H
#define __AGG_STRUCT_H
typedef struct _met_rec_type {
  uint64_t num_probes;
  // Place other metrics here
} MET_REC_TYPE;

typedef struct _buf_rec_type {
  uint8_t *fnds; // boolean saying whether value found or not
  uint8_t *tids; // thread ID indicating who will process it 
  uint32_t *locs; // initial location to start search 
  uint32_t *hshs; // hash of key 
  val_t *mvals; // values to be maintained forthis key
} BUF_REC_TYPE;

typedef struct _agg_rec_type {
  hmap_t *ptr_hmap; 
  MET_REC_TYPE *ptr_metrics;
  BUF_REC_TYPE *ptr_bufs;
} AGG_REC_TYPE;
#endif
