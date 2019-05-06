#include "q_incs.h"
#include "scalar.h"
extern int 
eval_cmp(
    const char *const fldtype1,
    const char *const fldtype2,
    const char *const op,
    CDATA_TYPE cdata1,
    CDATA_TYPE cdata2,
    int *ptr_ret_val
    );
int 
eval_cmp(
    const char *const fldtype1,
    const char *const fldtype2,
    const char *const op,
    CDATA_TYPE cdata1,
    CDATA_TYPE cdata2,
    int *ptr_ret_val
    )
{
  int status = 0;
  int ret_val;
  if ( strcmp(fldtype1, "B1") == 0 ) {
    if ( strcmp(fldtype2, "B1") == 0 ) {
      if ( strcmp(op, "==") == 0 ) {
        ret_val = cdata1.valB1  == cdata2.valB1 ;
      }
      else      if ( strcmp(op, "!=") == 0 ) {
        ret_val = cdata1.valB1  != cdata2.valB1 ;
      }
      else      if ( strcmp(op, ">") == 0 ) {
        ret_val = cdata1.valB1  > cdata2.valB1 ;
      }
      else      if ( strcmp(op, "<") == 0 ) {
        ret_val = cdata1.valB1  < cdata2.valB1 ;
      }
      else      if ( strcmp(op, ">=") == 0 ) {
        ret_val = cdata1.valB1  >= cdata2.valB1 ;
      }
      else      if ( strcmp(op, "<=") == 0 ) {
        ret_val = cdata1.valB1  <= cdata2.valB1 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "I1") == 0 ) {
      if ( strcmp(op, "==") == 0 ) {
        ret_val = cdata1.valB1  == cdata2.valI1 ;
      }
      else      if ( strcmp(op, "!=") == 0 ) {
        ret_val = cdata1.valB1  != cdata2.valI1 ;
      }
      else      if ( strcmp(op, ">") == 0 ) {
        ret_val = cdata1.valB1  > cdata2.valI1 ;
      }
      else      if ( strcmp(op, "<") == 0 ) {
        ret_val = cdata1.valB1  < cdata2.valI1 ;
      }
      else      if ( strcmp(op, ">=") == 0 ) {
        ret_val = cdata1.valB1  >= cdata2.valI1 ;
      }
      else      if ( strcmp(op, "<=") == 0 ) {
        ret_val = cdata1.valB1  <= cdata2.valI1 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "I2") == 0 ) {
      if ( strcmp(op, "==") == 0 ) {
        ret_val = cdata1.valB1  == cdata2.valI2 ;
      }
      else      if ( strcmp(op, "!=") == 0 ) {
        ret_val = cdata1.valB1  != cdata2.valI2 ;
      }
      else      if ( strcmp(op, ">") == 0 ) {
        ret_val = cdata1.valB1  > cdata2.valI2 ;
      }
      else      if ( strcmp(op, "<") == 0 ) {
        ret_val = cdata1.valB1  < cdata2.valI2 ;
      }
      else      if ( strcmp(op, ">=") == 0 ) {
        ret_val = cdata1.valB1  >= cdata2.valI2 ;
      }
      else      if ( strcmp(op, "<=") == 0 ) {
        ret_val = cdata1.valB1  <= cdata2.valI2 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "I4") == 0 ) {
      if ( strcmp(op, "==") == 0 ) {
        ret_val = cdata1.valB1  == cdata2.valI4 ;
      }
      else      if ( strcmp(op, "!=") == 0 ) {
        ret_val = cdata1.valB1  != cdata2.valI4 ;
      }
      else      if ( strcmp(op, ">") == 0 ) {
        ret_val = cdata1.valB1  > cdata2.valI4 ;
      }
      else      if ( strcmp(op, "<") == 0 ) {
        ret_val = cdata1.valB1  < cdata2.valI4 ;
      }
      else      if ( strcmp(op, ">=") == 0 ) {
        ret_val = cdata1.valB1  >= cdata2.valI4 ;
      }
      else      if ( strcmp(op, "<=") == 0 ) {
        ret_val = cdata1.valB1  <= cdata2.valI4 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "I8") == 0 ) {
      if ( strcmp(op, "==") == 0 ) {
        ret_val = cdata1.valB1  == cdata2.valI8 ;
      }
      else      if ( strcmp(op, "!=") == 0 ) {
        ret_val = cdata1.valB1  != cdata2.valI8 ;
      }
      else      if ( strcmp(op, ">") == 0 ) {
        ret_val = cdata1.valB1  > cdata2.valI8 ;
      }
      else      if ( strcmp(op, "<") == 0 ) {
        ret_val = cdata1.valB1  < cdata2.valI8 ;
      }
      else      if ( strcmp(op, ">=") == 0 ) {
        ret_val = cdata1.valB1  >= cdata2.valI8 ;
      }
      else      if ( strcmp(op, "<=") == 0 ) {
        ret_val = cdata1.valB1  <= cdata2.valI8 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "F4") == 0 ) {
      if ( strcmp(op, "==") == 0 ) {
        ret_val = cdata1.valB1  == cdata2.valF4 ;
      }
      else      if ( strcmp(op, "!=") == 0 ) {
        ret_val = cdata1.valB1  != cdata2.valF4 ;
      }
      else      if ( strcmp(op, ">") == 0 ) {
        ret_val = cdata1.valB1  > cdata2.valF4 ;
      }
      else      if ( strcmp(op, "<") == 0 ) {
        ret_val = cdata1.valB1  < cdata2.valF4 ;
      }
      else      if ( strcmp(op, ">=") == 0 ) {
        ret_val = cdata1.valB1  >= cdata2.valF4 ;
      }
      else      if ( strcmp(op, "<=") == 0 ) {
        ret_val = cdata1.valB1  <= cdata2.valF4 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "F8") == 0 ) {
      if ( strcmp(op, "==") == 0 ) {
        ret_val = cdata1.valB1  == cdata2.valF8 ;
      }
      else      if ( strcmp(op, "!=") == 0 ) {
        ret_val = cdata1.valB1  != cdata2.valF8 ;
      }
      else      if ( strcmp(op, ">") == 0 ) {
        ret_val = cdata1.valB1  > cdata2.valF8 ;
      }
      else      if ( strcmp(op, "<") == 0 ) {
        ret_val = cdata1.valB1  < cdata2.valF8 ;
      }
      else      if ( strcmp(op, ">=") == 0 ) {
        ret_val = cdata1.valB1  >= cdata2.valF8 ;
      }
      else      if ( strcmp(op, "<=") == 0 ) {
        ret_val = cdata1.valB1  <= cdata2.valF8 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }    else /* LOOP2 */ {
      go_BYE(-1);
    }  }else if ( strcmp(fldtype1, "I1") == 0 ) {
    if ( strcmp(fldtype2, "B1") == 0 ) {
      if ( strcmp(op, "==") == 0 ) {
        ret_val = cdata1.valI1  == cdata2.valB1 ;
      }
      else      if ( strcmp(op, "!=") == 0 ) {
        ret_val = cdata1.valI1  != cdata2.valB1 ;
      }
      else      if ( strcmp(op, ">") == 0 ) {
        ret_val = cdata1.valI1  > cdata2.valB1 ;
      }
      else      if ( strcmp(op, "<") == 0 ) {
        ret_val = cdata1.valI1  < cdata2.valB1 ;
      }
      else      if ( strcmp(op, ">=") == 0 ) {
        ret_val = cdata1.valI1  >= cdata2.valB1 ;
      }
      else      if ( strcmp(op, "<=") == 0 ) {
        ret_val = cdata1.valI1  <= cdata2.valB1 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "I1") == 0 ) {
      if ( strcmp(op, "==") == 0 ) {
        ret_val = cdata1.valI1  == cdata2.valI1 ;
      }
      else      if ( strcmp(op, "!=") == 0 ) {
        ret_val = cdata1.valI1  != cdata2.valI1 ;
      }
      else      if ( strcmp(op, ">") == 0 ) {
        ret_val = cdata1.valI1  > cdata2.valI1 ;
      }
      else      if ( strcmp(op, "<") == 0 ) {
        ret_val = cdata1.valI1  < cdata2.valI1 ;
      }
      else      if ( strcmp(op, ">=") == 0 ) {
        ret_val = cdata1.valI1  >= cdata2.valI1 ;
      }
      else      if ( strcmp(op, "<=") == 0 ) {
        ret_val = cdata1.valI1  <= cdata2.valI1 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "I2") == 0 ) {
      if ( strcmp(op, "==") == 0 ) {
        ret_val = cdata1.valI1  == cdata2.valI2 ;
      }
      else      if ( strcmp(op, "!=") == 0 ) {
        ret_val = cdata1.valI1  != cdata2.valI2 ;
      }
      else      if ( strcmp(op, ">") == 0 ) {
        ret_val = cdata1.valI1  > cdata2.valI2 ;
      }
      else      if ( strcmp(op, "<") == 0 ) {
        ret_val = cdata1.valI1  < cdata2.valI2 ;
      }
      else      if ( strcmp(op, ">=") == 0 ) {
        ret_val = cdata1.valI1  >= cdata2.valI2 ;
      }
      else      if ( strcmp(op, "<=") == 0 ) {
        ret_val = cdata1.valI1  <= cdata2.valI2 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "I4") == 0 ) {
      if ( strcmp(op, "==") == 0 ) {
        ret_val = cdata1.valI1  == cdata2.valI4 ;
      }
      else      if ( strcmp(op, "!=") == 0 ) {
        ret_val = cdata1.valI1  != cdata2.valI4 ;
      }
      else      if ( strcmp(op, ">") == 0 ) {
        ret_val = cdata1.valI1  > cdata2.valI4 ;
      }
      else      if ( strcmp(op, "<") == 0 ) {
        ret_val = cdata1.valI1  < cdata2.valI4 ;
      }
      else      if ( strcmp(op, ">=") == 0 ) {
        ret_val = cdata1.valI1  >= cdata2.valI4 ;
      }
      else      if ( strcmp(op, "<=") == 0 ) {
        ret_val = cdata1.valI1  <= cdata2.valI4 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "I8") == 0 ) {
      if ( strcmp(op, "==") == 0 ) {
        ret_val = cdata1.valI1  == cdata2.valI8 ;
      }
      else      if ( strcmp(op, "!=") == 0 ) {
        ret_val = cdata1.valI1  != cdata2.valI8 ;
      }
      else      if ( strcmp(op, ">") == 0 ) {
        ret_val = cdata1.valI1  > cdata2.valI8 ;
      }
      else      if ( strcmp(op, "<") == 0 ) {
        ret_val = cdata1.valI1  < cdata2.valI8 ;
      }
      else      if ( strcmp(op, ">=") == 0 ) {
        ret_val = cdata1.valI1  >= cdata2.valI8 ;
      }
      else      if ( strcmp(op, "<=") == 0 ) {
        ret_val = cdata1.valI1  <= cdata2.valI8 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "F4") == 0 ) {
      if ( strcmp(op, "==") == 0 ) {
        ret_val = cdata1.valI1  == cdata2.valF4 ;
      }
      else      if ( strcmp(op, "!=") == 0 ) {
        ret_val = cdata1.valI1  != cdata2.valF4 ;
      }
      else      if ( strcmp(op, ">") == 0 ) {
        ret_val = cdata1.valI1  > cdata2.valF4 ;
      }
      else      if ( strcmp(op, "<") == 0 ) {
        ret_val = cdata1.valI1  < cdata2.valF4 ;
      }
      else      if ( strcmp(op, ">=") == 0 ) {
        ret_val = cdata1.valI1  >= cdata2.valF4 ;
      }
      else      if ( strcmp(op, "<=") == 0 ) {
        ret_val = cdata1.valI1  <= cdata2.valF4 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "F8") == 0 ) {
      if ( strcmp(op, "==") == 0 ) {
        ret_val = cdata1.valI1  == cdata2.valF8 ;
      }
      else      if ( strcmp(op, "!=") == 0 ) {
        ret_val = cdata1.valI1  != cdata2.valF8 ;
      }
      else      if ( strcmp(op, ">") == 0 ) {
        ret_val = cdata1.valI1  > cdata2.valF8 ;
      }
      else      if ( strcmp(op, "<") == 0 ) {
        ret_val = cdata1.valI1  < cdata2.valF8 ;
      }
      else      if ( strcmp(op, ">=") == 0 ) {
        ret_val = cdata1.valI1  >= cdata2.valF8 ;
      }
      else      if ( strcmp(op, "<=") == 0 ) {
        ret_val = cdata1.valI1  <= cdata2.valF8 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }    else /* LOOP2 */ {
      go_BYE(-1);
    }  }else if ( strcmp(fldtype1, "I2") == 0 ) {
    if ( strcmp(fldtype2, "B1") == 0 ) {
      if ( strcmp(op, "==") == 0 ) {
        ret_val = cdata1.valI2  == cdata2.valB1 ;
      }
      else      if ( strcmp(op, "!=") == 0 ) {
        ret_val = cdata1.valI2  != cdata2.valB1 ;
      }
      else      if ( strcmp(op, ">") == 0 ) {
        ret_val = cdata1.valI2  > cdata2.valB1 ;
      }
      else      if ( strcmp(op, "<") == 0 ) {
        ret_val = cdata1.valI2  < cdata2.valB1 ;
      }
      else      if ( strcmp(op, ">=") == 0 ) {
        ret_val = cdata1.valI2  >= cdata2.valB1 ;
      }
      else      if ( strcmp(op, "<=") == 0 ) {
        ret_val = cdata1.valI2  <= cdata2.valB1 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "I1") == 0 ) {
      if ( strcmp(op, "==") == 0 ) {
        ret_val = cdata1.valI2  == cdata2.valI1 ;
      }
      else      if ( strcmp(op, "!=") == 0 ) {
        ret_val = cdata1.valI2  != cdata2.valI1 ;
      }
      else      if ( strcmp(op, ">") == 0 ) {
        ret_val = cdata1.valI2  > cdata2.valI1 ;
      }
      else      if ( strcmp(op, "<") == 0 ) {
        ret_val = cdata1.valI2  < cdata2.valI1 ;
      }
      else      if ( strcmp(op, ">=") == 0 ) {
        ret_val = cdata1.valI2  >= cdata2.valI1 ;
      }
      else      if ( strcmp(op, "<=") == 0 ) {
        ret_val = cdata1.valI2  <= cdata2.valI1 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "I2") == 0 ) {
      if ( strcmp(op, "==") == 0 ) {
        ret_val = cdata1.valI2  == cdata2.valI2 ;
      }
      else      if ( strcmp(op, "!=") == 0 ) {
        ret_val = cdata1.valI2  != cdata2.valI2 ;
      }
      else      if ( strcmp(op, ">") == 0 ) {
        ret_val = cdata1.valI2  > cdata2.valI2 ;
      }
      else      if ( strcmp(op, "<") == 0 ) {
        ret_val = cdata1.valI2  < cdata2.valI2 ;
      }
      else      if ( strcmp(op, ">=") == 0 ) {
        ret_val = cdata1.valI2  >= cdata2.valI2 ;
      }
      else      if ( strcmp(op, "<=") == 0 ) {
        ret_val = cdata1.valI2  <= cdata2.valI2 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "I4") == 0 ) {
      if ( strcmp(op, "==") == 0 ) {
        ret_val = cdata1.valI2  == cdata2.valI4 ;
      }
      else      if ( strcmp(op, "!=") == 0 ) {
        ret_val = cdata1.valI2  != cdata2.valI4 ;
      }
      else      if ( strcmp(op, ">") == 0 ) {
        ret_val = cdata1.valI2  > cdata2.valI4 ;
      }
      else      if ( strcmp(op, "<") == 0 ) {
        ret_val = cdata1.valI2  < cdata2.valI4 ;
      }
      else      if ( strcmp(op, ">=") == 0 ) {
        ret_val = cdata1.valI2  >= cdata2.valI4 ;
      }
      else      if ( strcmp(op, "<=") == 0 ) {
        ret_val = cdata1.valI2  <= cdata2.valI4 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "I8") == 0 ) {
      if ( strcmp(op, "==") == 0 ) {
        ret_val = cdata1.valI2  == cdata2.valI8 ;
      }
      else      if ( strcmp(op, "!=") == 0 ) {
        ret_val = cdata1.valI2  != cdata2.valI8 ;
      }
      else      if ( strcmp(op, ">") == 0 ) {
        ret_val = cdata1.valI2  > cdata2.valI8 ;
      }
      else      if ( strcmp(op, "<") == 0 ) {
        ret_val = cdata1.valI2  < cdata2.valI8 ;
      }
      else      if ( strcmp(op, ">=") == 0 ) {
        ret_val = cdata1.valI2  >= cdata2.valI8 ;
      }
      else      if ( strcmp(op, "<=") == 0 ) {
        ret_val = cdata1.valI2  <= cdata2.valI8 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "F4") == 0 ) {
      if ( strcmp(op, "==") == 0 ) {
        ret_val = cdata1.valI2  == cdata2.valF4 ;
      }
      else      if ( strcmp(op, "!=") == 0 ) {
        ret_val = cdata1.valI2  != cdata2.valF4 ;
      }
      else      if ( strcmp(op, ">") == 0 ) {
        ret_val = cdata1.valI2  > cdata2.valF4 ;
      }
      else      if ( strcmp(op, "<") == 0 ) {
        ret_val = cdata1.valI2  < cdata2.valF4 ;
      }
      else      if ( strcmp(op, ">=") == 0 ) {
        ret_val = cdata1.valI2  >= cdata2.valF4 ;
      }
      else      if ( strcmp(op, "<=") == 0 ) {
        ret_val = cdata1.valI2  <= cdata2.valF4 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "F8") == 0 ) {
      if ( strcmp(op, "==") == 0 ) {
        ret_val = cdata1.valI2  == cdata2.valF8 ;
      }
      else      if ( strcmp(op, "!=") == 0 ) {
        ret_val = cdata1.valI2  != cdata2.valF8 ;
      }
      else      if ( strcmp(op, ">") == 0 ) {
        ret_val = cdata1.valI2  > cdata2.valF8 ;
      }
      else      if ( strcmp(op, "<") == 0 ) {
        ret_val = cdata1.valI2  < cdata2.valF8 ;
      }
      else      if ( strcmp(op, ">=") == 0 ) {
        ret_val = cdata1.valI2  >= cdata2.valF8 ;
      }
      else      if ( strcmp(op, "<=") == 0 ) {
        ret_val = cdata1.valI2  <= cdata2.valF8 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }    else /* LOOP2 */ {
      go_BYE(-1);
    }  }else if ( strcmp(fldtype1, "I4") == 0 ) {
    if ( strcmp(fldtype2, "B1") == 0 ) {
      if ( strcmp(op, "==") == 0 ) {
        ret_val = cdata1.valI4  == cdata2.valB1 ;
      }
      else      if ( strcmp(op, "!=") == 0 ) {
        ret_val = cdata1.valI4  != cdata2.valB1 ;
      }
      else      if ( strcmp(op, ">") == 0 ) {
        ret_val = cdata1.valI4  > cdata2.valB1 ;
      }
      else      if ( strcmp(op, "<") == 0 ) {
        ret_val = cdata1.valI4  < cdata2.valB1 ;
      }
      else      if ( strcmp(op, ">=") == 0 ) {
        ret_val = cdata1.valI4  >= cdata2.valB1 ;
      }
      else      if ( strcmp(op, "<=") == 0 ) {
        ret_val = cdata1.valI4  <= cdata2.valB1 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "I1") == 0 ) {
      if ( strcmp(op, "==") == 0 ) {
        ret_val = cdata1.valI4  == cdata2.valI1 ;
      }
      else      if ( strcmp(op, "!=") == 0 ) {
        ret_val = cdata1.valI4  != cdata2.valI1 ;
      }
      else      if ( strcmp(op, ">") == 0 ) {
        ret_val = cdata1.valI4  > cdata2.valI1 ;
      }
      else      if ( strcmp(op, "<") == 0 ) {
        ret_val = cdata1.valI4  < cdata2.valI1 ;
      }
      else      if ( strcmp(op, ">=") == 0 ) {
        ret_val = cdata1.valI4  >= cdata2.valI1 ;
      }
      else      if ( strcmp(op, "<=") == 0 ) {
        ret_val = cdata1.valI4  <= cdata2.valI1 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "I2") == 0 ) {
      if ( strcmp(op, "==") == 0 ) {
        ret_val = cdata1.valI4  == cdata2.valI2 ;
      }
      else      if ( strcmp(op, "!=") == 0 ) {
        ret_val = cdata1.valI4  != cdata2.valI2 ;
      }
      else      if ( strcmp(op, ">") == 0 ) {
        ret_val = cdata1.valI4  > cdata2.valI2 ;
      }
      else      if ( strcmp(op, "<") == 0 ) {
        ret_val = cdata1.valI4  < cdata2.valI2 ;
      }
      else      if ( strcmp(op, ">=") == 0 ) {
        ret_val = cdata1.valI4  >= cdata2.valI2 ;
      }
      else      if ( strcmp(op, "<=") == 0 ) {
        ret_val = cdata1.valI4  <= cdata2.valI2 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "I4") == 0 ) {
      if ( strcmp(op, "==") == 0 ) {
        ret_val = cdata1.valI4  == cdata2.valI4 ;
      }
      else      if ( strcmp(op, "!=") == 0 ) {
        ret_val = cdata1.valI4  != cdata2.valI4 ;
      }
      else      if ( strcmp(op, ">") == 0 ) {
        ret_val = cdata1.valI4  > cdata2.valI4 ;
      }
      else      if ( strcmp(op, "<") == 0 ) {
        ret_val = cdata1.valI4  < cdata2.valI4 ;
      }
      else      if ( strcmp(op, ">=") == 0 ) {
        ret_val = cdata1.valI4  >= cdata2.valI4 ;
      }
      else      if ( strcmp(op, "<=") == 0 ) {
        ret_val = cdata1.valI4  <= cdata2.valI4 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "I8") == 0 ) {
      if ( strcmp(op, "==") == 0 ) {
        ret_val = cdata1.valI4  == cdata2.valI8 ;
      }
      else      if ( strcmp(op, "!=") == 0 ) {
        ret_val = cdata1.valI4  != cdata2.valI8 ;
      }
      else      if ( strcmp(op, ">") == 0 ) {
        ret_val = cdata1.valI4  > cdata2.valI8 ;
      }
      else      if ( strcmp(op, "<") == 0 ) {
        ret_val = cdata1.valI4  < cdata2.valI8 ;
      }
      else      if ( strcmp(op, ">=") == 0 ) {
        ret_val = cdata1.valI4  >= cdata2.valI8 ;
      }
      else      if ( strcmp(op, "<=") == 0 ) {
        ret_val = cdata1.valI4  <= cdata2.valI8 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "F4") == 0 ) {
      if ( strcmp(op, "==") == 0 ) {
        ret_val = cdata1.valI4  == cdata2.valF4 ;
      }
      else      if ( strcmp(op, "!=") == 0 ) {
        ret_val = cdata1.valI4  != cdata2.valF4 ;
      }
      else      if ( strcmp(op, ">") == 0 ) {
        ret_val = cdata1.valI4  > cdata2.valF4 ;
      }
      else      if ( strcmp(op, "<") == 0 ) {
        ret_val = cdata1.valI4  < cdata2.valF4 ;
      }
      else      if ( strcmp(op, ">=") == 0 ) {
        ret_val = cdata1.valI4  >= cdata2.valF4 ;
      }
      else      if ( strcmp(op, "<=") == 0 ) {
        ret_val = cdata1.valI4  <= cdata2.valF4 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "F8") == 0 ) {
      if ( strcmp(op, "==") == 0 ) {
        ret_val = cdata1.valI4  == cdata2.valF8 ;
      }
      else      if ( strcmp(op, "!=") == 0 ) {
        ret_val = cdata1.valI4  != cdata2.valF8 ;
      }
      else      if ( strcmp(op, ">") == 0 ) {
        ret_val = cdata1.valI4  > cdata2.valF8 ;
      }
      else      if ( strcmp(op, "<") == 0 ) {
        ret_val = cdata1.valI4  < cdata2.valF8 ;
      }
      else      if ( strcmp(op, ">=") == 0 ) {
        ret_val = cdata1.valI4  >= cdata2.valF8 ;
      }
      else      if ( strcmp(op, "<=") == 0 ) {
        ret_val = cdata1.valI4  <= cdata2.valF8 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }    else /* LOOP2 */ {
      go_BYE(-1);
    }  }else if ( strcmp(fldtype1, "I8") == 0 ) {
    if ( strcmp(fldtype2, "B1") == 0 ) {
      if ( strcmp(op, "==") == 0 ) {
        ret_val = cdata1.valI8  == cdata2.valB1 ;
      }
      else      if ( strcmp(op, "!=") == 0 ) {
        ret_val = cdata1.valI8  != cdata2.valB1 ;
      }
      else      if ( strcmp(op, ">") == 0 ) {
        ret_val = cdata1.valI8  > cdata2.valB1 ;
      }
      else      if ( strcmp(op, "<") == 0 ) {
        ret_val = cdata1.valI8  < cdata2.valB1 ;
      }
      else      if ( strcmp(op, ">=") == 0 ) {
        ret_val = cdata1.valI8  >= cdata2.valB1 ;
      }
      else      if ( strcmp(op, "<=") == 0 ) {
        ret_val = cdata1.valI8  <= cdata2.valB1 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "I1") == 0 ) {
      if ( strcmp(op, "==") == 0 ) {
        ret_val = cdata1.valI8  == cdata2.valI1 ;
      }
      else      if ( strcmp(op, "!=") == 0 ) {
        ret_val = cdata1.valI8  != cdata2.valI1 ;
      }
      else      if ( strcmp(op, ">") == 0 ) {
        ret_val = cdata1.valI8  > cdata2.valI1 ;
      }
      else      if ( strcmp(op, "<") == 0 ) {
        ret_val = cdata1.valI8  < cdata2.valI1 ;
      }
      else      if ( strcmp(op, ">=") == 0 ) {
        ret_val = cdata1.valI8  >= cdata2.valI1 ;
      }
      else      if ( strcmp(op, "<=") == 0 ) {
        ret_val = cdata1.valI8  <= cdata2.valI1 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "I2") == 0 ) {
      if ( strcmp(op, "==") == 0 ) {
        ret_val = cdata1.valI8  == cdata2.valI2 ;
      }
      else      if ( strcmp(op, "!=") == 0 ) {
        ret_val = cdata1.valI8  != cdata2.valI2 ;
      }
      else      if ( strcmp(op, ">") == 0 ) {
        ret_val = cdata1.valI8  > cdata2.valI2 ;
      }
      else      if ( strcmp(op, "<") == 0 ) {
        ret_val = cdata1.valI8  < cdata2.valI2 ;
      }
      else      if ( strcmp(op, ">=") == 0 ) {
        ret_val = cdata1.valI8  >= cdata2.valI2 ;
      }
      else      if ( strcmp(op, "<=") == 0 ) {
        ret_val = cdata1.valI8  <= cdata2.valI2 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "I4") == 0 ) {
      if ( strcmp(op, "==") == 0 ) {
        ret_val = cdata1.valI8  == cdata2.valI4 ;
      }
      else      if ( strcmp(op, "!=") == 0 ) {
        ret_val = cdata1.valI8  != cdata2.valI4 ;
      }
      else      if ( strcmp(op, ">") == 0 ) {
        ret_val = cdata1.valI8  > cdata2.valI4 ;
      }
      else      if ( strcmp(op, "<") == 0 ) {
        ret_val = cdata1.valI8  < cdata2.valI4 ;
      }
      else      if ( strcmp(op, ">=") == 0 ) {
        ret_val = cdata1.valI8  >= cdata2.valI4 ;
      }
      else      if ( strcmp(op, "<=") == 0 ) {
        ret_val = cdata1.valI8  <= cdata2.valI4 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "I8") == 0 ) {
      if ( strcmp(op, "==") == 0 ) {
        ret_val = cdata1.valI8  == cdata2.valI8 ;
      }
      else      if ( strcmp(op, "!=") == 0 ) {
        ret_val = cdata1.valI8  != cdata2.valI8 ;
      }
      else      if ( strcmp(op, ">") == 0 ) {
        ret_val = cdata1.valI8  > cdata2.valI8 ;
      }
      else      if ( strcmp(op, "<") == 0 ) {
        ret_val = cdata1.valI8  < cdata2.valI8 ;
      }
      else      if ( strcmp(op, ">=") == 0 ) {
        ret_val = cdata1.valI8  >= cdata2.valI8 ;
      }
      else      if ( strcmp(op, "<=") == 0 ) {
        ret_val = cdata1.valI8  <= cdata2.valI8 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "F4") == 0 ) {
      if ( strcmp(op, "==") == 0 ) {
        ret_val = cdata1.valI8  == cdata2.valF4 ;
      }
      else      if ( strcmp(op, "!=") == 0 ) {
        ret_val = cdata1.valI8  != cdata2.valF4 ;
      }
      else      if ( strcmp(op, ">") == 0 ) {
        ret_val = cdata1.valI8  > cdata2.valF4 ;
      }
      else      if ( strcmp(op, "<") == 0 ) {
        ret_val = cdata1.valI8  < cdata2.valF4 ;
      }
      else      if ( strcmp(op, ">=") == 0 ) {
        ret_val = cdata1.valI8  >= cdata2.valF4 ;
      }
      else      if ( strcmp(op, "<=") == 0 ) {
        ret_val = cdata1.valI8  <= cdata2.valF4 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "F8") == 0 ) {
      if ( strcmp(op, "==") == 0 ) {
        ret_val = cdata1.valI8  == cdata2.valF8 ;
      }
      else      if ( strcmp(op, "!=") == 0 ) {
        ret_val = cdata1.valI8  != cdata2.valF8 ;
      }
      else      if ( strcmp(op, ">") == 0 ) {
        ret_val = cdata1.valI8  > cdata2.valF8 ;
      }
      else      if ( strcmp(op, "<") == 0 ) {
        ret_val = cdata1.valI8  < cdata2.valF8 ;
      }
      else      if ( strcmp(op, ">=") == 0 ) {
        ret_val = cdata1.valI8  >= cdata2.valF8 ;
      }
      else      if ( strcmp(op, "<=") == 0 ) {
        ret_val = cdata1.valI8  <= cdata2.valF8 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }    else /* LOOP2 */ {
      go_BYE(-1);
    }  }else if ( strcmp(fldtype1, "F4") == 0 ) {
    if ( strcmp(fldtype2, "B1") == 0 ) {
      if ( strcmp(op, "==") == 0 ) {
        ret_val = cdata1.valF4  == cdata2.valB1 ;
      }
      else      if ( strcmp(op, "!=") == 0 ) {
        ret_val = cdata1.valF4  != cdata2.valB1 ;
      }
      else      if ( strcmp(op, ">") == 0 ) {
        ret_val = cdata1.valF4  > cdata2.valB1 ;
      }
      else      if ( strcmp(op, "<") == 0 ) {
        ret_val = cdata1.valF4  < cdata2.valB1 ;
      }
      else      if ( strcmp(op, ">=") == 0 ) {
        ret_val = cdata1.valF4  >= cdata2.valB1 ;
      }
      else      if ( strcmp(op, "<=") == 0 ) {
        ret_val = cdata1.valF4  <= cdata2.valB1 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "I1") == 0 ) {
      if ( strcmp(op, "==") == 0 ) {
        ret_val = cdata1.valF4  == cdata2.valI1 ;
      }
      else      if ( strcmp(op, "!=") == 0 ) {
        ret_val = cdata1.valF4  != cdata2.valI1 ;
      }
      else      if ( strcmp(op, ">") == 0 ) {
        ret_val = cdata1.valF4  > cdata2.valI1 ;
      }
      else      if ( strcmp(op, "<") == 0 ) {
        ret_val = cdata1.valF4  < cdata2.valI1 ;
      }
      else      if ( strcmp(op, ">=") == 0 ) {
        ret_val = cdata1.valF4  >= cdata2.valI1 ;
      }
      else      if ( strcmp(op, "<=") == 0 ) {
        ret_val = cdata1.valF4  <= cdata2.valI1 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "I2") == 0 ) {
      if ( strcmp(op, "==") == 0 ) {
        ret_val = cdata1.valF4  == cdata2.valI2 ;
      }
      else      if ( strcmp(op, "!=") == 0 ) {
        ret_val = cdata1.valF4  != cdata2.valI2 ;
      }
      else      if ( strcmp(op, ">") == 0 ) {
        ret_val = cdata1.valF4  > cdata2.valI2 ;
      }
      else      if ( strcmp(op, "<") == 0 ) {
        ret_val = cdata1.valF4  < cdata2.valI2 ;
      }
      else      if ( strcmp(op, ">=") == 0 ) {
        ret_val = cdata1.valF4  >= cdata2.valI2 ;
      }
      else      if ( strcmp(op, "<=") == 0 ) {
        ret_val = cdata1.valF4  <= cdata2.valI2 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "I4") == 0 ) {
      if ( strcmp(op, "==") == 0 ) {
        ret_val = cdata1.valF4  == cdata2.valI4 ;
      }
      else      if ( strcmp(op, "!=") == 0 ) {
        ret_val = cdata1.valF4  != cdata2.valI4 ;
      }
      else      if ( strcmp(op, ">") == 0 ) {
        ret_val = cdata1.valF4  > cdata2.valI4 ;
      }
      else      if ( strcmp(op, "<") == 0 ) {
        ret_val = cdata1.valF4  < cdata2.valI4 ;
      }
      else      if ( strcmp(op, ">=") == 0 ) {
        ret_val = cdata1.valF4  >= cdata2.valI4 ;
      }
      else      if ( strcmp(op, "<=") == 0 ) {
        ret_val = cdata1.valF4  <= cdata2.valI4 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "I8") == 0 ) {
      if ( strcmp(op, "==") == 0 ) {
        ret_val = cdata1.valF4  == cdata2.valI8 ;
      }
      else      if ( strcmp(op, "!=") == 0 ) {
        ret_val = cdata1.valF4  != cdata2.valI8 ;
      }
      else      if ( strcmp(op, ">") == 0 ) {
        ret_val = cdata1.valF4  > cdata2.valI8 ;
      }
      else      if ( strcmp(op, "<") == 0 ) {
        ret_val = cdata1.valF4  < cdata2.valI8 ;
      }
      else      if ( strcmp(op, ">=") == 0 ) {
        ret_val = cdata1.valF4  >= cdata2.valI8 ;
      }
      else      if ( strcmp(op, "<=") == 0 ) {
        ret_val = cdata1.valF4  <= cdata2.valI8 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "F4") == 0 ) {
      if ( strcmp(op, "==") == 0 ) {
        ret_val = cdata1.valF4  == cdata2.valF4 ;
      }
      else      if ( strcmp(op, "!=") == 0 ) {
        ret_val = cdata1.valF4  != cdata2.valF4 ;
      }
      else      if ( strcmp(op, ">") == 0 ) {
        ret_val = cdata1.valF4  > cdata2.valF4 ;
      }
      else      if ( strcmp(op, "<") == 0 ) {
        ret_val = cdata1.valF4  < cdata2.valF4 ;
      }
      else      if ( strcmp(op, ">=") == 0 ) {
        ret_val = cdata1.valF4  >= cdata2.valF4 ;
      }
      else      if ( strcmp(op, "<=") == 0 ) {
        ret_val = cdata1.valF4  <= cdata2.valF4 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "F8") == 0 ) {
      if ( strcmp(op, "==") == 0 ) {
        ret_val = cdata1.valF4  == cdata2.valF8 ;
      }
      else      if ( strcmp(op, "!=") == 0 ) {
        ret_val = cdata1.valF4  != cdata2.valF8 ;
      }
      else      if ( strcmp(op, ">") == 0 ) {
        ret_val = cdata1.valF4  > cdata2.valF8 ;
      }
      else      if ( strcmp(op, "<") == 0 ) {
        ret_val = cdata1.valF4  < cdata2.valF8 ;
      }
      else      if ( strcmp(op, ">=") == 0 ) {
        ret_val = cdata1.valF4  >= cdata2.valF8 ;
      }
      else      if ( strcmp(op, "<=") == 0 ) {
        ret_val = cdata1.valF4  <= cdata2.valF8 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }    else /* LOOP2 */ {
      go_BYE(-1);
    }  }else if ( strcmp(fldtype1, "F8") == 0 ) {
    if ( strcmp(fldtype2, "B1") == 0 ) {
      if ( strcmp(op, "==") == 0 ) {
        ret_val = cdata1.valF8  == cdata2.valB1 ;
      }
      else      if ( strcmp(op, "!=") == 0 ) {
        ret_val = cdata1.valF8  != cdata2.valB1 ;
      }
      else      if ( strcmp(op, ">") == 0 ) {
        ret_val = cdata1.valF8  > cdata2.valB1 ;
      }
      else      if ( strcmp(op, "<") == 0 ) {
        ret_val = cdata1.valF8  < cdata2.valB1 ;
      }
      else      if ( strcmp(op, ">=") == 0 ) {
        ret_val = cdata1.valF8  >= cdata2.valB1 ;
      }
      else      if ( strcmp(op, "<=") == 0 ) {
        ret_val = cdata1.valF8  <= cdata2.valB1 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "I1") == 0 ) {
      if ( strcmp(op, "==") == 0 ) {
        ret_val = cdata1.valF8  == cdata2.valI1 ;
      }
      else      if ( strcmp(op, "!=") == 0 ) {
        ret_val = cdata1.valF8  != cdata2.valI1 ;
      }
      else      if ( strcmp(op, ">") == 0 ) {
        ret_val = cdata1.valF8  > cdata2.valI1 ;
      }
      else      if ( strcmp(op, "<") == 0 ) {
        ret_val = cdata1.valF8  < cdata2.valI1 ;
      }
      else      if ( strcmp(op, ">=") == 0 ) {
        ret_val = cdata1.valF8  >= cdata2.valI1 ;
      }
      else      if ( strcmp(op, "<=") == 0 ) {
        ret_val = cdata1.valF8  <= cdata2.valI1 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "I2") == 0 ) {
      if ( strcmp(op, "==") == 0 ) {
        ret_val = cdata1.valF8  == cdata2.valI2 ;
      }
      else      if ( strcmp(op, "!=") == 0 ) {
        ret_val = cdata1.valF8  != cdata2.valI2 ;
      }
      else      if ( strcmp(op, ">") == 0 ) {
        ret_val = cdata1.valF8  > cdata2.valI2 ;
      }
      else      if ( strcmp(op, "<") == 0 ) {
        ret_val = cdata1.valF8  < cdata2.valI2 ;
      }
      else      if ( strcmp(op, ">=") == 0 ) {
        ret_val = cdata1.valF8  >= cdata2.valI2 ;
      }
      else      if ( strcmp(op, "<=") == 0 ) {
        ret_val = cdata1.valF8  <= cdata2.valI2 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "I4") == 0 ) {
      if ( strcmp(op, "==") == 0 ) {
        ret_val = cdata1.valF8  == cdata2.valI4 ;
      }
      else      if ( strcmp(op, "!=") == 0 ) {
        ret_val = cdata1.valF8  != cdata2.valI4 ;
      }
      else      if ( strcmp(op, ">") == 0 ) {
        ret_val = cdata1.valF8  > cdata2.valI4 ;
      }
      else      if ( strcmp(op, "<") == 0 ) {
        ret_val = cdata1.valF8  < cdata2.valI4 ;
      }
      else      if ( strcmp(op, ">=") == 0 ) {
        ret_val = cdata1.valF8  >= cdata2.valI4 ;
      }
      else      if ( strcmp(op, "<=") == 0 ) {
        ret_val = cdata1.valF8  <= cdata2.valI4 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "I8") == 0 ) {
      if ( strcmp(op, "==") == 0 ) {
        ret_val = cdata1.valF8  == cdata2.valI8 ;
      }
      else      if ( strcmp(op, "!=") == 0 ) {
        ret_val = cdata1.valF8  != cdata2.valI8 ;
      }
      else      if ( strcmp(op, ">") == 0 ) {
        ret_val = cdata1.valF8  > cdata2.valI8 ;
      }
      else      if ( strcmp(op, "<") == 0 ) {
        ret_val = cdata1.valF8  < cdata2.valI8 ;
      }
      else      if ( strcmp(op, ">=") == 0 ) {
        ret_val = cdata1.valF8  >= cdata2.valI8 ;
      }
      else      if ( strcmp(op, "<=") == 0 ) {
        ret_val = cdata1.valF8  <= cdata2.valI8 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "F4") == 0 ) {
      if ( strcmp(op, "==") == 0 ) {
        ret_val = cdata1.valF8  == cdata2.valF4 ;
      }
      else      if ( strcmp(op, "!=") == 0 ) {
        ret_val = cdata1.valF8  != cdata2.valF4 ;
      }
      else      if ( strcmp(op, ">") == 0 ) {
        ret_val = cdata1.valF8  > cdata2.valF4 ;
      }
      else      if ( strcmp(op, "<") == 0 ) {
        ret_val = cdata1.valF8  < cdata2.valF4 ;
      }
      else      if ( strcmp(op, ">=") == 0 ) {
        ret_val = cdata1.valF8  >= cdata2.valF4 ;
      }
      else      if ( strcmp(op, "<=") == 0 ) {
        ret_val = cdata1.valF8  <= cdata2.valF4 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }
    else if ( strcmp(fldtype2, "F8") == 0 ) {
      if ( strcmp(op, "==") == 0 ) {
        ret_val = cdata1.valF8  == cdata2.valF8 ;
      }
      else      if ( strcmp(op, "!=") == 0 ) {
        ret_val = cdata1.valF8  != cdata2.valF8 ;
      }
      else      if ( strcmp(op, ">") == 0 ) {
        ret_val = cdata1.valF8  > cdata2.valF8 ;
      }
      else      if ( strcmp(op, "<") == 0 ) {
        ret_val = cdata1.valF8  < cdata2.valF8 ;
      }
      else      if ( strcmp(op, ">=") == 0 ) {
        ret_val = cdata1.valF8  >= cdata2.valF8 ;
      }
      else      if ( strcmp(op, "<=") == 0 ) {
        ret_val = cdata1.valF8  <= cdata2.valF8 ;
      }
      else /* LOOP 3 */{
        go_BYE(-1);
      }
    }    else /* LOOP2 */ {
      go_BYE(-1);
    }  }  else /* LOOP 1 */{
    go_BYE(-1);
  }   *ptr_ret_val = ret_val;
BYE:
  return status;
}
