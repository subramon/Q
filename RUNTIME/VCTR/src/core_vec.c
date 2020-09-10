#include "q_incs.h"
#include "vec_macros.h"
#include "core_vec.h"
#include "aux_qmem.h"
#include "aux_core_vec.h"
#include "cmem.h"

#include "copy_file.h"
#include "file_exists.h"
#include "get_file_size.h"
#include "isfile.h"
#include "isdir.h"
#include "rdtsc.h"
#include "rs_mmap.h"
#include "txt_to_I4.h"

#include "lauxlib.h"


typedef struct _vec_uqid_chunk_num_rec_type {
  uint64_t vec_uqid;
  uint32_t chunk_num;
} VEC_UQID_CHUNK_NUM_REC_TYPE;


static int
sortfn2(
    const void *p1, 
    const void *p2
    )
{
  const uint64_t *r1 = (const uint64_t *)p1;
  const uint64_t *r2 = (const uint64_t *)p2;
  if ( *r1 < *r2 ) { 
    return -1;
  }
  else  {
    return 1;
  }
}

static int
sortfn(
    const void *p1, 
    const void *p2
    )
{
  const VEC_UQID_CHUNK_NUM_REC_TYPE *r1 = (const VEC_UQID_CHUNK_NUM_REC_TYPE *)p1;
  const VEC_UQID_CHUNK_NUM_REC_TYPE *r2 = (const VEC_UQID_CHUNK_NUM_REC_TYPE *)p2;
  if ( r1->vec_uqid < r2->vec_uqid ) { 
    return -1;
  }
  else if ( r1->vec_uqid > r2->vec_uqid ) { 
    return 1;
  }
  else {
    if ( r1->chunk_num < r2->chunk_num ) { 
      return -1;
    }
    else {
      return 1;
    }
  }
}

int
vec_meta(
    qmem_struct_t *ptr_S, 
    VEC_REC_TYPE *ptr_vec,
    char **ptr_opbuf
    )
{
  int status = 0;
  *ptr_opbuf = NULL;
  char *file_name = NULL;
  char buf[4096]; // should be large enough 
  if ( ptr_vec == NULL ) {  go_BYE(-1); }
  status = mk_file_name(ptr_S, ptr_vec->uqid, &file_name); cBYE(status);

  char  *opbuf = NULL; size_t bufsz = 4096; // initial size 
  opbuf = malloc(bufsz); return_if_malloc_failed(opbuf);
  memset(opbuf, '\0', bufsz);

  strcpy(buf, "return { ");
  safe_strcat(&opbuf, &bufsz, buf); 
  //------------------------------------------------
  sprintf(buf, "fldtype   = \"%s\", ", ptr_vec->fldtype);
  safe_strcat(&opbuf, &bufsz, buf); 
  sprintf(buf, "field_width   = %d, ", ptr_vec->field_width);
  safe_strcat(&opbuf, &bufsz, buf);
  sprintf(buf, "uqid         = %" PRIu64 ", ", ptr_vec->uqid);
  safe_strcat(&opbuf, &bufsz, buf);

  //-------------------------------------
  sprintf(buf, "num_elements = %" PRIu64 ", ", ptr_vec->num_elements);
  safe_strcat(&opbuf, &bufsz, buf);
  sprintf(buf, "name         = \"%s\", ", ptr_vec->name);
  safe_strcat(&opbuf, &bufsz, buf);

  //-------------------------------------
  // TODO P2: All the stuff from qmem_struct about chunks
  // TODO P2: All the stuff from qmem_struct about whole_vecs

  //-------------------------------------
  sprintf(buf, "is_persist = %s, ", ptr_vec->is_persist ? "true" : "false");
  safe_strcat(&opbuf, &bufsz, buf);
  sprintf(buf, "is_memo = %s, ", ptr_vec->is_memo ? "true" : "false");
  safe_strcat(&opbuf, &bufsz, buf);
  sprintf(buf, "is_eov = %s, ", ptr_vec->is_eov ? "true" : "false");
  safe_strcat(&opbuf, &bufsz, buf);
  sprintf(buf, "is_killable = %s, ", ptr_vec->is_killable ? "true" : "false");
  safe_strcat(&opbuf, &bufsz, buf);
  //-------------------------------------
  sprintf(buf, "num_chunks = %" PRIu32 ", ", ptr_vec->num_chunks);
  safe_strcat(&opbuf, &bufsz, buf);
  sprintf(buf, "sz_chunks = %" PRIu32 ", ", ptr_vec->sz_chunks);
  safe_strcat(&opbuf, &bufsz, buf);

  //-------------------------------------
  strcpy(buf, "} ");
  safe_strcat(&opbuf, &bufsz, buf);
  *ptr_opbuf = opbuf;
BYE:
  return status;
}

int
vec_free(
    qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec
    )
{
  int status = 0;
  // printf("vec_free: Freeing vector\n");
  if ( ptr_vec == NULL ) {  go_BYE(-1); }
  if ( ptr_vec->is_dead ) {  
    // fprintf(stderr, "Freeing Vector that is already dead\n");
    return status; // TODO P4 Should this be an error?
  }
  // delete all resources for this vector (modulo what is_persist says)
  bool is_hard;
  if ( ptr_vec->is_persist ) { is_hard = false; } else { is_hard = true; }
  status = qmem_delete_vec(ptr_S, ptr_vec, is_hard);
  cBYE(status);
  free_if_non_null(ptr_vec->name); 
  free_if_non_null(ptr_vec->chunks); 
  memset(ptr_vec, '\0', sizeof(VEC_REC_TYPE));
  ptr_vec->is_dead = true;
  // Don't do this in C. Lua will do it: free(ptr_vec);
BYE:
  return status;
}
// vec_delete is *almost* identical as vec_free but hard delete of files
int
vec_delete(
    qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec
    )
{
  int status = 0;
  ptr_vec->is_persist = false; // IMPORTANT 
  status = vec_free(ptr_S, ptr_vec); cBYE(status);
BYE:
  return status;
}

int
vec_new(
    qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec,
    const char * const fldtype,
    uint32_t field_width,
    uint64_t vec_uqid,
    uint32_t num_chunks_to_allocate
    )
{
  int status = 0;
  if ( ptr_vec == NULL ) { go_BYE(-1); }
  status = chk_fldtype(fldtype, field_width); cBYE(status);

  memset(ptr_vec, '\0', sizeof(VEC_REC_TYPE));

  strncpy(ptr_vec->fldtype, fldtype, Q_MAX_LEN_QTYPE_NAME-1);
  ptr_vec->field_width = field_width;
  status = register_with_qmem(ptr_S, ptr_vec, vec_uqid); cBYE(status);

  //-----------------------------
  ptr_vec->num_chunks = 0;
  status = init_chunk_dir(ptr_vec, num_chunks_to_allocate); cBYE(status);
  //-----------------------------
  // TODO P2 ptr_vec->is_memo = ptr_S->is_memo; // default behavior 
BYE:
  return status;
}
//---------------------
//-------------------------------------------------
int
check_chunks(
    qmem_struct_t *ptr_S
    )
{
  int status = 0;
  CHUNK_REC_TYPE *chunks = ptr_S->chunk_dir->chunks;
  uint32_t sz  = ptr_S->chunk_dir->sz;
  uint32_t n   = ptr_S->chunk_dir->n;
  if ( n == 0 ) { return status;  }
  if ( n > sz ) { go_BYE(-1); }
  VEC_UQID_CHUNK_NUM_REC_TYPE *buf1 = NULL;
  uint64_t                    *buf2 = NULL;

  buf1 = malloc(n * sizeof(VEC_UQID_CHUNK_NUM_REC_TYPE));
  return_if_malloc_failed(buf1);

  buf2 = malloc(n * sizeof(uint64_t));
  return_if_malloc_failed(buf2);

  uint32_t alt_n = 0;
  for ( uint32_t i = 0; i < sz; i++ ) { 
    if ( chunks[i].uqid == 0 ) { continue;}
    if ( alt_n >= n ) { go_BYE(-1); }
    buf1[alt_n].vec_uqid = chunks[i].vec_uqid;
    buf1[alt_n].chunk_num = chunks[i].chunk_num;
    buf2[alt_n] = chunks[i].uqid;
    alt_n++;
    // other checks 
    if ( chunks[i].num_readers < 0 ) { go_BYE(-1); }
  }
  if ( alt_n != n ) { go_BYE(-1); }
  // check uniqueness of (vec_uqid, chunk_num);
  qsort(buf1, n, sizeof(VEC_UQID_CHUNK_NUM_REC_TYPE), sortfn);
  for ( uint32_t i = 1; i < n; i++ )   {
    if ( ( buf1[i].vec_uqid  == buf1[i-1].vec_uqid ) && 
         ( buf1[i].chunk_num == buf1[i-1].chunk_num ) ) {
      go_BYE(-1);
    }
  }
  // check uniqueness of (uqid);
  qsort(buf2, n, sizeof(uint64_t), sortfn2);
  for ( uint32_t i = 1; i < n; i++ )   {
    if ( buf2[i] == buf2[i-1] ) { go_BYE(-1); }
  }

BYE:
  free_if_non_null(buf1);
  free_if_non_null(buf2);
  return status;
}
//-------------------------------------------------
int
vec_check_qmem(
    qmem_struct_t *ptr_S
    )
{
  int status = 0;
  size_t sz; char *cptr;
  uint64_t *buf = NULL;

  if ( ptr_S->q_data_dir == NULL ) { go_BYE(-1); }
  if ( ptr_S->chunk_size == 0 ) { go_BYE(-1); }
  if ( ptr_S->max_mem_KB < ptr_S->now_mem_KB ) { go_BYE(-1); }

  if ( ptr_S->whole_vec_dir == NULL ) { go_BYE(-1); }
  if ( ptr_S->whole_vec_dir->whole_vecs == NULL ) { go_BYE(-1); }
  if ( ptr_S->whole_vec_dir->sz == 0 ) { go_BYE(-1); }
  if ( ptr_S->whole_vec_dir->n >= ptr_S->whole_vec_dir->sz ) {go_BYE(-1);} 
  // check that 0th position is unused
  WHOLE_VEC_REC_TYPE *w0 = ptr_S->whole_vec_dir->whole_vecs + 0;
  sz = sizeof(WHOLE_VEC_REC_TYPE);
  cptr = (char *)w0;
  for ( uint32_t i = 0; i < sz; i++ ) { 
    if ( *cptr++ != '\0' ) { go_BYE(-1); 
    }
  }

  if ( ptr_S->chunk_dir == NULL ) { go_BYE(-1); }
  if ( ptr_S->chunk_dir->chunks == NULL ) { go_BYE(-1); }
  if ( ptr_S->chunk_dir->sz == 0 ) { go_BYE(-1); }
  if ( ptr_S->chunk_dir->n >= ptr_S->chunk_dir->sz ) {go_BYE(-1);} 

  // check that 0th position is unused
  CHUNK_REC_TYPE *c0 = ptr_S->chunk_dir->chunks + 0;
  sz = sizeof(CHUNK_REC_TYPE);
  cptr = (char *)c0;
  for ( uint32_t i = 0; i < sz; i++ ) { 
    if ( *cptr++ != '\0' ) { go_BYE(-1); 
    }
  }

  uint32_t szW = ptr_S->whole_vec_dir->sz;
  uint32_t nW  = ptr_S->whole_vec_dir->n;
  for ( uint32_t i = 0; i < szW; i++ ) {
    WHOLE_VEC_REC_TYPE *w = ptr_S->whole_vec_dir->whole_vecs + i;
    if ( w->uqid == 0 ) { continue; }

    //------------------------------------------
    if ( w->is_file ) { 
      if ( w->file_size == 0 ) { go_BYE(-1); }
    }
    else {
      if ( w->file_size   != 0    ) { go_BYE(-1); }
      if ( w->mmap_addr   != NULL ) { go_BYE(-1); }
      if ( w->mmap_len    != 0    ) { go_BYE(-1); }
      if ( w->num_readers != 0    ) { go_BYE(-1); }
      if ( w->num_writers != 0    ) { go_BYE(-1); }
    }
    //-------------------------------------------
    if ( w->num_readers > 0 ) { 
      if ( w->num_writers != 0 ) { go_BYE(-1); }
    }
    if ( w->num_writers > 1 ) { go_BYE(-1); }
    if ( w->num_writers == 1 ) { 
      if ( w->num_readers != 0 ) { go_BYE(-1); }
    }
    //-------------------------------------------
    if ( w->mmap_addr != NULL ) { 
      if ( !w->is_file      ) { go_BYE(-1); }
      if ( w->mmap_len == 0 ) { go_BYE(-1); }
      if ( ( w->num_readers == 0 ) && ( w->num_writers == 0 ) )  {
        go_BYE(-1);
      }
    }
    else {
      if ( ( w->num_readers > 0 ) || ( w->num_writers > 0 ) )  {
        go_BYE(-1);
      }
    }
  }
  // check uniqueness of (vec_uqid);
  if ( nW > 0 ) { 
    free_if_non_null(buf);
    uint32_t idx = 0;
    buf = malloc(nW * sizeof(uint64_t));
    return_if_malloc_failed(buf);
    for ( uint32_t i = 0; i < szW; i++ ) {
      WHOLE_VEC_REC_TYPE *w = ptr_S->whole_vec_dir->whole_vecs + i;
      if ( w->uqid != 0 ) { 
        if ( idx >= nW ) { go_BYE(-1); } buf[idx++] = w->uqid; 
      }
    }
    qsort(buf, nW, sizeof(uint64_t), sortfn2);
    for ( uint32_t i = 1; i < nW; i++ )   {
      if ( buf[i] == buf[i-1] ) { go_BYE(-1); }
    }
  }
  // check uniqueness of (chunk_uqid);
  uint32_t szC = ptr_S->chunk_dir->sz;
  uint32_t nC  = ptr_S->chunk_dir->n;
  if ( nC > 0 ) {
    free_if_non_null(buf);
    uint32_t idx = 0;
    buf = malloc(nC * sizeof(uint64_t));
    return_if_malloc_failed(buf);
    for ( uint32_t i = 0; i < szC; i++ ) {
      CHUNK_REC_TYPE *c = ptr_S->chunk_dir->chunks + i;
      if ( c->uqid != 0 ) { 
        if ( idx >= nC ) { go_BYE(-1); } buf[idx++] = c->uqid; 
      }
    }
    qsort(buf, nC, sizeof(uint64_t), sortfn2);
    for ( uint32_t i = 1; i < nC; i++ )   {
      if ( buf[i] == buf[i-1] ) { go_BYE(-1); }
    }
  }

BYE:
  free_if_non_null(buf);
  return status;
}
int
vec_check(
    qmem_struct_t *ptr_S,
    VEC_REC_TYPE *v
    )
{
  int status = 0;

  if ( ptr_S->q_data_dir == NULL ) { go_BYE(-1); }
  if ( ptr_S->chunk_size == 0 ) { go_BYE(-1); }
  if ( ptr_S->max_mem_KB < ptr_S->now_mem_KB ) { go_BYE(-1); }
  if ( ptr_S->chunk_dir == NULL ) { go_BYE(-1); }

  if ( ptr_S->whole_vec_dir == NULL ) { go_BYE(-1); }
  if ( ptr_S->whole_vec_dir->whole_vecs == NULL ) { go_BYE(-1); }
  if ( ptr_S->whole_vec_dir->sz == 0 ) { go_BYE(-1); }
  if ( ptr_S->whole_vec_dir->n >= ptr_S->whole_vec_dir->sz ) {go_BYE(-1);} 

  if ( ptr_S->chunk_dir == NULL ) { go_BYE(-1); }
  if ( ptr_S->chunk_dir->chunks == NULL ) { go_BYE(-1); }
  if ( ptr_S->chunk_dir->sz == 0 ) { go_BYE(-1); }
  if ( ptr_S->chunk_dir->n >= ptr_S->chunk_dir->sz ) {go_BYE(-1);} 

  // TODO P3 Check uniqueness of uqid in whole_vecs and chunks
  WHOLE_VEC_REC_TYPE *w = 
    ptr_S->whole_vec_dir->whole_vecs + v->whole_vec_dir_idx;
  if ( w->uqid != v->uqid ) { go_BYE(-1); } 

  if ( v->num_elements == 0 ) {
    if ( v->num_chunks  != 0    ) { go_BYE(-1); }
    if ( v->is_dead             ) { go_BYE(-1); }
    for ( uint32_t i = 0; i < v->sz_chunks; i++ ) { 
      CHUNK_REC_TYPE *c = ptr_S->chunk_dir->chunks + v->chunks[i];
      char *cptr = (char *)c;
      size_t sz = sizeof(CHUNK_REC_TYPE);
      for ( uint32_t j = 0; j < sz; j++ ) {
        if ( *cptr++ != '\0' ) { go_BYE(-1); }
      }
    }

    if ( w->file_size   != 0    ) { go_BYE(-1); }
    if ( w->mmap_addr   != NULL ) { go_BYE(-1); }
    if ( w->mmap_len    != 0    ) { go_BYE(-1); }
    if ( w->num_readers != 0    ) { go_BYE(-1); }
    if ( w->num_writers != 0    ) { go_BYE(-1); }

    // TODO P2 THINK if ( v->is_eov              ) { go_BYE(-1); }
    if ( w->is_file             ) { go_BYE(-1); }
    return status;
  }
  //------------------------------------------
  if ( w->is_file ) { 
    if ( w->file_size == 0 ) { go_BYE(-1); }
  }
  else {
    if ( w->file_size   != 0    ) { go_BYE(-1); }
    if ( w->mmap_addr   != NULL ) { go_BYE(-1); }
    if ( w->mmap_len    != 0    ) { go_BYE(-1); }
    if ( w->num_readers != 0    ) { go_BYE(-1); }
    if ( w->num_writers != 0    ) { go_BYE(-1); }
  }
  //-------------------------------------------
  if ( w->num_readers > 0 ) { 
    if ( w->num_writers != 0 ) { go_BYE(-1); }
  }
  if ( w->num_writers > 1 ) { go_BYE(-1); }
  if ( w->num_writers == 1 ) { 
    if ( w->num_readers != 0 ) { go_BYE(-1); }
  }
  //-------------------------------------------
  if ( w->mmap_addr != NULL ) { 
    if ( !w->is_file      ) { go_BYE(-1); }
    if ( w->mmap_len == 0 ) { go_BYE(-1); }
    if ( ( w->num_readers == 0 ) && ( w->num_writers == 0 ) )  {
      go_BYE(-1);
    }
  }
  else {
    if ( ( w->num_readers > 0 ) || ( w->num_writers > 0 ) )  {
      go_BYE(-1);
    }
  }
  //-------------------------------------------
  if ( v->is_dead ) { 
    char *cptr = (char *)v;
    for ( uint32_t i = 0; i < sizeof(VEC_REC_TYPE); i++ ) { 
      if ( *cptr++ != '\0' ) { go_BYE(-1); }
    }
  }
  //-------------------------------------------
  // if ( v->num_chunks < 0 ) { go_BYE(-1); }
  // if ( v->sz_chunks < 0 ) { go_BYE(-1); }
  if ( v->num_chunks > v->sz_chunks ) { go_BYE(-1); }
  //-------------------------------------------
  if ( v->chunks != NULL ) { 
    if ( v->num_chunks == 0 ) { go_BYE(-1); }
    if ( v->sz_chunks  == 0 ) { go_BYE(-1); }
  }
  //-------------------------------------------
  if ( !v->is_memo ) { 
    if ( v->chunks != NULL ) { 
      if ( v->num_chunks != 1 ) { go_BYE(-1); }
      if ( v->sz_chunks  < v->num_chunks ) { go_BYE(-1); }
    }
  }
  else {
    // if ( v->num_chunks < 0 ) { go_BYE(-1); }
    // if ( v->sz_chunks < 0 ) { go_BYE(-1); }
  }
  //-------------------------------------------
  for ( uint32_t i = 0; i < v->num_chunks; i++ ) {
    chk_chunk_dir_idx(v->chunks[i]);
    status = chk_chunk(ptr_S, v, v->chunks[i]); cBYE(status);
    for ( uint32_t j = i+1; j  < v->num_chunks; j++ ) {
      if (  v->chunks[i] == v->chunks[j] ) { go_BYE(-1); }
    }
  }
  //-------------------------------------------
  if ( strcmp(v->fldtype, "B1") == 0 ) { 
    // TODO P1: How do we handle field_width for B1?
  }
  else {
    if  ( v->field_width == 0 ) { go_BYE(-1); }
    status = chk_fldtype(v->fldtype, v->field_width); cBYE(status);
  }
BYE:
  return status;
}

int
vec_memo(
    const VEC_REC_TYPE *const ptr_vec,
    bool *ptr_is_memo,
    bool is_memo
    )
{
  int status = 0;
  // No changes about is_memo can be made once creation starts
  if ( ptr_vec->is_eov == true ) { go_BYE(-1); }
  if ( ptr_vec->num_elements > 0 ) { go_BYE(-1); }
  //----------------------------------------
  if ( ( is_memo == false ) && ( ptr_vec->is_persist == true )) {
    // If Vector is to be persisted, and you don't memoize it, you take 
    // the chance of losing it. You will get lucky if the number of 
    // elements is less than the chunk size
    // However, note that this is NOT an error
  }
  *ptr_is_memo = is_memo;
BYE:
  return status;
}

int
vec_get1(
    qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec,
    uint64_t idx,
    void **ptr_data
    )
{
  int status = 0;
  uint32_t chunk_num, chunk_dir_idx, in_chunk_idx;
  if ( ptr_vec->is_dead ) { go_BYE(-1); }
  status = chunk_num_for_read(ptr_S, ptr_vec, idx, &chunk_num);
  cBYE(status);
  status = qmem_load_chunk(ptr_S, ptr_vec, chunk_num); cBYE(status);
  in_chunk_idx = idx % ptr_S->chunk_size; // identifies element within chunk
  chunk_dir_idx = ptr_vec->chunks[chunk_num];

  CHUNK_REC_TYPE *chunk = ptr_S->chunk_dir->chunks + chunk_dir_idx;
  if ( strcmp(ptr_vec->fldtype, "B1") == 0 ) { 
    uint32_t word_idx = in_chunk_idx / 64;
    *ptr_data =  chunk->data + word_idx;
  }
  else {
    *ptr_data =  chunk->data + (in_chunk_idx * ptr_vec->field_width);
  }

BYE:
  return status;
}
//--------------------------------------------------
int
vec_start_read(
    qmem_struct_t *ptr_S,
    VEC_REC_TYPE *v,
    CMEM_REC_TYPE *c
    )
{
  int status = 0;
  if ( !v->is_eov         ) { go_BYE(-1); }
  WHOLE_VEC_REC_TYPE *w = 
    ptr_S->whole_vec_dir->whole_vecs + v->whole_vec_dir_idx;
  if ( w->uqid != v->uqid ) { go_BYE(-1); } 
  if ( w->num_writers > 0 ) { go_BYE(-1); }

  w->num_readers++; 
  if ( w->mmap_addr == NULL ) { 
    status = qmem_backup_vec(ptr_S, v); cBYE(status);
    if ( !w->is_file ) { go_BYE(-1); }
    char *X = NULL; size_t nX = 0;
    char *file_name = NULL;
    status = mk_file_name(ptr_S, v->uqid, &file_name);
    status = rs_mmap(file_name, &X, &nX, 0); cBYE(status);
    w->mmap_addr = X;
    w->mmap_len  = nX;
    free_if_non_null(file_name);
  }
  c->data = w->mmap_addr;
  c->size = w->mmap_len;
  if ( v->name ) { 
    size_t len = strlen(v->name) + 1;
    char *name = malloc(len);
    strcpy(name, v->name);
    c->cell_name = name;
  }
  strncpy(c->fldtype, v->fldtype, Q_MAX_LEN_QTYPE_NAME-1);
  c->is_foreign = true;
BYE:
  return status;
}
//--------------------------------------------------
int
vec_end_read(
    qmem_struct_t *ptr_S,
    VEC_REC_TYPE *v
    )
{
  int status = 0;
  WHOLE_VEC_REC_TYPE *w = 
    ptr_S->whole_vec_dir->whole_vecs + v->whole_vec_dir_idx;
  if ( w->uqid != v->uqid ) { go_BYE(-1); } 
  if ( w->mmap_addr   == NULL ) { go_BYE(-1); }
  if ( w->mmap_len    == 0    )  { go_BYE(-1); }
  if ( w->num_readers == 0    ) { go_BYE(-1); }

  w->num_readers--;
  if ( w->num_readers == 0 ) { 
    munmap(w->mmap_addr, w->mmap_len);
    w->mmap_addr  = NULL;
    w->mmap_len   = 0;
  }
BYE:
  return status;
}
//--------------------------------------------------
int
vec_get_chunk(
    qmem_struct_t *ptr_S,
    VEC_REC_TYPE *v,
    uint32_t chunk_num,
    CMEM_REC_TYPE *ptr_cmem,
    uint32_t *ptr_num_in_chunk
    )
{
  int status = 0;
  if ( !v->is_memo ) { chunk_num = 0; } // Important
  if ( chunk_num >= v->num_chunks ) { go_BYE(-1); } 
  status = qmem_load_chunk(ptr_S, v, chunk_num); cBYE(status);
  uint32_t chunk_dir_idx = v->chunks[chunk_num];
  chk_chunk_dir_idx(chunk_dir_idx);
  CHUNK_REC_TYPE *chunk = ptr_S->chunk_dir->chunks + chunk_dir_idx;
  if ( chunk->num_readers  < 0 ) { go_BYE(-1); }
  chunk->num_readers++;

  ptr_cmem->data = chunk->data;
  ptr_cmem->size = ptr_S->chunk_size * v->field_width;
  strncpy(ptr_cmem->fldtype, v->fldtype, Q_MAX_LEN_QTYPE_NAME-1);
  ptr_cmem->is_foreign = true;

  // set chunk size
  if ( chunk_num < v->num_chunks - 1 ) {
    *ptr_num_in_chunk = ptr_S->chunk_size;
  }
  else {
    *ptr_num_in_chunk = v->num_elements % ptr_S->chunk_size;
    if ( *ptr_num_in_chunk == 0 ) { 
      *ptr_num_in_chunk = ptr_S->chunk_size;
    }
  }
BYE:
  return status;
}
//------------------------------------------------
int
vec_shutdown(
    qmem_struct_t *ptr_S,
    VEC_REC_TYPE *v,
    char **ptr_str
    )
{
  int status = 0;
  *ptr_str = NULL;
  WHOLE_VEC_REC_TYPE *w = 
    ptr_S->whole_vec_dir->whole_vecs + v->whole_vec_dir_idx;
  if ( w->uqid != v->uqid ) { go_BYE(-1); } 

  if ( ( !v->is_memo )  && 
      ( v->num_elements > ptr_S->chunk_size ) ) { 
    fprintf(stderr,"We have lost data and no hope of recovering it\n");
    status = vec_delete(ptr_S, v); cBYE(status);
    go_BYE(-1); 
  }
  // if not eov, then delete the vector
  // In other words, only eov vectors get to be saved
  if ( !v->is_eov )  {
    status = vec_delete(ptr_S, v); cBYE(status);
    return status;
  }
  // check if anybody is using it 
  if ( vec_in_use(ptr_S, v) ) { go_BYE(-1); }
  //------------------------------------------
  // When we shutdown a vector, we prepare for reincarnation ONLY 
  // if is_persist == true 
  if ( v->is_persist ) { 
    if ( w->is_file ) { 
      // master file exists, no need to flush chunks individually
    }
    else {
      status = qmem_backup_chunks(ptr_S, v); cBYE(status);
      status = qmem_un_load_chunks(ptr_S, v, false); cBYE(status);
    }
    status = code_for_reincarnate(ptr_S, v, ptr_str, false);
    cBYE(status);
  }
  status = vec_free(ptr_S, v); cBYE(status);
BYE:
  return status;
}
int
vec_unget_chunk(
    qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec,
    uint32_t chunk_num
    )
{
  int status = 0;
  if ( !ptr_vec->is_memo ) { chunk_num = 0; } // Important
  if ( chunk_num >= ptr_vec->num_chunks ) { go_BYE(-1); }
  uint32_t chunk_dir_idx = ptr_vec->chunks[chunk_num];
  CHUNK_REC_TYPE *chunk = ptr_S->chunk_dir->chunks + chunk_dir_idx;
  chk_chunk_dir_idx(chunk_dir_idx);
  if ( chunk->data     == NULL ) { go_BYE(-1); }
  if ( chunk->num_readers == 0 ) { go_BYE(-1); }
  chunk->num_readers--;
BYE:
  return status;
}
//--------------------------------------------------


int
vec_start_write(
    qmem_struct_t *ptr_S,
    VEC_REC_TYPE *v,
    CMEM_REC_TYPE *ptr_cmem
    )
{
  int status = 0;
  char *file_name = NULL;
  char *X = NULL; size_t nX = 0;
  WHOLE_VEC_REC_TYPE *w = 
    ptr_S->whole_vec_dir->whole_vecs + v->whole_vec_dir_idx;
  if ( w->uqid != v->uqid ) { go_BYE(-1); } 
  if ( v->is_dead ) { go_BYE(-1); }
  if ( !v->is_eov ) { go_BYE(-1); }
  if ( !v->is_memo ) { go_BYE(-1); }
  if ( w->num_writers != 0 ) { go_BYE(-1); }
  if ( w->num_readers != 0 ) { go_BYE(-1); }
  status = qmem_backup_vec(ptr_S, v); cBYE(status);
  // delete chunks since they no longer reflect reality
  bool is_hard = false;  
  // note that since vector file exists, chunks will be 
  // un-loaded and un-backedup
  status = qmem_un_load_chunks(ptr_S, v, is_hard); cBYE(status);
  status = qmem_un_backup_chunks(ptr_S, v, is_hard); cBYE(status);
  //------------------

  status = mk_file_name(ptr_S, v->uqid, &file_name); cBYE(status);
  rs_mmap(file_name, &X, &nX, 1); cBYE(status);
  if ( ( X == NULL ) || ( nX == 0 ) )  { go_BYE(-1); }
  // Set the CMEM that will be consumed by caller
  w->num_writers = 1;
  w->mmap_addr = ptr_cmem->data     = X;
  w->mmap_len  = ptr_cmem->size     = nX;
  ptr_cmem->is_foreign = true;
  strncpy(ptr_cmem->fldtype, v->fldtype, Q_MAX_LEN_QTYPE_NAME-1);
  if ( v->name ) { 
    size_t len = strlen(v->name) + 1;
    char *name = malloc(len);
    strcpy(name, v->name);
    ptr_cmem->cell_name = name;
  }

BYE:
  free_if_non_null(file_name);
  return status;
}

int
vec_end_write(
    qmem_struct_t *ptr_S,
    VEC_REC_TYPE *v
    )
{
  int status = 0;
  WHOLE_VEC_REC_TYPE *w = 
    ptr_S->whole_vec_dir->whole_vecs + v->whole_vec_dir_idx;
  if ( w->uqid != v->uqid ) { go_BYE(-1); } 
  if ( w->num_writers != 1 ) { go_BYE(-1); }
  if ( w->mmap_addr  == NULL ) { go_BYE(-1); }
  if ( w->mmap_len   == 0    )  { go_BYE(-1); }
  munmap(w->mmap_addr, w->mmap_len);
  w->mmap_addr  = NULL;
  w->mmap_len   = 0;
  w->num_writers = 0; 
BYE:
  return status;
}

int
vec_kill(
    qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec
    )
{
  int status = 0;
  if ( ptr_vec->is_dead ) { go_BYE(-1); }
  if ( !ptr_vec->is_killable ) { return status; } // ignore if necessary
  status = vec_delete(ptr_S, ptr_vec); cBYE(status);
BYE:
  return status;
}

int
vec_killable(
    VEC_REC_TYPE *ptr_vec,
    bool is_killable
    )
{
  int status = 0;
  if ( ptr_vec->is_dead ) { go_BYE(-1); }
  if ( ptr_vec->num_elements > 0 ) { go_BYE(-1); }
  ptr_vec->is_killable = is_killable;
BYE:
  return status;
}

int
vec_persist(
    VEC_REC_TYPE *ptr_vec,
    bool is_persist
    )
{
  int status = 0;
  if ( ptr_vec->is_dead ) { go_BYE(-1); }
  ptr_vec->is_persist = is_persist;
BYE:
  return status;
}

int
vec_set_name(
    VEC_REC_TYPE *ptr_vec,
    const char * const name
    )
{
  int status = 0;
  if ( ptr_vec == NULL ) { go_BYE(-1); }
  free_if_non_null(ptr_vec->name);
  if ( ( name != NULL ) && ( *name != '\0' ) ) {
    int len = strlen(name) + 1; 
    ptr_vec->name = malloc(len);
    memset(ptr_vec->name, '\0', len);
    status = chk_name(name); cBYE(status);
    strcpy(ptr_vec->name, name);
  }
BYE:
  return status;
}

char *
vec_get_name(
    VEC_REC_TYPE *ptr_vec
    )
{
  return ptr_vec->name;
}

int
vec_eov(
    VEC_REC_TYPE *ptr_vec
    )
{
  int status = 0;
  if ( ptr_vec->is_dead ) { go_BYE(-1); }
  if ( ptr_vec->is_eov ) { return status; }
  ptr_vec->is_eov = true;
BYE:
  return status;
}

int
vec_put_chunk(
    qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec,
    CMEM_REC_TYPE *ptr_cmem,
    uint32_t num_elements
    )
{
  int status = 0;
  if ( ptr_S->chunk_size == 0 ) { go_BYE(-1); }
  if ( ptr_vec  == NULL ) { go_BYE(-1); }
  if ( ptr_cmem == NULL ) { go_BYE(-1); }
  if ( ptr_vec->is_dead ) { go_BYE(-1); }
  if ( ptr_vec->is_eov ) { go_BYE(-1); }

  if ( num_elements == 0 ) { num_elements = ptr_S->chunk_size; }
  if ( num_elements > ptr_S->chunk_size ) { go_BYE(-1); }
  const char * const data = ptr_cmem->data;
  if ( data == NULL ) { go_BYE(-1); }

  bool is_malloc;
  if ( ptr_cmem->is_stealable ) {
    is_malloc = false;
  }
  else {
    is_malloc = true;
  }
  //-----------------------------------------
  // number of elements must be a multiple of ptr_S->chunk_size
  if ( !is_multiple(ptr_vec->num_elements, ptr_S->chunk_size) ) { 
    go_BYE(-1); 
  }
  uint32_t chunk_num, chunk_dir_idx;
  if ( !ptr_vec->is_memo ) {
    chunk_num = 0;
    if ( ptr_vec->num_chunks == 0 ) { // indicating no allocation done 
      status = allocate_chunk(ptr_S, ptr_vec, chunk_num, 
          &chunk_dir_idx, is_malloc, 0); 
      cBYE(status);
      if ( chunk_dir_idx >= ptr_S->chunk_dir->sz ) { go_BYE(-1); }
  chk_chunk_dir_idx(chunk_dir_idx);
      if ( !is_malloc ) {
        ptr_cmem->is_foreign   = true;
        ptr_S->chunk_dir->chunks[chunk_dir_idx].data = ptr_cmem->data;
      }
      ptr_vec->chunks[chunk_num] = chunk_dir_idx;
      ptr_vec->num_chunks = 1;
    }
    else {
      chunk_dir_idx = ptr_vec->chunks[chunk_num];
    }
    // if memo and stealable, then you have stolen CMEM by now
    // This means that the write done by the generator was into the
    // first chunk of this Vector and there is nothing more to do 
    if ( ptr_cmem->is_stealable ) { 
      ptr_vec->num_elements += num_elements;
      return 0;
    }
  }
  else {
    status = get_chunk_num_for_write(ptr_S, ptr_vec, &chunk_num); 
    cBYE(status);
    status = get_chunk_dir_idx(ptr_S, ptr_vec, chunk_num, 
        &(ptr_vec->num_chunks), &chunk_dir_idx, is_malloc); 
    cBYE(status);
    // if NOT memo and stealable, then you have stolen CMEM by now
    // This means that Vector took the CMEM from the generator
    // as the data for its chunk and there is nothing more to do 
    if ( !is_malloc ) { 
      ptr_cmem->is_foreign   = true;
      ptr_S->chunk_dir->chunks[chunk_dir_idx].data = ptr_cmem->data;
      ptr_cmem->data = NULL;
      ptr_cmem->size = 0;
      // following to tell cmem that it is okay for data to be NULL
      // when its free is invoked
      strcpy(ptr_cmem->fldtype, "XXX");
      free_if_non_null(ptr_cmem->cell_name);
      //-----
      ptr_vec->num_elements += num_elements;
      return 0;
    }
  }
  chk_chunk_dir_idx(chunk_dir_idx);
  CHUNK_REC_TYPE *chunk = ptr_S->chunk_dir->chunks + chunk_dir_idx;

  size_t sz = num_elements * ptr_vec->field_width;
  // handle special case for B1
  if ( strcmp(ptr_vec->fldtype, "B1") == 0 ) { 
    sz = ceil((double)num_elements / 8.0); 
  }
  l_memcpy(chunk->data, data, sz);

  ptr_vec->num_elements += num_elements;
  ptr_vec->chunks[chunk_num] = chunk_dir_idx;

BYE:
  return status;
}


int
vec_put1(
    qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec,
    const void * const data
    )
{
  int status = 0;
  // START: Do some basic checks
  if ( ptr_vec->is_dead ) { go_BYE(-1); }
  if ( ptr_S->chunk_size == 0 ) { go_BYE(-1); }
  if ( ptr_vec == NULL ) { go_BYE(-1); }
  if ( data == NULL ) { go_BYE(-1); }
  if ( ptr_vec->is_eov ) { go_BYE(-1); }
  //---------------------------------------
  uint32_t chunk_num, chunk_dir_idx;
  status = get_chunk_num_for_write(ptr_S, ptr_vec, &chunk_num); 
  cBYE(status);
  status = get_chunk_dir_idx(ptr_S, ptr_vec, chunk_num, 
      &(ptr_vec->num_chunks), &chunk_dir_idx, true); 
  cBYE(status);
  CHUNK_REC_TYPE *chunk = ptr_S->chunk_dir->chunks + chunk_dir_idx;
  if ( strcmp(ptr_vec->fldtype, "B1") == 0 ) {
    // Unfortunately, need to handle B1 as a special case
    uint32_t num_in_chunk = ptr_vec->num_elements % ptr_S->chunk_size;
    const uint64_t *const in_bdata = (const uint64_t *const )data;
    uint64_t *out_bdata = (uint64_t *)chunk->data;
    uint64_t word_idx = num_in_chunk / 64;
    uint64_t  bit_idx = num_in_chunk % 64;
    uint64_t one = 1 ;
    uint64_t mask = one << bit_idx;
    /*
      int buflen = 32;
      char buf[buflen];
      memset(buf, '\0', buflen);
      as_hex(mask, buf, buflen);
      printf("%llu, %llu, %s \n", n_put1, *in_bdata, buf);
    */
    if ( *in_bdata == 0 ) { 
      mask = ~mask;
      out_bdata[word_idx] &= mask;
    }
    else if ( *in_bdata == 1 ) { 
      out_bdata[word_idx] |= mask;
    }
    else {
      go_BYE(-1);
    }
  }
  else {
    uint32_t in_chunk_idx = ptr_vec->num_elements % ptr_S->chunk_size;
    uint32_t offset = (in_chunk_idx*ptr_vec->field_width);
    char *data_ptr = chunk->data + offset;
    l_memcpy(data_ptr, data, ptr_vec->field_width);
  }
  ptr_vec->num_elements++;
BYE:
  return status;
}

int
vec_same_state(
    VEC_REC_TYPE *ptr_v1,
    VEC_REC_TYPE *ptr_v2
    )
{
  int status = 0;
  if ( ptr_v1 == NULL ) { go_BYE(-1); }
  if ( ptr_v2 == NULL ) { go_BYE(-1); }
  if ( ptr_v1->num_elements != ptr_v2->num_elements ) { go_BYE(-1); }
  if ( ptr_v1->is_eov != ptr_v2->is_eov ) { go_BYE(-1); }
  if ( ptr_v1->is_memo != ptr_v2->is_memo ) { go_BYE(-1); }
  if ( ptr_v1->is_persist != ptr_v2->is_persist ) { go_BYE(-1); }
BYE:
  return status;
}

int
vec_file_name(
    qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec,
    int32_t chunk_num,
    char **ptr_file_name
    )
{
  int status = 0;
  *ptr_file_name = NULL;

  if ( chunk_num == -1 ) { // want file name for vector 
    status = mk_file_name(ptr_S, ptr_vec->uqid, ptr_file_name); 
    cBYE(status);
  }
  else if ( chunk_num >= 0 ) {
    if ( (uint32_t)chunk_num >= ptr_vec->num_chunks ) { go_BYE(-1); }
    uint32_t chunk_dir_idx = ptr_vec->chunks[chunk_num];
    chk_chunk_dir_idx(chunk_dir_idx);
    CHUNK_REC_TYPE *chunk = ptr_S->chunk_dir->chunks + chunk_dir_idx;
    status = mk_file_name(ptr_S, chunk->uqid, ptr_file_name); 
    cBYE(status);
  }
  else { 
    go_BYE(-1);
  }
BYE:
  return status;
}

int 
vec_reincarnate(
    qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec,
    const char * const fldtype,
    uint32_t field_width,
    int64_t num_elements,
    int64_t vec_uqid,
    int64_t *chunk_uqids, // [num_chunks]
    uint32_t num_chunks_to_allocate
    )
{
  int status = 0;

  if ( num_elements == 0 ) { go_BYE(-1); }
  if ( vec_uqid == 0 ) { go_BYE(-1); }
  if ( chunk_uqids == NULL ) { go_BYE(-1); }
  if ( field_width == 0 ) { go_BYE(-1); }
  if ( fldtype == NULL ) { go_BYE(-1); }

  status = vec_new(ptr_S, ptr_vec, fldtype, field_width, vec_uqid,
      num_chunks_to_allocate);
  cBYE(status);
  bool b_is_vec_file = is_vec_file(ptr_S, ptr_vec); 

  ptr_vec->num_elements = num_elements; // after init_chunk_dir()
  ptr_vec->num_chunks   = num_chunks_to_allocate;
  for ( uint32_t i = 0; i < num_chunks_to_allocate; i++ ) {
    uint32_t chunk_dir_idx;
    // Note that we reserve a location for the chunk in chunk_dir_idx
    // but we do not malloc the data inside it 
    status = allocate_chunk(ptr_S, ptr_vec, i, &chunk_dir_idx, false,
        chunk_uqids[i]); 
    cBYE(status); 
    chk_chunk_dir_idx(chunk_dir_idx); 
    ptr_vec->chunks[i] = chunk_dir_idx;
    CHUNK_REC_TYPE *chunk = ptr_S->chunk_dir->chunks + chunk_dir_idx;
    chunk->uqid = chunk_uqids[i]; // Important: over-write
    if ( ( !b_is_vec_file ) && ( !is_chunk_file(ptr_S, ptr_vec, i) ) ) {
      go_BYE(-1);
    }
  }
  ptr_vec->num_elements = num_elements;
  ptr_vec->is_eov     = true;
  ptr_vec->is_memo    = true;
  ptr_vec->is_persist = true;
  ptr_vec->g_S        = ptr_S;
  //------------
BYE:
  return status;
}
int 
vec_clone(
    qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_in_vec,
    VEC_REC_TYPE *ptr_out_vec
    )
{
  int status = 0;

  if ( ptr_in_vec  == NULL ) { go_BYE(-1); }
  if ( ptr_out_vec == NULL ) { go_BYE(-1); }
  if ( ptr_in_vec->is_dead ) { go_BYE(-1); }
  if ( !ptr_in_vec->is_eov ) { go_BYE(-1); }
  //----------------

  status = vec_new(ptr_S, ptr_out_vec, ptr_in_vec->fldtype, 
      ptr_in_vec->field_width, 0, ptr_in_vec->num_chunks);
  cBYE(status);
  //  If in vec has a master file, make one for out_vec
  status = duplicate_vec_file(
    ptr_in_vec->whole_vec_dir_idx, ptr_out_vec->whole_vec_dir_idx);
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
  //-------------------------

  ptr_out_vec->num_elements = ptr_in_vec->num_elements; 
  ptr_out_vec->num_chunks   = ptr_in_vec->num_chunks;
  for ( uint32_t i = 0; i < ptr_in_vec->num_chunks; i++ ) {
    uint32_t out_chunk_dir_idx;
    uint32_t in_chunk_dir_idx = ptr_in_vec->chunks[i];
    // Note that we reserve a location for the chunk in chunk_dir_idx
    // but we do not malloc the data inside it 
    status = allocate_chunk(ptr_S, ptr_out_vec, i, &out_chunk_dir_idx, 
        false, 0);
    cBYE(status); 
    chk_chunk_dir_idx(out_chunk_dir_idx); 
    ptr_out_vec->chunks[i] = out_chunk_dir_idx;
    CHUNK_REC_TYPE *out_chunk = ptr_S->chunk_dir->chunks + out_chunk_dir_idx;
    CHUNK_REC_TYPE *in_chunk = ptr_S->chunk_dir->chunks + in_chunk_dir_idx;
    if ( is_chunk_file(ptr_S, ptr_in_vec, i) )  {
      // TODO: Make a copy of the chunk file for out_vec
    }
    if ( in_chunk->data != NULL ) { 
      // TODO: Make a copy of the chunk data for out_vec
    }
  }
  ptr_out_vec->is_eov     = true;
  ptr_out_vec->is_memo    = true;
  ptr_out_vec->is_persist = true;
  ptr_out_vec->g_S        = ptr_S;
  //------------
BYE:
  return status;
}
