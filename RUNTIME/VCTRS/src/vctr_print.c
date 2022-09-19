#include "q_incs.h"
#include "qtypes.h"
#include "vctr_rs_hmap_struct.h"
#include "chnk_rs_hmap_struct.h"
#include "chnk_is.h"
#include "vctr_is.h"
#include "chnk_get_data.h"
#include "vctr_print.h"

extern vctr_rs_hmap_t g_vctr_hmap;
extern chnk_rs_hmap_t g_chnk_hmap;

int
vctr_print(
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
  if ( nn_vctr_uqid != 0 ) { go_BYE(-1); } // TODO TO BE IMPLEMENTED
  if ( ( opfile == NULL ) || ( *opfile == '\0' ) ) { 
    fp = stdout;
  }
  else {
    fp = fopen(opfile, "w");
    return_if_fopen_failed(fp, opfile, "w");
  }
  bool vctr_is_found, chnk_is_found;
  qtype_t qtype;
  uint64_t num_elements, num_to_pr, pr_idx;
  uint32_t vctr_where_found, chnk_where_found;
  uint32_t width, max_num_in_chnk;

  status = vctr_is(vctr_uqid, &vctr_is_found, &vctr_where_found);
  cBYE(status);
  if ( !vctr_is_found ) { go_BYE(-1); }

  qtype  = g_vctr_hmap.bkts[vctr_where_found].val.qtype;
  width  = g_vctr_hmap.bkts[vctr_where_found].val.width;
  max_num_in_chnk = g_vctr_hmap.bkts[vctr_where_found].val.max_num_in_chnk;
  num_elements = g_vctr_hmap.bkts[vctr_where_found].val.num_elements;;

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
  for ( ; num_to_pr > 0; ) {

    uint32_t chnk_idx = pr_idx / max_num_in_chnk;
    uint32_t chnk_off = pr_idx % max_num_in_chnk;
    //-------------------------------
    status = chnk_is(vctr_uqid, chnk_idx, &chnk_is_found,&chnk_where_found);
    cBYE(status);
    if ( !chnk_is_found ) { go_BYE(-1); }
    uint32_t num_in_chnk = 
      g_chnk_hmap.bkts[chnk_where_found].val.num_elements;
    //-----------------------------------------------------
    char *data  = chnk_get_data(chnk_where_found, false);
    data += (chnk_off * width);
    num_in_chnk -= chnk_off;  
    uint32_t l_num_to_pr = mcr_min(num_in_chnk, num_to_pr); 
    for ( uint64_t i = 0; i < l_num_to_pr; i++ ) { 
      switch ( qtype ) {
        case I1 : fprintf(fp, "%d\n", ((int8_t *)data)[i]); break; 
        case I2 : fprintf(fp, "%d\n", ((int16_t *)data)[i]); break; 
        case I4 : fprintf(fp, "%d\n", ((int32_t *)data)[i]); break; 
        case I8 : fprintf(fp, "%" PRIi64 "\n", ((int64_t *)data)[i]); break; 
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
        default : go_BYE(-1); break;
      }
    }
    // indicate that you no longer need it 
    g_chnk_hmap.bkts[chnk_where_found].val.num_readers--;
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
    fclose(fp);
  }
  return status;
}
