#include "q_incs.h"
#include "qtypes.h"
#include "qjit_consts.h"
#include "vctr_rs_hmap_struct.h"
#include "chnk_rs_hmap_struct.h"
#include "chnk_is.h"
#include "vctr_is.h"
#include "l2_file_name.h"
#include "file_exists.h"
#include "rs_mmap.h"
#include "chnk_get_data.h"
#include "get_bit_u64.h"
#include "vctr_print.h"

extern vctr_rs_hmap_t *g_vctr_hmap;
extern chnk_rs_hmap_t *g_chnk_hmap;

int
vctr_print_lma(
    FILE *fp,
    const char * const format,
    uint32_t tbsp,
    uint32_t vctr_uqid,
    vctr_rs_hmap_val_t *ptr_val,
    uint64_t lb,
    uint64_t ub
    )
{
  int status = 0;
  char *lma_file = NULL; 
  char *X = NULL, *Y = NULL; size_t nX = 0;
  if ( !ptr_val->is_lma ) { go_BYE(-1); } 
  if ( ptr_val->num_writers > 0 ) { go_BYE(-1); } 
  if ( ptr_val->num_readers > 0 ) { 
    X = ptr_val->X;
    nX = ptr_val->nX;
  }
  else {
    if ( ptr_val->X != NULL ) { go_BYE(-1); } 
    if ( ptr_val->nX != 0   ) { go_BYE(-1); } 
    lma_file = l2_file_name(tbsp, vctr_uqid, ((uint32_t)~0));
    if ( lma_file == NULL ) { go_BYE(-1); }
    if ( !file_exists(lma_file) ) { go_BYE(-1); }
    status = rs_mmap(lma_file, &X, &nX, 0); cBYE(status);
  }
  if ( ( X == NULL ) || ( nX == 0 ) ) { go_BYE(-1); }
  uint32_t width = ptr_val->width;
  qtype_t qtype  = ptr_val->qtype;
  size_t offset = lb * width;
  Y = X + offset;
  for ( uint64_t i = 0; i < (ub-lb); i++ ) {
    switch ( qtype ) {
      case B1 : go_BYE(-1); break; // TODO P2 
      case BL : fprintf(fp, "%s\n", 
                    ((bool *)Y)[i] ? "true" : "false"); break;
      case I1 : fprintf(fp, "%d\n", ((int8_t *)Y)[i]); break; 
      case I2 : fprintf(fp, "%d\n", ((int16_t *)Y)[i]); break; 
      case I4 : fprintf(fp, "%d\n", ((int32_t *)Y)[i]); break; 
      case I8 : fprintf(fp, "%" PRIi64 "\n", ((int64_t *)Y)[i]); break; 
      case F2 : {
                  float ftmp = F2_to_F4(((bfloat16 *)Y)[i]);
                  fprintf(fp, "%f\n", ftmp);
                }
                break;
      case F4 : fprintf(fp, "%f\n", ((float *)Y)[i]); break; 
      case F8 : fprintf(fp, "%lf\n", ((double *)Y)[i]); break; 
      case SC : { 
                  char *cptr = (char *)Y;
                  cptr += (i*width);
                  fprintf(fp, "%s\n", cptr);
                }
                break;
      case TM : {
                  char buf[64]; 
                  int len = sizeof(buf); 
                  memset(buf, 0, len);
                  struct tm * tptr = ((struct tm *)Y) + i;
                  size_t nw = strftime(buf, len-1, format, tptr);
                  if ( nw == 0 ) { go_BYE(-1); }
                  fprintf(fp, "%s\n", buf);
                }
                break;
      case TM1 : {
                   char buf[64]; 
                   int len = sizeof(buf); 
                   memset(buf, 0, len);
                   tm_t * tptr = ((tm_t *)Y);
                   snprintf(buf, len-1, "\"%d-%02d-%02d %d:%d %d\"", 
                       tptr[i].tm_year + 1900,
                       tptr[i].tm_mon + 1,
                       tptr[i].tm_mday,
                       tptr[i].tm_hour,
                       // tptr[i].tm_min,
                       // tptr[i].tm_sec,
                       tptr[i].tm_wday, 
                       tptr[i].tm_yday);

                   fprintf(fp, "%s\n", buf);
                 }
                 break;
      default : go_BYE(-1); break;
    }
  }

  // release resources you might have acquired
  if ( ptr_val->num_readers > 0 ) { 
    munmap(X, nX); 
  }
BYE:
  return status;
}

int
vctr_print(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    uint32_t nn_vctr_uqid,
    const char * const opfile,
    const char * const format,
    uint64_t lb,
    uint64_t ub
    )
{
  int status = 0;
  FILE *fp = NULL;

  if ( vctr_uqid == 0 ) { go_BYE(-1); }
  if ( ( opfile == NULL ) || ( *opfile == '\0' ) ) { 
    fp = stdout;
  }
  else {
    fp = fopen(opfile, "w");
    return_if_fopen_failed(fp, opfile, "w");
  }
  bool vctr_is_found, chnk_is_found;
  bool nn_vctr_is_found, nn_chnk_is_found;
  qtype_t qtype, nn_qtype = Q0;
  uint64_t num_elements, num_to_pr, pr_idx;
  uint64_t nn_num_elements;
  uint32_t vctr_where_found, chnk_where_found;
  uint32_t nn_vctr_where_found, nn_chnk_where_found;
  uint32_t width, max_num_in_chnk;
  uint32_t nn_width, nn_max_num_in_chnk;

  status = vctr_is(tbsp, vctr_uqid, &vctr_is_found, &vctr_where_found);
  cBYE(status);
  if ( !vctr_is_found ) { go_BYE(-1); }

  if ( nn_vctr_uqid > 0 ) { 
    status = vctr_is(tbsp, nn_vctr_uqid, &nn_vctr_is_found, &nn_vctr_where_found);
    cBYE(status);
    if ( !nn_vctr_is_found ) { go_BYE(-1); }
  }

  qtype  = g_vctr_hmap[tbsp].bkts[vctr_where_found].val.qtype;
  width  = g_vctr_hmap[tbsp].bkts[vctr_where_found].val.width;
  max_num_in_chnk = g_vctr_hmap[tbsp].bkts[vctr_where_found].val.max_num_in_chnk;
  num_elements = g_vctr_hmap[tbsp].bkts[vctr_where_found].val.num_elements;

  if ( nn_vctr_uqid > 0 ) { 
    nn_qtype  = g_vctr_hmap[tbsp].bkts[nn_vctr_where_found].val.qtype;
    nn_width  = g_vctr_hmap[tbsp].bkts[nn_vctr_where_found].val.width;
    nn_max_num_in_chnk = g_vctr_hmap[tbsp].bkts[nn_vctr_where_found].val.max_num_in_chnk;
    nn_num_elements = g_vctr_hmap[tbsp].bkts[nn_vctr_where_found].val.num_elements;
    if ( ( nn_qtype != BL ) && ( nn_qtype != B1 ) ) { go_BYE(-1); }
    if ( nn_qtype == BL ) { if ( nn_width != 1  ) { go_BYE(-1); } }
    if ( nn_max_num_in_chnk != max_num_in_chnk ) { go_BYE(-1); }
    if ( nn_num_elements != num_elements ) { go_BYE(-1); }
  }

  if ( ub == 0 ) { ub = num_elements; }
  if ( ub <= lb ) { go_BYE(-1); } 
  if ( ub > num_elements ) { go_BYE(-1); }

  if ( qtype == TM ) { 
    if ( ( format == NULL ) || ( *format == '\0' ) ) {
      go_BYE(-1);
    }
  }
  num_to_pr = ub - lb;
  pr_idx = lb;
  //-----------------------------------------
  if ( g_vctr_hmap[tbsp].bkts[vctr_where_found].val.is_lma ) {
    status = vctr_print_lma(fp, format, tbsp, vctr_uqid, 
        &(g_vctr_hmap[tbsp].bkts[vctr_where_found].val), lb, ub);
    cBYE(status);
    goto BYE; 
  }
  //-----------------------------------------

  for ( ; num_to_pr > 0; ) {

    uint32_t chnk_idx = pr_idx / max_num_in_chnk;
    uint32_t chnk_off = pr_idx % max_num_in_chnk;
    //-------------------------------
    status = chnk_is(tbsp, vctr_uqid, chnk_idx, &chnk_is_found,&chnk_where_found);
    cBYE(status);
    if ( !chnk_is_found ) { go_BYE(-1); }
    uint32_t num_in_chnk = 
      g_chnk_hmap[tbsp].bkts[chnk_where_found].val.num_elements;
    char *data  = chnk_get_data(tbsp, chnk_where_found, false);
    char *orig_data = data;
    //-----------------------------------------------------
    char *nn_data = NULL, *nn_orig_data = NULL;
    if ( nn_vctr_uqid > 0 ) {
      status = chnk_is(tbsp, nn_vctr_uqid, chnk_idx, &nn_chnk_is_found, 
          &nn_chnk_where_found);
      cBYE(status);
      if ( !nn_chnk_is_found ) { go_BYE(-1); }
      uint32_t nn_num_in_chnk = 
        g_chnk_hmap[tbsp].bkts[nn_chnk_where_found].val.num_elements;
      if ( nn_num_in_chnk != num_in_chnk ) { go_BYE(-1); }
      nn_data  = chnk_get_data(tbsp, nn_chnk_where_found, false);
      nn_orig_data = nn_data;
    }
    //-----------------------------------------------------
    data += (chnk_off * width);
    num_in_chnk -= chnk_off;  
    uint32_t l_num_to_pr = mcr_min(num_in_chnk, num_to_pr); 
    for ( uint64_t i = 0; i < l_num_to_pr; i++ ) {
      if ( nn_vctr_uqid > 0 ) { 
        switch ( nn_qtype ) {
          case BL : 
            if ( ((bool *)nn_data)[i] == false ) { 
              fprintf(fp, "\"\"\n"); continue;
            }
            break;
          case B1 : 
            {
              int ival = get_bit_u64((uint64_t *)nn_orig_data, chnk_off+i); 
              if ( ival == 0 ) { fprintf(fp, "\"\"\n"); continue; }
            }
            break;
          default : 
            go_BYE(-1); break; 
        }
      }
      switch ( qtype ) {
        case B1 : 
          {
            int ival = get_bit_u64((uint64_t *)orig_data, chnk_off+i); 
            cBYE(status);
            fprintf(fp, "%s\n", ival ? "true" : "false"); break;
          }
        case BL : fprintf(fp, "%s\n", 
                      ((bool *)data)[i] ? "true" : "false"); break;
        case I1 : fprintf(fp, "%d\n", ((int8_t *)data)[i]); break; 
        case I2 : fprintf(fp, "%d\n", ((int16_t *)data)[i]); break; 
        case I4 : fprintf(fp, "%d\n", ((int32_t *)data)[i]); break; 
        case I8 : fprintf(fp, "%" PRIi64 "\n", ((int64_t *)data)[i]); break; 
        case UI1 : fprintf(fp, "%d\n", ((uint8_t *)data)[i]); break; 
        case UI2 : fprintf(fp, "%d\n", ((uint16_t *)data)[i]); break; 
        case UI4 : fprintf(fp, "%d\n", ((uint32_t *)data)[i]); break; 
        case UI8 : fprintf(fp, "%" PRIu64 "\n", ((uint64_t *)data)[i]); break; 
        case F2 : 
                   {
                     float ftmp = F2_to_F4(((bfloat16 *)data)[i]);
                     fprintf(fp, "%f\n", ftmp);
                   }
                   break; 
        case F4 : fprintf(fp, "%f\n", ((float *)data)[i]); break; 
        case F8 : fprintf(fp, "%lf\n", ((double *)data)[i]); break; 
        case SC : { 
                    char *cptr = (char *)data;
                    cptr += (i*width);
                    fprintf(fp, "%s\n", cptr);
                  }
                  break;
        case TM : {
                    char buf[64]; 
                    int len = sizeof(buf); 
                    memset(buf, 0, len);
                    struct tm * tptr = ((struct tm *)data) + i;
                    size_t nw = strftime(buf, len-1, format, tptr);
                    if ( nw == 0 ) { go_BYE(-1); }
                    fprintf(fp, "%s\n", buf);
                  }
                  break;
        case TM1 : {
                     char buf[64]; 
                     int len = sizeof(buf); 
                     memset(buf, 0, len);
                     tm_t * tptr = ((tm_t *)data);
                     snprintf(buf, len-1, "\"%d-%02d-%02d %d:%d:%d\"", 
                         tptr[i].tm_year + 1900,
                         tptr[i].tm_mon + 1,
                         tptr[i].tm_mday,
                         tptr[i].tm_hour,
                         // tptr[i].tm_min,
                         // tptr[i].tm_sec,
                         tptr[i].tm_wday,
                         tptr[i].tm_yday);

                     fprintf(fp, "%s\n", buf);
                   }
                  break;
        default : go_BYE(-1); break;
      }
    }
    // indicate that you no longer need it 
    g_chnk_hmap[tbsp].bkts[chnk_where_found].val.num_readers--;
    if ( nn_vctr_uqid > 0 ) {
      g_chnk_hmap[tbsp].bkts[nn_chnk_where_found].val.num_readers--;
    }
    //-------------
    lb += l_num_to_pr; 
    num_to_pr = ub - lb;
    pr_idx = lb;
  }
BYE:
  if ( ( opfile == NULL ) || ( *opfile == '\0' ) ) { 
    // nothing to do 
  }
  else {
    fclose_if_non_null(fp);
  }
  return status;
}
