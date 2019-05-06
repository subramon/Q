
#include "_bin_search_I8.h"

      int
      bin_search_I8(
          const int64_t *X,
          uint64_t nX,
          int64_t key,
          const char * const str_direction,
          int64_t *ptr_pos
          )
      {
        int status = 0;
        uint64_t pos, lb, ub, mid;
        int direction;

        if ( X == NULL ) go_BYE(-1);
        if ( nX <= 0 ) go_BYE(-1);
        if ( nX == 1 ) { 
          if ( X[0] == key ) { 
            *ptr_pos = 0; 
          }
          else {
            *ptr_pos = -1;
          }
          return status ; 
        }

        lb = 0; ub = nX - 1;
        *ptr_pos = pos = -1;
        for ( ; lb < ub ; ) {  // TODO P2 Confirm that this is not <=
          mid = ( lb + ub )  / 2 ;
          if ( X[mid] == key ) { 
            pos = mid;
            break;
          }
          else if ( key < X[mid] ) { /* reduce ub */
            ub = mcr_min(ub - 1, mid);
          }
          else /* key > X[mid] */ { /* increase lb */
            lb = mcr_max(lb + 1, mid);
          }
        }
        /* The following is meant to handle the case when the values are not unique
         */
        if ( ( str_direction == NULL ) || ( strlen(str_direction) == 0 ) ) { 
          direction = BSEARCH_DONTCARE; // Default setting
        }
        else if ( strcasecmp(str_direction, "lowest") == 0  ) {
          direction = BSEARCH_LOWEST; 
        }
        else if ( strcasecmp(str_direction, "highest") == 0  ) {
          direction = BSEARCH_HIGHEST; 
        }
        else if ( strcasecmp(str_direction, "dontcare") == 0  ) {
          direction = BSEARCH_DONTCARE; 
        }
        else { 
          go_BYE(-1);
        }
        switch ( direction ) { 
          case BSEARCH_LOWEST : 
            for ( ; pos > 0; ) { 
              if ( X[pos-1] == key ) { pos--; } else { break; }
            }
            break;
          case BSEARCH_HIGHEST : 
            for ( ; pos < nX-1; ) { 
              if ( X[pos+1] == key ) { pos++; } else { break; }
            }
            break;
          case BSEARCH_DONTCARE : 
            /* Nothing to do */
            break;
          default : go_BYE(-1);
        }
        *ptr_pos = (int64_t)pos;
BYE:
        return status ;
      }

  
