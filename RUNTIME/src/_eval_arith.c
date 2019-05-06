#include "q_incs.h"
#include "scalar.h"
extern int 
eval_arith(
    const char *const fldtype1,
    const char *const fldtype2,
    const char *const op,
    CDATA_TYPE cdata1,
    CDATA_TYPE cdata2,
    CDATA_TYPE *ptr_cdata
    );
int 
eval_arith(
    const char *const fldtype1,
    const char *const fldtype2,
    const char *const op,
    CDATA_TYPE cdata1,
    CDATA_TYPE cdata2,
    CDATA_TYPE *ptr_cdata
    )
{
  int status = 0;
  if ( strcmp(fldtype1, "I1") == 0 ) {
    if ( strcmp(fldtype2, "I1") == 0 ) {
      if ( strcmp(op, "+") == 0 ) {
        ptr_cdata->valI1 = cdata1.valI1  + cdata2.valI1 ;
      }
      else      if ( strcmp(op, "-") == 0 ) {
        ptr_cdata->valI1 = cdata1.valI1  - cdata2.valI1 ;
      }
      else      if ( strcmp(op, "*") == 0 ) {
        ptr_cdata->valI1 = cdata1.valI1  * cdata2.valI1 ;
      }
      else      if ( strcmp(op, "/") == 0 ) {
        ptr_cdata->valI1 = cdata1.valI1  / cdata2.valI1 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "I2") == 0 ) {
      if ( strcmp(op, "+") == 0 ) {
        ptr_cdata->valI2 = cdata1.valI1  + cdata2.valI2 ;
      }
      else      if ( strcmp(op, "-") == 0 ) {
        ptr_cdata->valI2 = cdata1.valI1  - cdata2.valI2 ;
      }
      else      if ( strcmp(op, "*") == 0 ) {
        ptr_cdata->valI2 = cdata1.valI1  * cdata2.valI2 ;
      }
      else      if ( strcmp(op, "/") == 0 ) {
        ptr_cdata->valI2 = cdata1.valI1  / cdata2.valI2 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "I4") == 0 ) {
      if ( strcmp(op, "+") == 0 ) {
        ptr_cdata->valI4 = cdata1.valI1  + cdata2.valI4 ;
      }
      else      if ( strcmp(op, "-") == 0 ) {
        ptr_cdata->valI4 = cdata1.valI1  - cdata2.valI4 ;
      }
      else      if ( strcmp(op, "*") == 0 ) {
        ptr_cdata->valI4 = cdata1.valI1  * cdata2.valI4 ;
      }
      else      if ( strcmp(op, "/") == 0 ) {
        ptr_cdata->valI4 = cdata1.valI1  / cdata2.valI4 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "I8") == 0 ) {
      if ( strcmp(op, "+") == 0 ) {
        ptr_cdata->valI8 = cdata1.valI1  + cdata2.valI8 ;
      }
      else      if ( strcmp(op, "-") == 0 ) {
        ptr_cdata->valI8 = cdata1.valI1  - cdata2.valI8 ;
      }
      else      if ( strcmp(op, "*") == 0 ) {
        ptr_cdata->valI8 = cdata1.valI1  * cdata2.valI8 ;
      }
      else      if ( strcmp(op, "/") == 0 ) {
        ptr_cdata->valI8 = cdata1.valI1  / cdata2.valI8 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "F4") == 0 ) {
      if ( strcmp(op, "+") == 0 ) {
        ptr_cdata->valF4 = cdata1.valI1  + cdata2.valF4 ;
      }
      else      if ( strcmp(op, "-") == 0 ) {
        ptr_cdata->valF4 = cdata1.valI1  - cdata2.valF4 ;
      }
      else      if ( strcmp(op, "*") == 0 ) {
        ptr_cdata->valF4 = cdata1.valI1  * cdata2.valF4 ;
      }
      else      if ( strcmp(op, "/") == 0 ) {
        ptr_cdata->valF4 = cdata1.valI1  / cdata2.valF4 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "F8") == 0 ) {
      if ( strcmp(op, "+") == 0 ) {
        ptr_cdata->valF8 = cdata1.valI1  + cdata2.valF8 ;
      }
      else      if ( strcmp(op, "-") == 0 ) {
        ptr_cdata->valF8 = cdata1.valI1  - cdata2.valF8 ;
      }
      else      if ( strcmp(op, "*") == 0 ) {
        ptr_cdata->valF8 = cdata1.valI1  * cdata2.valF8 ;
      }
      else      if ( strcmp(op, "/") == 0 ) {
        ptr_cdata->valF8 = cdata1.valI1  / cdata2.valF8 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }    else /* LOOP2 */ {
      go_BYE(-1);
    }  }else if ( strcmp(fldtype1, "I2") == 0 ) {
    if ( strcmp(fldtype2, "I1") == 0 ) {
      if ( strcmp(op, "+") == 0 ) {
        ptr_cdata->valI2 = cdata1.valI2  + cdata2.valI1 ;
      }
      else      if ( strcmp(op, "-") == 0 ) {
        ptr_cdata->valI2 = cdata1.valI2  - cdata2.valI1 ;
      }
      else      if ( strcmp(op, "*") == 0 ) {
        ptr_cdata->valI2 = cdata1.valI2  * cdata2.valI1 ;
      }
      else      if ( strcmp(op, "/") == 0 ) {
        ptr_cdata->valI2 = cdata1.valI2  / cdata2.valI1 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "I2") == 0 ) {
      if ( strcmp(op, "+") == 0 ) {
        ptr_cdata->valI2 = cdata1.valI2  + cdata2.valI2 ;
      }
      else      if ( strcmp(op, "-") == 0 ) {
        ptr_cdata->valI2 = cdata1.valI2  - cdata2.valI2 ;
      }
      else      if ( strcmp(op, "*") == 0 ) {
        ptr_cdata->valI2 = cdata1.valI2  * cdata2.valI2 ;
      }
      else      if ( strcmp(op, "/") == 0 ) {
        ptr_cdata->valI2 = cdata1.valI2  / cdata2.valI2 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "I4") == 0 ) {
      if ( strcmp(op, "+") == 0 ) {
        ptr_cdata->valI4 = cdata1.valI2  + cdata2.valI4 ;
      }
      else      if ( strcmp(op, "-") == 0 ) {
        ptr_cdata->valI4 = cdata1.valI2  - cdata2.valI4 ;
      }
      else      if ( strcmp(op, "*") == 0 ) {
        ptr_cdata->valI4 = cdata1.valI2  * cdata2.valI4 ;
      }
      else      if ( strcmp(op, "/") == 0 ) {
        ptr_cdata->valI4 = cdata1.valI2  / cdata2.valI4 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "I8") == 0 ) {
      if ( strcmp(op, "+") == 0 ) {
        ptr_cdata->valI8 = cdata1.valI2  + cdata2.valI8 ;
      }
      else      if ( strcmp(op, "-") == 0 ) {
        ptr_cdata->valI8 = cdata1.valI2  - cdata2.valI8 ;
      }
      else      if ( strcmp(op, "*") == 0 ) {
        ptr_cdata->valI8 = cdata1.valI2  * cdata2.valI8 ;
      }
      else      if ( strcmp(op, "/") == 0 ) {
        ptr_cdata->valI8 = cdata1.valI2  / cdata2.valI8 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "F4") == 0 ) {
      if ( strcmp(op, "+") == 0 ) {
        ptr_cdata->valF4 = cdata1.valI2  + cdata2.valF4 ;
      }
      else      if ( strcmp(op, "-") == 0 ) {
        ptr_cdata->valF4 = cdata1.valI2  - cdata2.valF4 ;
      }
      else      if ( strcmp(op, "*") == 0 ) {
        ptr_cdata->valF4 = cdata1.valI2  * cdata2.valF4 ;
      }
      else      if ( strcmp(op, "/") == 0 ) {
        ptr_cdata->valF4 = cdata1.valI2  / cdata2.valF4 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "F8") == 0 ) {
      if ( strcmp(op, "+") == 0 ) {
        ptr_cdata->valF8 = cdata1.valI2  + cdata2.valF8 ;
      }
      else      if ( strcmp(op, "-") == 0 ) {
        ptr_cdata->valF8 = cdata1.valI2  - cdata2.valF8 ;
      }
      else      if ( strcmp(op, "*") == 0 ) {
        ptr_cdata->valF8 = cdata1.valI2  * cdata2.valF8 ;
      }
      else      if ( strcmp(op, "/") == 0 ) {
        ptr_cdata->valF8 = cdata1.valI2  / cdata2.valF8 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }    else /* LOOP2 */ {
      go_BYE(-1);
    }  }else if ( strcmp(fldtype1, "I4") == 0 ) {
    if ( strcmp(fldtype2, "I1") == 0 ) {
      if ( strcmp(op, "+") == 0 ) {
        ptr_cdata->valI4 = cdata1.valI4  + cdata2.valI1 ;
      }
      else      if ( strcmp(op, "-") == 0 ) {
        ptr_cdata->valI4 = cdata1.valI4  - cdata2.valI1 ;
      }
      else      if ( strcmp(op, "*") == 0 ) {
        ptr_cdata->valI4 = cdata1.valI4  * cdata2.valI1 ;
      }
      else      if ( strcmp(op, "/") == 0 ) {
        ptr_cdata->valI4 = cdata1.valI4  / cdata2.valI1 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "I2") == 0 ) {
      if ( strcmp(op, "+") == 0 ) {
        ptr_cdata->valI4 = cdata1.valI4  + cdata2.valI2 ;
      }
      else      if ( strcmp(op, "-") == 0 ) {
        ptr_cdata->valI4 = cdata1.valI4  - cdata2.valI2 ;
      }
      else      if ( strcmp(op, "*") == 0 ) {
        ptr_cdata->valI4 = cdata1.valI4  * cdata2.valI2 ;
      }
      else      if ( strcmp(op, "/") == 0 ) {
        ptr_cdata->valI4 = cdata1.valI4  / cdata2.valI2 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "I4") == 0 ) {
      if ( strcmp(op, "+") == 0 ) {
        ptr_cdata->valI4 = cdata1.valI4  + cdata2.valI4 ;
      }
      else      if ( strcmp(op, "-") == 0 ) {
        ptr_cdata->valI4 = cdata1.valI4  - cdata2.valI4 ;
      }
      else      if ( strcmp(op, "*") == 0 ) {
        ptr_cdata->valI4 = cdata1.valI4  * cdata2.valI4 ;
      }
      else      if ( strcmp(op, "/") == 0 ) {
        ptr_cdata->valI4 = cdata1.valI4  / cdata2.valI4 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "I8") == 0 ) {
      if ( strcmp(op, "+") == 0 ) {
        ptr_cdata->valI8 = cdata1.valI4  + cdata2.valI8 ;
      }
      else      if ( strcmp(op, "-") == 0 ) {
        ptr_cdata->valI8 = cdata1.valI4  - cdata2.valI8 ;
      }
      else      if ( strcmp(op, "*") == 0 ) {
        ptr_cdata->valI8 = cdata1.valI4  * cdata2.valI8 ;
      }
      else      if ( strcmp(op, "/") == 0 ) {
        ptr_cdata->valI8 = cdata1.valI4  / cdata2.valI8 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "F4") == 0 ) {
      if ( strcmp(op, "+") == 0 ) {
        ptr_cdata->valF4 = cdata1.valI4  + cdata2.valF4 ;
      }
      else      if ( strcmp(op, "-") == 0 ) {
        ptr_cdata->valF4 = cdata1.valI4  - cdata2.valF4 ;
      }
      else      if ( strcmp(op, "*") == 0 ) {
        ptr_cdata->valF4 = cdata1.valI4  * cdata2.valF4 ;
      }
      else      if ( strcmp(op, "/") == 0 ) {
        ptr_cdata->valF4 = cdata1.valI4  / cdata2.valF4 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "F8") == 0 ) {
      if ( strcmp(op, "+") == 0 ) {
        ptr_cdata->valF8 = cdata1.valI4  + cdata2.valF8 ;
      }
      else      if ( strcmp(op, "-") == 0 ) {
        ptr_cdata->valF8 = cdata1.valI4  - cdata2.valF8 ;
      }
      else      if ( strcmp(op, "*") == 0 ) {
        ptr_cdata->valF8 = cdata1.valI4  * cdata2.valF8 ;
      }
      else      if ( strcmp(op, "/") == 0 ) {
        ptr_cdata->valF8 = cdata1.valI4  / cdata2.valF8 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }    else /* LOOP2 */ {
      go_BYE(-1);
    }  }else if ( strcmp(fldtype1, "I8") == 0 ) {
    if ( strcmp(fldtype2, "I1") == 0 ) {
      if ( strcmp(op, "+") == 0 ) {
        ptr_cdata->valI8 = cdata1.valI8  + cdata2.valI1 ;
      }
      else      if ( strcmp(op, "-") == 0 ) {
        ptr_cdata->valI8 = cdata1.valI8  - cdata2.valI1 ;
      }
      else      if ( strcmp(op, "*") == 0 ) {
        ptr_cdata->valI8 = cdata1.valI8  * cdata2.valI1 ;
      }
      else      if ( strcmp(op, "/") == 0 ) {
        ptr_cdata->valI8 = cdata1.valI8  / cdata2.valI1 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "I2") == 0 ) {
      if ( strcmp(op, "+") == 0 ) {
        ptr_cdata->valI8 = cdata1.valI8  + cdata2.valI2 ;
      }
      else      if ( strcmp(op, "-") == 0 ) {
        ptr_cdata->valI8 = cdata1.valI8  - cdata2.valI2 ;
      }
      else      if ( strcmp(op, "*") == 0 ) {
        ptr_cdata->valI8 = cdata1.valI8  * cdata2.valI2 ;
      }
      else      if ( strcmp(op, "/") == 0 ) {
        ptr_cdata->valI8 = cdata1.valI8  / cdata2.valI2 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "I4") == 0 ) {
      if ( strcmp(op, "+") == 0 ) {
        ptr_cdata->valI8 = cdata1.valI8  + cdata2.valI4 ;
      }
      else      if ( strcmp(op, "-") == 0 ) {
        ptr_cdata->valI8 = cdata1.valI8  - cdata2.valI4 ;
      }
      else      if ( strcmp(op, "*") == 0 ) {
        ptr_cdata->valI8 = cdata1.valI8  * cdata2.valI4 ;
      }
      else      if ( strcmp(op, "/") == 0 ) {
        ptr_cdata->valI8 = cdata1.valI8  / cdata2.valI4 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "I8") == 0 ) {
      if ( strcmp(op, "+") == 0 ) {
        ptr_cdata->valI8 = cdata1.valI8  + cdata2.valI8 ;
      }
      else      if ( strcmp(op, "-") == 0 ) {
        ptr_cdata->valI8 = cdata1.valI8  - cdata2.valI8 ;
      }
      else      if ( strcmp(op, "*") == 0 ) {
        ptr_cdata->valI8 = cdata1.valI8  * cdata2.valI8 ;
      }
      else      if ( strcmp(op, "/") == 0 ) {
        ptr_cdata->valI8 = cdata1.valI8  / cdata2.valI8 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "F4") == 0 ) {
      if ( strcmp(op, "+") == 0 ) {
        ptr_cdata->valF4 = cdata1.valI8  + cdata2.valF4 ;
      }
      else      if ( strcmp(op, "-") == 0 ) {
        ptr_cdata->valF4 = cdata1.valI8  - cdata2.valF4 ;
      }
      else      if ( strcmp(op, "*") == 0 ) {
        ptr_cdata->valF4 = cdata1.valI8  * cdata2.valF4 ;
      }
      else      if ( strcmp(op, "/") == 0 ) {
        ptr_cdata->valF4 = cdata1.valI8  / cdata2.valF4 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "F8") == 0 ) {
      if ( strcmp(op, "+") == 0 ) {
        ptr_cdata->valF8 = cdata1.valI8  + cdata2.valF8 ;
      }
      else      if ( strcmp(op, "-") == 0 ) {
        ptr_cdata->valF8 = cdata1.valI8  - cdata2.valF8 ;
      }
      else      if ( strcmp(op, "*") == 0 ) {
        ptr_cdata->valF8 = cdata1.valI8  * cdata2.valF8 ;
      }
      else      if ( strcmp(op, "/") == 0 ) {
        ptr_cdata->valF8 = cdata1.valI8  / cdata2.valF8 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }    else /* LOOP2 */ {
      go_BYE(-1);
    }  }else if ( strcmp(fldtype1, "F4") == 0 ) {
    if ( strcmp(fldtype2, "I1") == 0 ) {
      if ( strcmp(op, "+") == 0 ) {
        ptr_cdata->valF4 = cdata1.valF4  + cdata2.valI1 ;
      }
      else      if ( strcmp(op, "-") == 0 ) {
        ptr_cdata->valF4 = cdata1.valF4  - cdata2.valI1 ;
      }
      else      if ( strcmp(op, "*") == 0 ) {
        ptr_cdata->valF4 = cdata1.valF4  * cdata2.valI1 ;
      }
      else      if ( strcmp(op, "/") == 0 ) {
        ptr_cdata->valF4 = cdata1.valF4  / cdata2.valI1 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "I2") == 0 ) {
      if ( strcmp(op, "+") == 0 ) {
        ptr_cdata->valF4 = cdata1.valF4  + cdata2.valI2 ;
      }
      else      if ( strcmp(op, "-") == 0 ) {
        ptr_cdata->valF4 = cdata1.valF4  - cdata2.valI2 ;
      }
      else      if ( strcmp(op, "*") == 0 ) {
        ptr_cdata->valF4 = cdata1.valF4  * cdata2.valI2 ;
      }
      else      if ( strcmp(op, "/") == 0 ) {
        ptr_cdata->valF4 = cdata1.valF4  / cdata2.valI2 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "I4") == 0 ) {
      if ( strcmp(op, "+") == 0 ) {
        ptr_cdata->valF4 = cdata1.valF4  + cdata2.valI4 ;
      }
      else      if ( strcmp(op, "-") == 0 ) {
        ptr_cdata->valF4 = cdata1.valF4  - cdata2.valI4 ;
      }
      else      if ( strcmp(op, "*") == 0 ) {
        ptr_cdata->valF4 = cdata1.valF4  * cdata2.valI4 ;
      }
      else      if ( strcmp(op, "/") == 0 ) {
        ptr_cdata->valF4 = cdata1.valF4  / cdata2.valI4 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "I8") == 0 ) {
      if ( strcmp(op, "+") == 0 ) {
        ptr_cdata->valF4 = cdata1.valF4  + cdata2.valI8 ;
      }
      else      if ( strcmp(op, "-") == 0 ) {
        ptr_cdata->valF4 = cdata1.valF4  - cdata2.valI8 ;
      }
      else      if ( strcmp(op, "*") == 0 ) {
        ptr_cdata->valF4 = cdata1.valF4  * cdata2.valI8 ;
      }
      else      if ( strcmp(op, "/") == 0 ) {
        ptr_cdata->valF4 = cdata1.valF4  / cdata2.valI8 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "F4") == 0 ) {
      if ( strcmp(op, "+") == 0 ) {
        ptr_cdata->valF4 = cdata1.valF4  + cdata2.valF4 ;
      }
      else      if ( strcmp(op, "-") == 0 ) {
        ptr_cdata->valF4 = cdata1.valF4  - cdata2.valF4 ;
      }
      else      if ( strcmp(op, "*") == 0 ) {
        ptr_cdata->valF4 = cdata1.valF4  * cdata2.valF4 ;
      }
      else      if ( strcmp(op, "/") == 0 ) {
        ptr_cdata->valF4 = cdata1.valF4  / cdata2.valF4 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "F8") == 0 ) {
      if ( strcmp(op, "+") == 0 ) {
        ptr_cdata->valF8 = cdata1.valF4  + cdata2.valF8 ;
      }
      else      if ( strcmp(op, "-") == 0 ) {
        ptr_cdata->valF8 = cdata1.valF4  - cdata2.valF8 ;
      }
      else      if ( strcmp(op, "*") == 0 ) {
        ptr_cdata->valF8 = cdata1.valF4  * cdata2.valF8 ;
      }
      else      if ( strcmp(op, "/") == 0 ) {
        ptr_cdata->valF8 = cdata1.valF4  / cdata2.valF8 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }    else /* LOOP2 */ {
      go_BYE(-1);
    }  }else if ( strcmp(fldtype1, "F8") == 0 ) {
    if ( strcmp(fldtype2, "I1") == 0 ) {
      if ( strcmp(op, "+") == 0 ) {
        ptr_cdata->valF8 = cdata1.valF8  + cdata2.valI1 ;
      }
      else      if ( strcmp(op, "-") == 0 ) {
        ptr_cdata->valF8 = cdata1.valF8  - cdata2.valI1 ;
      }
      else      if ( strcmp(op, "*") == 0 ) {
        ptr_cdata->valF8 = cdata1.valF8  * cdata2.valI1 ;
      }
      else      if ( strcmp(op, "/") == 0 ) {
        ptr_cdata->valF8 = cdata1.valF8  / cdata2.valI1 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "I2") == 0 ) {
      if ( strcmp(op, "+") == 0 ) {
        ptr_cdata->valF8 = cdata1.valF8  + cdata2.valI2 ;
      }
      else      if ( strcmp(op, "-") == 0 ) {
        ptr_cdata->valF8 = cdata1.valF8  - cdata2.valI2 ;
      }
      else      if ( strcmp(op, "*") == 0 ) {
        ptr_cdata->valF8 = cdata1.valF8  * cdata2.valI2 ;
      }
      else      if ( strcmp(op, "/") == 0 ) {
        ptr_cdata->valF8 = cdata1.valF8  / cdata2.valI2 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "I4") == 0 ) {
      if ( strcmp(op, "+") == 0 ) {
        ptr_cdata->valF8 = cdata1.valF8  + cdata2.valI4 ;
      }
      else      if ( strcmp(op, "-") == 0 ) {
        ptr_cdata->valF8 = cdata1.valF8  - cdata2.valI4 ;
      }
      else      if ( strcmp(op, "*") == 0 ) {
        ptr_cdata->valF8 = cdata1.valF8  * cdata2.valI4 ;
      }
      else      if ( strcmp(op, "/") == 0 ) {
        ptr_cdata->valF8 = cdata1.valF8  / cdata2.valI4 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "I8") == 0 ) {
      if ( strcmp(op, "+") == 0 ) {
        ptr_cdata->valF8 = cdata1.valF8  + cdata2.valI8 ;
      }
      else      if ( strcmp(op, "-") == 0 ) {
        ptr_cdata->valF8 = cdata1.valF8  - cdata2.valI8 ;
      }
      else      if ( strcmp(op, "*") == 0 ) {
        ptr_cdata->valF8 = cdata1.valF8  * cdata2.valI8 ;
      }
      else      if ( strcmp(op, "/") == 0 ) {
        ptr_cdata->valF8 = cdata1.valF8  / cdata2.valI8 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "F4") == 0 ) {
      if ( strcmp(op, "+") == 0 ) {
        ptr_cdata->valF8 = cdata1.valF8  + cdata2.valF4 ;
      }
      else      if ( strcmp(op, "-") == 0 ) {
        ptr_cdata->valF8 = cdata1.valF8  - cdata2.valF4 ;
      }
      else      if ( strcmp(op, "*") == 0 ) {
        ptr_cdata->valF8 = cdata1.valF8  * cdata2.valF4 ;
      }
      else      if ( strcmp(op, "/") == 0 ) {
        ptr_cdata->valF8 = cdata1.valF8  / cdata2.valF4 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "F8") == 0 ) {
      if ( strcmp(op, "+") == 0 ) {
        ptr_cdata->valF8 = cdata1.valF8  + cdata2.valF8 ;
      }
      else      if ( strcmp(op, "-") == 0 ) {
        ptr_cdata->valF8 = cdata1.valF8  - cdata2.valF8 ;
      }
      else      if ( strcmp(op, "*") == 0 ) {
        ptr_cdata->valF8 = cdata1.valF8  * cdata2.valF8 ;
      }
      else      if ( strcmp(op, "/") == 0 ) {
        ptr_cdata->valF8 = cdata1.valF8  / cdata2.valF8 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }    else /* LOOP2 */ {
      go_BYE(-1);
    }  }  else /* LOOP 1 */{
    go_BYE(-1);
  } BYE:
  return status;
}
