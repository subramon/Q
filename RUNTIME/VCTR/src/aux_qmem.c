#include "q_incs.h"
#include "vec_macros.h"
#include "vctr_struct.h"

#include "get_file_size.h"
#include "copy_file.h"
#include "isfile.h"
#include "isdir.h"
#include "rdtsc.h"
#include "rs_mmap.h"

#include "aux_qmem.h"
#include "aux_core_vec.h"

int
load_chunk_from_vec(
    qmem_struct_t *ptr_S, 
    VEC_REC_TYPE *v, 
    uint32_t chunk_num
    )
{
  int status = 0;
  char *file_name = NULL;
  char *X = NULL; size_t nX = 0;
  if ( chunk_num >= v->num_chunks ) { go_BYE(-1); }
  size_t chnk_sz = get_chunk_size_in_bytes(ptr_S, v);
  uint32_t chunk_dir_idx = v->chunks[chunk_num];
  CHUNK_REC_TYPE *chunk =  ptr_S->chunk_dir->chunks + chunk_dir_idx;

  status = mk_file_name(ptr_S, v->uqid, &file_name); cBYE(status);
  status = rs_mmap(file_name, &X, &nX, 0); cBYE(status);
  if ( X == NULL ) { go_BYE(-1); }
  size_t offset = chnk_sz * chunk_num;
  if ( offset + chnk_sz > nX ) { 
    printf("hello world \n"); 
    go_BYE(-1); }
  if ( chunk->data == NULL ) { 
    chunk->data = malloc(chnk_sz);
    return_if_malloc_failed(chunk->data);
  }
  memcpy(chunk->data, X + offset, chnk_sz);
BYE:
  free_if_non_null(file_name);
  if ( X != NULL ) { munmap(X, nX); }
  return status;
}

int 
register_with_qmem(
    qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec,
    uint64_t vec_uqid
    )
{
  int status = 0;
  if ( vec_uqid == 0 ) { 
    ptr_vec->uqid = get_uqid(ptr_S);
  }
  else {
    // make sure that the vec_uqid is not in use 
    whole_vec_dir_t *w = ptr_S->whole_vec_dir;
    for ( uint32_t i = 0; i < w->sz; i++ ) { 
      if ( w->whole_vecs[i].uqid == vec_uqid ) {
        go_BYE(-1);
      }
    }
    //-----------------
    ptr_vec->uqid = vec_uqid;
  }
  status = assign_vec_idx(ptr_S, ptr_vec); cBYE(status);
BYE:
  return status; 
}

uint64_t
get_uqid(
    qmem_struct_t *ptr_S
    )
{
  return ++ptr_S->uqid_gen;
}

int
chk_chunk(
    qmem_struct_t *ptr_S,
    const VEC_REC_TYPE *const v,
    uint32_t chunk_dir_idx
    )
{
  int status = 0;
  char *file_name = NULL;

  WHOLE_VEC_REC_TYPE *w = 
    ptr_S->whole_vec_dir->whole_vecs + v->whole_vec_dir_idx;
  if ( w->uqid != v->uqid ) { go_BYE(-1); } 
  if ( chunk_dir_idx >= ptr_S->chunk_dir->sz ) { go_BYE(-1); }
  CHUNK_REC_TYPE *chunk = ptr_S->chunk_dir->chunks + chunk_dir_idx;
  /* What checks on these guys?
     if ( ptr_vec->num_readers > 0 ) { go_BYE(-1); }
     */
  if ( chunk->uqid == 0 ) { // we expect this to be free 
    if ( chunk->chunk_num != 0 ) { go_BYE(-1); }
    if ( chunk->uqid != 0 ) { go_BYE(-1); }
    if ( chunk->vec_uqid != 0 ) { go_BYE(-1); }
    if ( chunk->is_file ) { go_BYE(-1); }
    if ( isfile(file_name) ) { go_BYE(-1); }
    if ( chunk->data != NULL ) { go_BYE(-1); }
  }
  else {
    if ( chunk->vec_uqid != v->uqid ) { 
      printf("hello\n");
      go_BYE(-1); }
    if ( !w->is_file ) { 
      // this check is valid only when there is no master file 
      if ( ( chunk->data == NULL ) && ( !chunk->is_file ) ) { go_BYE(-1); }
    }
    if ( chunk->is_file ) { 
      status = mk_file_name(ptr_S, chunk->uqid, &file_name); cBYE(status);
      if ( !isfile(file_name) ) { go_BYE(-1); }
      free_if_non_null(file_name); 
    }
  }
BYE:
  free_if_non_null(file_name);
  return status;
}

int
assign_vec_idx(
    qmem_struct_t *ptr_S,
    VEC_REC_TYPE *v
    )
{
  int status = 0;
  whole_vec_dir_t *w = ptr_S->whole_vec_dir;
  unsigned int start_search = w->start_search;
  if ( start_search == 0 ) { start_search = 1; } // do not allocate 0
  if ( w->n  >= (w->sz-1) ) { go_BYE(-1); } // TODO P2 Need to re-allocate
  // NOTE: we do not allocate 0th entry
  for ( int iter = 0; iter < 2; iter++ ) { 
    unsigned int lb, ub;
    if ( iter == 0 ) { 
      lb = start_search; // note not 0
      ub = ptr_S->chunk_dir->sz;
    }
    else {
      lb = 1; 
      ub = start_search; // note not 0
    }
    for ( unsigned int i = lb ; i < ub; i++ ) { 
      if ( w->whole_vecs[i].uqid == 0 ) {
        w->whole_vecs[i].uqid = v->uqid;
        v->whole_vec_dir_idx = i; 
        w->n++;
        w->start_search = i+1;
        if ( w->start_search >= w->sz ) { w->start_search = 1; }
        return status;
      }
    }
  }
  /* control should not come here */
  go_BYE(-1); 
BYE:
  return status;
}

int
allocate_chunk(
    qmem_struct_t *ptr_S,
    VEC_REC_TYPE *v,
    uint32_t chunk_num,
    uint32_t *ptr_chunk_dir_idx,
    bool is_malloc,
    uint64_t chunk_uqid 
    )
{
  int status = 0;
  size_t sz = ptr_S->chunk_size * v->field_width;
  uint32_t start_search = ptr_S->chunk_dir->start_search;
  if ( start_search == 0 ) { start_search = 1; } // do not allocate 0
  // TODO P2 Need to re-allocate below
  if ( ptr_S->chunk_dir->n  >= (ptr_S->chunk_dir->sz-1) ) { go_BYE(-1); } 
  // NOTE: we do not allocate 0th entry
  for ( int iter = 0; iter < 2; iter++ ) { 
    unsigned int lb, ub;
    if ( iter == 0 ) { 
      lb = start_search; // note not 0
      ub = ptr_S->chunk_dir->sz;
    }
    else {
      lb = 1; 
      ub = start_search; // note not 0
    }
    for ( unsigned int i = lb ; i < ub; i++ ) {
      if ( ptr_S->chunk_dir->chunks[i].uqid == 0 ) {
        if ( chunk_uqid == 0 ) { 
          ptr_S->chunk_dir->chunks[i].uqid = get_uqid((qmem_struct_t *)ptr_S);
          ptr_S->chunk_dir->chunks[i].is_file = false;
        }
        else {
          for ( uint32_t j = 0; j < ptr_S->chunk_dir->sz; j++ ) { 
            if ( ptr_S->chunk_dir->chunks[j].uqid == chunk_uqid ) {
              go_BYE(-1);
            }
          }
          ptr_S->chunk_dir->chunks[i].uqid = chunk_uqid;
          char *file_name = NULL;
          status = mk_file_name(ptr_S, chunk_uqid, &file_name);cBYE(status);
          if ( !isfile(file_name) ) { go_BYE(-1); }
          ptr_S->chunk_dir->chunks[i].is_file = true;
          free_if_non_null(file_name);
        }
        ptr_S->chunk_dir->chunks[i].chunk_num = chunk_num;
        ptr_S->chunk_dir->chunks[i].vec_uqid = v->uqid;
        if ( is_malloc ) { 
          ptr_S->chunk_dir->chunks[i].data = l_malloc(sz);
          return_if_malloc_failed(ptr_S->chunk_dir->chunks[i].data);
        }
        *ptr_chunk_dir_idx = i; 
        ptr_S->chunk_dir->n++;
        start_search = i+1;
        if ( start_search >= ptr_S->chunk_dir->sz ) { start_search = 1; }
        return status;
      }
    }
  }
  /* control should not come here */
  go_BYE(-1); 
BYE:
  return status;
}

int64_t 
get_exp_file_size(
    qmem_struct_t *ptr_S,
    uint64_t num_elements,
    uint32_t field_width,
    const char * const fldtype
    )
{
  // NOTE: Currently we write entire chunk even if partially used
  num_elements = ceil((double)num_elements / ptr_S->chunk_size) * ptr_S->chunk_size;
  int64_t expected_file_size = num_elements * field_width;
  if ( strcmp(fldtype, "B1") == 0 ) {
    uint64_t num_words = num_elements / 64;
    if ( ( num_words * 64 ) != num_elements ) { num_words++; }
    expected_file_size = num_words * 8;
  }
  return expected_file_size;
}

size_t
get_chunk_size_in_bytes(
    qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_v
    )
{
  size_t chunk_size_in_bytes = ptr_S->chunk_size * ptr_v->field_width;
  if ( ptr_S->chunk_size == 0 ) { WHEREAMI; return -1; }
  if ( strcmp(ptr_v->fldtype, "B1") == 0 ) {  // SPECIAL CASE
    chunk_size_in_bytes = ptr_S->chunk_size / 8;
    if ( ( ( ptr_S->chunk_size / 64 ) * 64 ) != ptr_S->chunk_size ) { 
      WHEREAMI; return -1; 
    }
  }
  return chunk_size_in_bytes;
}

int
as_hex(
    uint64_t n,
    char *buf,
    size_t buflen
    )
{
  int status = 0;
  if ( buflen < 16+1 ) { go_BYE(-1); }
  for ( int i = 0; i < 16; i++ ) { 
    char c;
    switch ( n & 0xF )  {
      case 0 : c = '0'; break;
      case 1 : c = '1'; break;
      case 2 : c = '2'; break;
      case 3 : c = '3'; break;
      case 4 : c = '4'; break;
      case 5 : c = '5'; break;
      case 6 : c = '6'; break;
      case 7 : c = '7'; break;
      case 8 : c = '8'; break;
      case 9 : c = '9'; break;
      case 10 : c = 'A'; break;
      case 11 : c = 'B'; break;
      case 12 : c = 'C'; break;
      case 13 : c = 'D'; break;
      case 14 : c = 'E'; break;
      case 15 : c = 'F'; break;
      default : go_BYE(-1); break; 
    }
    buf[16-1-i] = c;
    n = n >> 4;
  }
BYE:
  return status;
}

int
mk_file_name(
    qmem_struct_t *ptr_S,
    uint64_t uqid, 
    char **ptr_file_name // [sz]
    )
{
  int status = 0;
  char *file_name = NULL;
  char buf[NUM_HEX_DIGITS_IN_UINT64+1];
  memset(buf, '\0', NUM_HEX_DIGITS_IN_UINT64+1);
  status = as_hex(uqid, buf, NUM_HEX_DIGITS_IN_UINT64); cBYE(status);
  char *data_dir = ptr_S->q_data_dir; 
  if ( data_dir == NULL ) { go_BYE(-1); }
  if ( !isdir(data_dir) ) { go_BYE(-1); }
  int len = strlen(data_dir) + 64; 
  file_name = malloc(len * sizeof(char));
  return_if_malloc_failed(file_name);
  snprintf(file_name, len-1, "%s/_%s.bin", data_dir, buf);
  *ptr_file_name = file_name;
BYE:
  return status;
}

int 
get_chunk_dir_idx(
    qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec,
    uint32_t chunk_num,
    uint32_t *ptr_num_chunks,
    uint32_t *ptr_chunk_dir_idx,
    bool is_malloc
    )
{
  int status = 0;
  if ( chunk_num >= ptr_vec->sz_chunks )  { go_BYE(-1); }
  uint32_t chunk_dir_idx = ptr_vec->chunks[chunk_num];
  if ( chunk_dir_idx == 0 ) { // we need to set it 
    status = allocate_chunk((qmem_struct_t *)ptr_S, ptr_vec, chunk_num, 
        &chunk_dir_idx, is_malloc, 0); 
    cBYE(status);
    *ptr_num_chunks = *ptr_num_chunks + 1;
  }
  *ptr_chunk_dir_idx = chunk_dir_idx;
  if ( chunk_dir_idx >= ptr_S->chunk_dir->sz ) { go_BYE(-1); }
  ptr_vec->chunks[chunk_num] = chunk_dir_idx;
BYE:
  return status;
}

int
qmem_backup_chunk(
    qmem_struct_t *ptr_S,
    const VEC_REC_TYPE *const v,
    int chunk_num
    )
{
  int status = 0;
  char *file_name = NULL;
  if ( v == NULL ) { go_BYE(-1); }
  if ( v->is_eov == false ) { go_BYE(-1); }

  WHOLE_VEC_REC_TYPE *w = 
    ptr_S->whole_vec_dir->whole_vecs + v->whole_vec_dir_idx;
  if ( w->uqid != v->uqid ) { go_BYE(-1); } 

  uint32_t chunk_dir_idx = v->chunks[chunk_num];
  chk_chunk_dir_idx(chunk_dir_idx);
  CHUNK_REC_TYPE *chunk = ptr_S->chunk_dir->chunks + chunk_dir_idx;
  //  if file exists, nothing to do 
  if ( chunk->is_file ) { return status; } 

  status = mk_file_name(ptr_S, chunk->uqid, &file_name); cBYE(status);
  size_t chnk_sz = get_chunk_size_in_bytes(ptr_S, v);
  if ( chunk->data == NULL ) { 
    if ( w->is_file ) { go_BYE(-1); }
    // load from vec file 
    fprintf(stderr, "TO BE IMPLEMENTED\n"); // TODO P2 
    go_BYE(-1); 
  }
  else {
    FILE *fp = fopen(file_name, "wb");
    return_if_fopen_failed(fp, file_name, "wb");
    fwrite(chunk->data, chnk_sz, 1, fp);
    fclose(fp);
  }
  chunk->is_file = true;
BYE:
  free_if_non_null(file_name);
  return status;
}

int
qmem_backup_chunks(
    qmem_struct_t *ptr_S,
    const VEC_REC_TYPE *const ptr_vec
    )
{
  int status = 0;
  if ( ptr_vec == NULL ) { go_BYE(-1); }
  if ( ptr_vec->is_eov == false ) { go_BYE(-1); }

  for ( uint32_t i = 0; i  < ptr_vec->num_chunks; i++ ) { 
    status = qmem_backup_chunk(ptr_S, ptr_vec, i);
    cBYE(status);
  }
BYE:
  return status;
}

int
qmem_un_backup_vec(
    qmem_struct_t *ptr_S,
    VEC_REC_TYPE *v,
    bool is_hard
    )
{
  int status = 0;
  char *file_name = NULL;
  WHOLE_VEC_REC_TYPE *w = 
    ptr_S->whole_vec_dir->whole_vecs + v->whole_vec_dir_idx;
  if ( w->uqid != v->uqid ) { go_BYE(-1); } 
  // If in use, then don't proceed
  if ( w->num_readers != 0 ) { go_BYE(-1); }
  if ( w->num_writers != 0 ) { go_BYE(-1); }
  if ( w->mmap_addr   != NULL ) { go_BYE(-1); }
  if ( w->mmap_len    != 0 ) { go_BYE(-1); }

  // No master file => nothing to do 
  if  ( !w->is_file ) { return status; } 

  if ( !is_hard ) {
    // Before deleting master file, must make sure chunks contain data
    for ( uint32_t i = 0; i < v->num_chunks; i++ ) { 
      uint32_t chunk_idx = v->chunks[i];
      CHUNK_REC_TYPE *chunk = ptr_S->chunk_dir->chunks + chunk_idx;
      if ( ( chunk->is_file ) || ( chunk->data != NULL ) ) {
        /* all is well */
      }
      else {
        load_chunk_from_vec(ptr_S, v, i); cBYE(status);
      }
    }
  }
  // When control come here, either 
  // (1) is_hard == true or
  // (2) chunks have data so no loss by deleting vector's file 
  status = mk_file_name(ptr_S, v->uqid, &file_name); cBYE(status);
  status = remove(file_name); cBYE(status);
  w->is_file = false;
  w->file_size = 0;
BYE:
  free_if_non_null(file_name);
  return status;
}

int
qmem_un_backup_chunk(
    qmem_struct_t *ptr_S,
    const VEC_REC_TYPE *const v,
    uint32_t chunk_num,
    bool is_hard
    )
{
  int status = 0;
  char *file_name = NULL;
  WHOLE_VEC_REC_TYPE *w = 
    ptr_S->whole_vec_dir->whole_vecs + v->whole_vec_dir_idx;
  if ( w->uqid != v->uqid ) { go_BYE(-1); } 
  if ( chunk_num >= v->num_chunks ) { go_BYE(-1); }

  uint32_t chunk_idx = v->chunks[chunk_num];
  CHUNK_REC_TYPE *chunk = ptr_S->chunk_dir->chunks + chunk_idx;
  if ( !chunk->is_file ) { return status; }
  // At this point, we know that chunk file does not exist 
  // can delete either if data in memory or master file exists
  if ( (is_hard) || ( w->is_file ) || ( chunk->data != NULL ) ) {
    status = mk_file_name(ptr_S, chunk->uqid, &file_name); cBYE(status);
    status = remove(file_name); cBYE(status);
    free_if_non_null(file_name);
    chunk->is_file = false;
  }
BYE:
  free_if_non_null(file_name);
  return status;
}

int
qmem_un_backup_chunks(
    qmem_struct_t *ptr_S,
    VEC_REC_TYPE *v,
    bool is_hard
    )
{
  int status = 0;

  for ( uint32_t i = 0; i < v->num_chunks; i++ ) { 
    status = qmem_un_backup_chunk(ptr_S, v, i, is_hard); cBYE(status);
  }
BYE:
  return status;
}

int 
qmem_backup_vec(
    qmem_struct_t *ptr_S,
    VEC_REC_TYPE *v
    )
{
  int status = 0; 
  char * vfile_name = NULL;
  FILE *vfp = NULL; 
  size_t file_size = 0; // number of bytes in file 
  char *X = NULL; size_t nX = 0;
  if ( !v->is_eov ) { go_BYE(-1); }
  WHOLE_VEC_REC_TYPE *w = 
    ptr_S->whole_vec_dir->whole_vecs + v->whole_vec_dir_idx;
  if ( w->uqid != v->uqid ) { go_BYE(-1); } 
  // Nothing to do: file exists 
  status = mk_file_name(ptr_S, v->uqid, &vfile_name); cBYE(status);
  if ( w->is_file ) { return status; } 

  status = mk_file_name(ptr_S, v->uqid, &vfile_name); cBYE(status);
  vfp = fopen(vfile_name, "wb"); 
  return_if_fopen_failed(vfp, vfile_name, "wb"); 
  size_t chnk_sz = get_chunk_size_in_bytes(ptr_S, v);
  for ( unsigned int i = 0; i < v->num_chunks; i++ ) { 
    int nw;
    uint32_t chunk_dir_idx = v->chunks[i];
    chk_chunk_dir_idx(chunk_dir_idx);
    CHUNK_REC_TYPE *ptr_chunk = ptr_S->chunk_dir->chunks + chunk_dir_idx;
    if ( ptr_chunk->data ) { 
      nw = fwrite(ptr_chunk->data, chnk_sz, 1, vfp);
      if ( nw != 1 ) { go_BYE(-1); }
    }
    else {
      char *cfile_name = NULL;
      status = mk_file_name(ptr_S, ptr_chunk->uqid, &cfile_name);
      cBYE(status);
      status = rs_mmap(cfile_name, &X, &nX, 0); cBYE(status);
      if ( nX != chnk_sz ) { go_BYE(-1); }
      nw = fwrite(X, nX, 1, vfp);
      if ( nw != 1 ) { go_BYE(-1); }
      munmap(X, nX); X = NULL; nX = 0;
      free_if_non_null(cfile_name);
    }
    file_size += chnk_sz;
  }
  w->is_file = true;
  w->file_size = file_size;
BYE:
  free_if_non_null(vfile_name);
  fclose_if_non_null(vfp);
  return status;
}

int
qmem_load_chunk(
    qmem_struct_t *ptr_S,
    const VEC_REC_TYPE *const v,
    int chunk_num
    )
{
  int status = 0;
  char *file_name = NULL;
  char *X = NULL; size_t nX = 0;
  chk_whole_vec_dir_idx(v->whole_vec_dir_idx);
  WHOLE_VEC_REC_TYPE *w = 
    ptr_S->whole_vec_dir->whole_vecs + v->whole_vec_dir_idx;
  if ( w->uqid != v->uqid ) { 
    go_BYE(-1); 
  } 
  // cannot load when write is in progress
  if ( w->num_writers > 0 ) { go_BYE(-1); }

  size_t chnk_sz = get_chunk_size_in_bytes(ptr_S, v);
  uint32_t chunk_dir_idx = v->chunks[chunk_num];
  CHUNK_REC_TYPE *chunk =  ptr_S->chunk_dir->chunks + chunk_dir_idx;
  if ( chunk->data != NULL ) { return status; } // already loaded
  // double check that this vector is yours
  if ( chunk->vec_uqid != v->uqid ) { go_BYE(-1); }

  // must be able to backup data from chunk file or vector file 
  if ( ( !chunk->is_file ) && ( !w->is_file ) ) { go_BYE(-1); }

  chunk->data = malloc(chnk_sz);
  return_if_malloc_failed(chunk->data);
  if ( chunk->is_file ) { // chunk has a backup file 
    status = mk_file_name(ptr_S, chunk->uqid, &file_name); cBYE(status);
    status = rs_mmap(file_name, &X, &nX, 0); cBYE(status);
    if ( X == NULL ) { go_BYE(-1); }
    if ( nX != chnk_sz ) { go_BYE(-1); }
    memcpy(chunk->data, X, nX);
    free_if_non_null(file_name);
    munmap(X, nX);  X = NULL; nX = 0;
  }
  else { // vector has a backup file 
    load_chunk_from_vec(ptr_S, v, chunk_num); cBYE(status);
  }
BYE:
  if ( X != NULL ) { munmap(X, nX); }
  free_if_non_null(file_name);
  return status;
}

int
qmem_load_chunks(
    qmem_struct_t *ptr_S,
    const VEC_REC_TYPE *const ptr_vec
    )
{
  int status = 0;
  for ( uint32_t i = 0; i < ptr_vec->num_chunks; i++ ) {
    status = qmem_load_chunk(ptr_S, ptr_vec, i); cBYE(status);
  }
BYE:
  return status;
}

int
qmem_un_load_chunk(
    qmem_struct_t *ptr_S,
    const VEC_REC_TYPE *const v,
    int chunk_num,
    bool is_hard
    )
{
  int status = 0;
  WHOLE_VEC_REC_TYPE *w = 
    ptr_S->whole_vec_dir->whole_vecs + v->whole_vec_dir_idx;
  if ( w->uqid != v->uqid ) { go_BYE(-1); } 
  // cannot unload when write is in progress
  if ( w->num_writers > 0 ) { go_BYE(-1); }

  uint32_t chunk_dir_idx = v->chunks[chunk_num];
  CHUNK_REC_TYPE *chunk =  ptr_S->chunk_dir->chunks + chunk_dir_idx;
  if ( chunk->data == NULL ) { return status; } // already unloaded
  // double check that this vector is yours
  if ( chunk->vec_uqid != v->uqid ) { go_BYE(-1); }

  // If you are NOT doing hard unload
  // them, you must be able to backup data from chunk file or vector file 
  if ( is_hard ) { 
    free_if_non_null(chunk->data); 
  }
  else {
    if ( ( chunk->is_file ) || ( w->is_file ) ) { // unload if safe
      free_if_non_null(chunk->data); 
    }
  }
BYE:
  return status;
}

int
qmem_un_load_chunks(
    qmem_struct_t *ptr_S,
    const VEC_REC_TYPE *const ptr_vec,
    bool is_hard
    )
{
  int status = 0;
  for ( uint32_t i = 0; i < ptr_vec->num_chunks; i++ ) {
    status = qmem_un_load_chunk(ptr_S, ptr_vec, i, is_hard); cBYE(status);
  }
BYE:
  return status;
}


int
qmem_delete_vec(
    qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec,
    bool is_hard
    )
{
  int status = 0;
  WHOLE_VEC_REC_TYPE *w = 
    ptr_S->whole_vec_dir->whole_vecs + ptr_vec->whole_vec_dir_idx;
  if ( w->uqid != ptr_vec->uqid ) { go_BYE(-1); } 
  
  status = qmem_un_backup_vec(ptr_S, ptr_vec, is_hard); cBYE(status);
  status = qmem_un_backup_chunks(ptr_S, ptr_vec, is_hard); cBYE(status);
  // clean out space in data structures
  memset(w, 0, sizeof(WHOLE_VEC_REC_TYPE));
  for ( uint32_t i = 0; i < ptr_vec->num_chunks; i++ ) { 
    uint32_t chunk_dir_idx = ptr_vec->chunks[i];
    CHUNK_REC_TYPE *c = ptr_S->chunk_dir->chunks + chunk_dir_idx;
    memset(c, 0, sizeof(CHUNK_REC_TYPE));
    ptr_S->chunk_dir->n--; // one spot opened up
  }
  ptr_S->whole_vec_dir->n--; // one spot opened up
BYE:
  return status;
}

bool 
vec_in_use(
    qmem_struct_t *ptr_S,
    VEC_REC_TYPE *v
    )
{
  WHOLE_VEC_REC_TYPE *w = 
    ptr_S->whole_vec_dir->whole_vecs + v->whole_vec_dir_idx;
  if ( ( w->num_readers > 0 ) || ( w->num_writers > 0 ) ) {
    return true;
  }
  for ( uint32_t i = 0; i < v->num_chunks; i++ ) { 
    uint32_t chunk_idx = v->chunks[i];
    CHUNK_REC_TYPE *chunk = ptr_S->chunk_dir->chunks + chunk_idx;
    if ( chunk->num_readers > 0 ) { return true; }
  }
  return false;
}

bool
is_vec_file(
    qmem_struct_t *ptr_S,
    const VEC_REC_TYPE *const v
    )
{
  WHOLE_VEC_REC_TYPE *w = 
    ptr_S->whole_vec_dir->whole_vecs + v->whole_vec_dir_idx;
  return w->is_file;
}

bool
is_chunk_file(
    qmem_struct_t *ptr_S,
    const VEC_REC_TYPE *const v,
    uint32_t chunk_num
    )
{
  if ( chunk_num >= v->num_chunks ) { return false; } // actually error 
  uint32_t chunk_dir_idx = v->chunks[chunk_num];
  CHUNK_REC_TYPE *c = 
    ptr_S->chunk_dir->chunks + chunk_dir_idx;
  return c->is_file;
}
int
duplicate_vec_file(
    uint32_t in_idx, 
    uint32_t out_idx)
{
  int status = 0;
  char *in_file_name = NULL;
  char *out_file_name = NULL;
  WHOLE_VEC_REC_TYPE *in_w  = ptr_S->whole_vec_dir->whole_vecs + in_idx;
  WHOLE_VEC_REC_TYPE *out_w = ptr_S->whole_vec_dir->whole_vecs + out_idx;
  if ( in_w->uqid == out_w->uqid ) { go_BYE(-1); } 
  if ( out_w->is_file ) { go_BYE(-1); } 
  if ( in_w->is_file ) {  
    status = mk_file_name(ptr_S, in_w->uqid, &in_file_name); cBYE(status);
    status = mk_file_name(ptr_S, out_w->uqid, &out_file_name); cBYE(status);
    status = copy_file(in_file_name, out_file_name); cBYE(status);
  }
BYE:
  free_if_non_null(in_file_name);
  free_if_non_null(out_file_name);
  return status;
}
