#include "lauxlib.h"
#include "lua.h"
#include "luaconf.h"
#include "lualib.h"
#include "q_incs.h"
#include "qtypes.h"
#include "sclr_struct.h"
static int l_sclr_eq(lua_State *L)
{
  int status = 0;
  bool bval = false;
  int num_args = lua_gettop(L); if ( num_args != 2 )  { go_BYE(-1); }

  SCLR_REC_TYPE *s1 = (SCLR_REC_TYPE *)luaL_checkudata(L, 1, "Scalar");
  SCLR_REC_TYPE *s2 = (SCLR_REC_TYPE *)luaL_checkudata(L, 2, "Scalar");
  qtype_t qtype1 = s1->qtype;
  qtype_t qtype2 = s2->qtype;
  if ( ( qtype1 == SC ) || ( qtype1 == TM ) || ( qtype1 == TM1 ) ) {
    // exact type match needed
    if ( qtype1 != qtype2 ) { goto BYE; }
  }
  // handle non number types first 
  if ( qtype1 == SC ) {
    char *str1 = s1->val.str;
    char *str2 = s2->val.str;
    if ( str1 == NULL ) { go_BYE(-1); }
    if ( str2 == NULL ) { go_BYE(-1); }
    if ( strcmp(str1, str2) == 0 ) { bval = true; } 
    lua_pushboolean(L, bval);
    return 1; 
  }
  if ( qtype1 == TM1 ) {
    printf("TODO \n"); goto BYE;
  }
  if ( qtype1 == TM ) {
    printf("TODO \n"); goto BYE;
  }
  // now handle number types 
  switch ( qtype1 ) {
    case BL : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.bl  == s2->val.bl ) { bval = true; } break;
        case I1 : if ( s1->val.bl  == s2->val.i1 ) { bval = true; }  break; 
        case I2 : if ( s1->val.bl  == s2->val.i2 ) { bval = true; }  break; 
        case I4 : if ( s1->val.bl  == s2->val.i4 ) { bval = true; }  break; 
        case I8 : if ( s1->val.bl  == s2->val.i8 ) { bval = true; }  break; 
        case UI1 : if ( s1->val.bl  == s2->val.ui1 ) { bval = true; } break;
        case UI2 : if ( s1->val.bl  == s2->val.ui2 ) { bval = true; } break;
        case UI4 : if ( s1->val.bl  == s2->val.ui4 ) { bval = true; } break;
        case UI8 : if ( s1->val.bl  == s2->val.ui8 ) { bval = true; } break;
        case F4 : if ( s1->val.bl  == s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.bl  == s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    case I1 : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.i1  == s2->val.bl ) { bval = true; } break;
        case I1 : if ( s1->val.i1  == s2->val.i1 ) { bval = true; }  break; 
        case I2 : if ( s1->val.i1  == s2->val.i2 ) { bval = true; }  break; 
        case I4 : if ( s1->val.i1  == s2->val.i4 ) { bval = true; }  break; 
        case I8 : if ( s1->val.i1  == s2->val.i8 ) { bval = true; }  break; 
        case UI1 : if ( ( s1->val.i1 >= 0 ) && 
                   ( s1->val.i1  == s2->val.ui1 ) ) { bval = true; } break; 
        case UI2 : if ( ( s1->val.i1 >= 0 ) && 
                   ( s1->val.i1  == s2->val.ui2 ) ) { bval = true; } break; 
        case UI4 : if ( ( s1->val.i1 >= 0 ) && 
                   ( s1->val.i1  == s2->val.ui4 ) ) { bval = true; } break; 
        case UI8 : if ( ( s1->val.i1 >= 0 ) && 
                   ( s1->val.i1  == s2->val.ui8 ) ) { bval = true; } break; 
        case F4 : if ( s1->val.i1  == s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.i1  == s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    case I2 : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.i2  == s2->val.bl ) { bval = true; } break;
        case I1 : if ( s1->val.i2  == s2->val.i1 ) { bval = true; }  break; 
        case I2 : if ( s1->val.i2  == s2->val.i2 ) { bval = true; }  break; 
        case I4 : if ( s1->val.i2  == s2->val.i4 ) { bval = true; }  break; 
        case I8 : if ( s1->val.i2  == s2->val.i8 ) { bval = true; }  break; 
        case UI1 : if ( ( s1->val.i2 >= 0 ) && 
                   ( s1->val.i2  == s2->val.ui1 ) ) { bval = true; } break; 
        case UI2 : if ( ( s1->val.i2 >= 0 ) && 
                   ( s1->val.i2  == s2->val.ui2 ) ) { bval = true; } break; 
        case UI4 : if ( ( s1->val.i2 >= 0 ) && 
                   ( s1->val.i2  == s2->val.ui4 ) ) { bval = true; } break; 
        case UI8 : if ( ( s1->val.i2 >= 0 ) && 
                   ( s1->val.i2  == s2->val.ui8 ) ) { bval = true; } break; 
        case F4 : if ( s1->val.i2  == s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.i2  == s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    case I4 : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.i4  == s2->val.bl ) { bval = true; } break;
        case I1 : if ( s1->val.i4  == s2->val.i1 ) { bval = true; }  break; 
        case I2 : if ( s1->val.i4  == s2->val.i2 ) { bval = true; }  break; 
        case I4 : if ( s1->val.i4  == s2->val.i4 ) { bval = true; }  break; 
        case I8 : if ( s1->val.i4  == s2->val.i8 ) { bval = true; }  break; 
        case UI1 : if ( ( s1->val.i4 >= 0 ) && 
                   ( s1->val.i4  == s2->val.ui1 ) ) { bval = true; } break; 
        case UI2 : if ( ( s1->val.i4 >= 0 ) && 
                   ( s1->val.i4  == s2->val.ui2 ) ) { bval = true; } break; 
        case UI4 : if ( ( s1->val.i4 >= 0 ) && 
                   ( s1->val.i4  == s2->val.ui4 ) ) { bval = true; } break; 
        case UI8 : if ( ( s1->val.i4 >= 0 ) && 
                   ( s1->val.i4  == s2->val.ui8 ) ) { bval = true; } break; 
        case F4 : if ( s1->val.i4  == s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.i4  == s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    case I8 : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.i8  == s2->val.bl ) { bval = true; } break;
        case I1 : if ( s1->val.i8  == s2->val.i1 ) { bval = true; }  break; 
        case I2 : if ( s1->val.i8  == s2->val.i2 ) { bval = true; }  break; 
        case I4 : if ( s1->val.i8  == s2->val.i4 ) { bval = true; }  break; 
        case I8 : if ( s1->val.i8  == s2->val.i8 ) { bval = true; }  break; 
        case UI1 : if ( ( s1->val.i8 >= 0 ) && 
                   ( s1->val.i8  == s2->val.ui1 ) ) { bval = true; } break; 
        case UI2 : if ( ( s1->val.i8 >= 0 ) && 
                   ( s1->val.i8  == s2->val.ui2 ) ) { bval = true; } break; 
        case UI4 : if ( ( s1->val.i8 >= 0 ) && 
                   ( s1->val.i8  == s2->val.ui4 ) ) { bval = true; } break; 
        case UI8 : if ( ( s1->val.i8 >= 0 ) && 
                   ( s1->val.i8  == s2->val.ui8 ) ) { bval = true; } break; 
        case F4 : if ( s1->val.i8  == s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.i8  == s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    case UI1 : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.ui1  == s2->val.bl ) { bval = true; } break;
        case I1 : if ( ( s2->val.i1 >= 0 ) && ( s1->val.ui1  == s2->val.i1 ) ) { bval = true; }  break;
        case I2 : if ( ( s2->val.i1 >= 0 ) && ( s1->val.ui1  == s2->val.i2 ) ) { bval = true; }  break;
        case I4 : if ( ( s2->val.i1 >= 0 ) && ( s1->val.ui1  == s2->val.i4 ) ) { bval = true; }  break;
        case I8 : if ( ( s2->val.i1 >= 0 ) && ( s1->val.ui1  == s2->val.i8 ) ) { bval = true; }  break;
        case UI1 : if ( s1->val.ui1  == s2->val.ui1 ) { bval = true; }  break;
        case UI2 : if ( s1->val.ui1  == s2->val.ui2 ) { bval = true; }  break;
        case UI4 : if ( s1->val.ui1  == s2->val.ui4 ) { bval = true; }  break;
        case UI8 : if ( s1->val.ui1  == s2->val.ui8 ) { bval = true; }  break;
        case F4 : if ( s1->val.i1  == s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.i1  == s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    case UI2 : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.ui2  == s2->val.bl ) { bval = true; } break;
        case I1 : if ( ( s2->val.i1 >= 0 ) && ( s1->val.ui2  == s2->val.i1 ) ) { bval = true; }  break;
        case I2 : if ( ( s2->val.i1 >= 0 ) && ( s1->val.ui2  == s2->val.i2 ) ) { bval = true; }  break;
        case I4 : if ( ( s2->val.i1 >= 0 ) && ( s1->val.ui2  == s2->val.i4 ) ) { bval = true; }  break;
        case I8 : if ( ( s2->val.i1 >= 0 ) && ( s1->val.ui2  == s2->val.i8 ) ) { bval = true; }  break;
        case UI1 : if ( s1->val.ui2  == s2->val.ui1 ) { bval = true; }  break;
        case UI2 : if ( s1->val.ui2  == s2->val.ui2 ) { bval = true; }  break;
        case UI4 : if ( s1->val.ui2  == s2->val.ui4 ) { bval = true; }  break;
        case UI8 : if ( s1->val.ui2  == s2->val.ui8 ) { bval = true; }  break;
        case F4 : if ( s1->val.i1  == s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.i1  == s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    case UI4 : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.ui4  == s2->val.bl ) { bval = true; } break;
        case I1 : if ( ( s2->val.i1 >= 0 ) && ( s1->val.ui4  == s2->val.i1 ) ) { bval = true; }  break;
        case I2 : if ( ( s2->val.i1 >= 0 ) && ( s1->val.ui4  == s2->val.i2 ) ) { bval = true; }  break;
        case I4 : if ( ( s2->val.i1 >= 0 ) && ( s1->val.ui4  == s2->val.i4 ) ) { bval = true; }  break;
        case I8 : if ( ( s2->val.i1 >= 0 ) && ( s1->val.ui4  == s2->val.i8 ) ) { bval = true; }  break;
        case UI1 : if ( s1->val.ui4  == s2->val.ui1 ) { bval = true; }  break;
        case UI2 : if ( s1->val.ui4  == s2->val.ui2 ) { bval = true; }  break;
        case UI4 : if ( s1->val.ui4  == s2->val.ui4 ) { bval = true; }  break;
        case UI8 : if ( s1->val.ui4  == s2->val.ui8 ) { bval = true; }  break;
        case F4 : if ( s1->val.i1  == s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.i1  == s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    case UI8 : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.ui8  == s2->val.bl ) { bval = true; } break;
        case I1 :
          if ( ( s2->val.i1 >= 0 ) && ( s1->val.ui8  == s2->val.i1 ) ) { 
            bval = true; 
          }  
          break;
        case I2 : if ( ( s2->val.i1 >= 0 ) && ( s1->val.ui8  == s2->val.i2 ) ) { bval = true; }  break;
        case I4 : if ( ( s2->val.i1 >= 0 ) && ( s1->val.ui8  == s2->val.i4 ) ) { bval = true; }  break;
        case I8 : if ( ( s2->val.i1 >= 0 ) && ( s1->val.ui8  == s2->val.i8 ) ) { bval = true; }  break;
        case UI1 : if ( s1->val.ui8  == s2->val.ui1 ) { bval = true; }  break;
        case UI2 : if ( s1->val.ui8  == s2->val.ui2 ) { bval = true; }  break;
        case UI4 : if ( s1->val.ui8  == s2->val.ui4 ) { bval = true; }  break;
        case UI8 : if ( s1->val.ui8  == s2->val.ui8 ) { bval = true; }  break;
        case F4 : if ( s1->val.i1  == s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.i1  == s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    case F4 : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.f4  == s2->val.bl ) { bval = true; } break;
        case I1 : if ( s1->val.f4  == s2->val.i1 ) { bval = true; }  break; 
        case I2 : if ( s1->val.f4  == s2->val.i2 ) { bval = true; }  break; 
        case I4 : if ( s1->val.f4  == s2->val.i4 ) { bval = true; }  break; 
        case I8 : if ( s1->val.f4  == s2->val.i8 ) { bval = true; }  break; 
        case F4 : if ( s1->val.f4  == s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.f4  == s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    case F8 : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.f8  == s2->val.bl ) { bval = true; } break;
        case I1 : if ( s1->val.f8  == s2->val.i1 ) { bval = true; }  break; 
        case I2 : if ( s1->val.f8  == s2->val.i2 ) { bval = true; }  break; 
        case I4 : if ( s1->val.f8  == s2->val.i4 ) { bval = true; }  break; 
        case I8 : if ( s1->val.f8  == s2->val.i8 ) { bval = true; }  break; 
        case F4 : if ( s1->val.f8  == s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.f8  == s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    default : 
      go_BYE(-1);
      break;
  }
              
  lua_pushboolean(L, bval);
  return 1;
BYE:
  lua_pushboolean(L, false);
  lua_pushnumber(L, status);
  lua_pushstring(L, __FUNCTION__);
  return 3;
}
static int l_sclr_neq(lua_State *L)
{
  int status = 0;
  bool bval = false;
  int num_args = lua_gettop(L); if ( num_args != 2 )  { go_BYE(-1); }

  SCLR_REC_TYPE *s1 = (SCLR_REC_TYPE *)luaL_checkudata(L, 1, "Scalar");
  SCLR_REC_TYPE *s2 = (SCLR_REC_TYPE *)luaL_checkudata(L, 2, "Scalar");
  qtype_t qtype1 = s1->qtype;
  qtype_t qtype2 = s2->qtype;
  if ( ( qtype1 == SC ) || ( qtype1 == TM ) || ( qtype1 == TM1 ) ) {
    // exact type match needed
    if ( qtype1 != qtype2 ) { goto BYE; }
  }
  // handle non number types first 
  if ( qtype1 == SC ) {
    char *str1 = s1->val.str;
    char *str2 = s2->val.str;
    if ( str1 == NULL ) { go_BYE(-1); }
    if ( str2 == NULL ) { go_BYE(-1); }
    if ( strcmp(str1, str2) != 0 ) { bval = true; } 
    goto BYE; 
  }
  if ( qtype1 == TM1 ) {
    printf("TODO \n"); goto BYE;
  }
  if ( qtype1 == TM ) {
    printf("TODO \n"); goto BYE;
  }
  // now handle number types 
  switch ( qtype1 ) {
    case BL : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.bl  != s2->val.bl ) { bval = true; } break;
        case I1 : if ( s1->val.bl  != s2->val.i1 ) { bval = true; }  break; 
        case I2 : if ( s1->val.bl  != s2->val.i2 ) { bval = true; }  break; 
        case I4 : if ( s1->val.bl  != s2->val.i4 ) { bval = true; }  break; 
        case I8 : if ( s1->val.bl  != s2->val.i8 ) { bval = true; }  break; 
        case F4 : if ( s1->val.bl  != s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.bl  != s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    case I1 : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.i1  != s2->val.bl ) { bval = true; } break;
        case I1 : if ( s1->val.i1  != s2->val.i1 ) { bval = true; }  break; 
        case I2 : if ( s1->val.i1  != s2->val.i2 ) { bval = true; }  break; 
        case I4 : if ( s1->val.i1  != s2->val.i4 ) { bval = true; }  break; 
        case I8 : if ( s1->val.i1  != s2->val.i8 ) { bval = true; }  break; 
        case F4 : if ( s1->val.i1  != s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.i1  != s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    case I2 : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.i2  != s2->val.bl ) { bval = true; } break;
        case I1 : if ( s1->val.i2  != s2->val.i1 ) { bval = true; }  break; 
        case I2 : if ( s1->val.i2  != s2->val.i2 ) { bval = true; }  break; 
        case I4 : if ( s1->val.i2  != s2->val.i4 ) { bval = true; }  break; 
        case I8 : if ( s1->val.i2  != s2->val.i8 ) { bval = true; }  break; 
        case F4 : if ( s1->val.i2  != s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.i2  != s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    case I4 : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.i4  != s2->val.bl ) { bval = true; } break;
        case I1 : if ( s1->val.i4  != s2->val.i1 ) { bval = true; }  break; 
        case I2 : if ( s1->val.i4  != s2->val.i2 ) { bval = true; }  break; 
        case I4 : if ( s1->val.i4  != s2->val.i4 ) { bval = true; }  break; 
        case I8 : if ( s1->val.i4  != s2->val.i8 ) { bval = true; }  break; 
        case F4 : if ( s1->val.i4  != s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.i4  != s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    case I8 : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.i8  != s2->val.bl ) { bval = true; } break;
        case I1 : if ( s1->val.i8  != s2->val.i1 ) { bval = true; }  break; 
        case I2 : if ( s1->val.i8  != s2->val.i2 ) { bval = true; }  break; 
        case I4 : if ( s1->val.i8  != s2->val.i4 ) { bval = true; }  break; 
        case I8 : if ( s1->val.i8  != s2->val.i8 ) { bval = true; }  break; 
        case F4 : if ( s1->val.i8  != s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.i8  != s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    case F4 : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.f4  != s2->val.bl ) { bval = true; } break;
        case I1 : if ( s1->val.f4  != s2->val.i1 ) { bval = true; }  break; 
        case I2 : if ( s1->val.f4  != s2->val.i2 ) { bval = true; }  break; 
        case I4 : if ( s1->val.f4  != s2->val.i4 ) { bval = true; }  break; 
        case I8 : if ( s1->val.f4  != s2->val.i8 ) { bval = true; }  break; 
        case F4 : if ( s1->val.f4  != s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.f4  != s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    case F8 : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.f8  != s2->val.bl ) { bval = true; } break;
        case I1 : if ( s1->val.f8  != s2->val.i1 ) { bval = true; }  break; 
        case I2 : if ( s1->val.f8  != s2->val.i2 ) { bval = true; }  break; 
        case I4 : if ( s1->val.f8  != s2->val.i4 ) { bval = true; }  break; 
        case I8 : if ( s1->val.f8  != s2->val.i8 ) { bval = true; }  break; 
        case F4 : if ( s1->val.f8  != s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.f8  != s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    default : 
      go_BYE(-1);
      break;
  }
              
  lua_pushboolean(L, bval);
  return 1;
BYE:
  lua_pushboolean(L, false);
  lua_pushnumber(L, status);
  lua_pushstring(L, __FUNCTION__);
  return 3;
}
static int l_sclr_gt(lua_State *L)
{
  int status = 0;
  bool bval = false;
  int num_args = lua_gettop(L); if ( num_args != 2 )  { go_BYE(-1); }

  SCLR_REC_TYPE *s1 = (SCLR_REC_TYPE *)luaL_checkudata(L, 1, "Scalar");
  SCLR_REC_TYPE *s2 = (SCLR_REC_TYPE *)luaL_checkudata(L, 2, "Scalar");
  qtype_t qtype1 = s1->qtype;
  qtype_t qtype2 = s2->qtype;
  if ( qtype1 == SC ) {
    fprintf(stderr, "order not defined on strings\n"); go_BYE(-1); 
  }
  if ( ( qtype1 == TM ) || ( qtype1 == TM1 ) ) {
    // exact type match needed
    if ( qtype1 != qtype2 ) { go_BYE(-1); } 
  }
  if ( qtype1 == TM1 ) { printf("TODO \n"); go_BYE(-1); } 
  if ( qtype1 ==  TM ) { printf("TODO \n"); go_BYE(-1); } 
  // now handle number types 
  switch ( qtype1 ) {
    case BL : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.bl  > s2->val.bl ) { bval = true; } break;
        case I1 : if ( s1->val.bl  > s2->val.i1 ) { bval = true; }  break; 
        case I2 : if ( s1->val.bl  > s2->val.i2 ) { bval = true; }  break; 
        case I4 : if ( s1->val.bl  > s2->val.i4 ) { bval = true; }  break; 
        case I8 : if ( s1->val.bl  > s2->val.i8 ) { bval = true; }  break; 
        case F4 : if ( s1->val.bl  > s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.bl  > s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    case I1 : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.i1  > s2->val.bl ) { bval = true; } break;
        case I1 : if ( s1->val.i1  > s2->val.i1 ) { bval = true; }  break; 
        case I2 : if ( s1->val.i1  > s2->val.i2 ) { bval = true; }  break; 
        case I4 : if ( s1->val.i1  > s2->val.i4 ) { bval = true; }  break; 
        case I8 : if ( s1->val.i1  > s2->val.i8 ) { bval = true; }  break; 
        case F4 : if ( s1->val.i1  > s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.i1  > s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    case I2 : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.i2  > s2->val.bl ) { bval = true; } break;
        case I1 : if ( s1->val.i2  > s2->val.i1 ) { bval = true; }  break; 
        case I2 : if ( s1->val.i2  > s2->val.i2 ) { bval = true; }  break; 
        case I4 : if ( s1->val.i2  > s2->val.i4 ) { bval = true; }  break; 
        case I8 : if ( s1->val.i2  > s2->val.i8 ) { bval = true; }  break; 
        case F4 : if ( s1->val.i2  > s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.i2  > s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    case I4 : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.i4  > s2->val.bl ) { bval = true; } break;
        case I1 : if ( s1->val.i4  > s2->val.i1 ) { bval = true; }  break; 
        case I2 : if ( s1->val.i4  > s2->val.i2 ) { bval = true; }  break; 
        case I4 : if ( s1->val.i4  > s2->val.i4 ) { bval = true; }  break; 
        case I8 : if ( s1->val.i4  > s2->val.i8 ) { bval = true; }  break; 
        case F4 : if ( s1->val.i4  > s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.i4  > s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    case I8 : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.i8  > s2->val.bl ) { bval = true; } break;
        case I1 : if ( s1->val.i8  > s2->val.i1 ) { bval = true; }  break; 
        case I2 : if ( s1->val.i8  > s2->val.i2 ) { bval = true; }  break; 
        case I4 : if ( s1->val.i8  > s2->val.i4 ) { bval = true; }  break; 
        case I8 : if ( s1->val.i8  > s2->val.i8 ) { bval = true; }  break; 
        case F4 : if ( s1->val.i8  > s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.i8  > s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    case UI1 : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.ui1  > s2->val.bl ) { bval = true; } break;
        case I1 : if ( s1->val.ui1  > s2->val.i1 ) { bval = true; }  break; 
        case I2 : if ( s1->val.ui1  > s2->val.i2 ) { bval = true; }  break; 
        case I4 : if ( s1->val.ui1  > s2->val.i4 ) { bval = true; }  break; 
        case I8 : if ( s1->val.ui1  > s2->val.i8 ) { bval = true; }  break; 
        case F4 : if ( s1->val.ui1  > s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.ui1  > s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    case UI2 : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.ui2  > s2->val.bl ) { bval = true; } break;
        case I1 : if ( s1->val.ui2  > s2->val.i1 ) { bval = true; }  break; 
        case I2 : if ( s1->val.ui2  > s2->val.i2 ) { bval = true; }  break; 
        case I4 : if ( s1->val.ui2  > s2->val.i4 ) { bval = true; }  break; 
        case I8 : if ( s1->val.ui2  > s2->val.i8 ) { bval = true; }  break; 
        case F4 : if ( s1->val.ui2  > s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.ui2  > s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    case UI4 : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.ui4  > s2->val.bl ) { bval = true; } break;
        case I1 : if ( s1->val.ui4  > s2->val.i1 ) { bval = true; }  break; 
        case I2 : if ( s1->val.ui4  > s2->val.i2 ) { bval = true; }  break; 
        case I4 : if ( s1->val.ui4  > s2->val.i4 ) { bval = true; }  break; 
        case I8 : if ( s1->val.ui4  > s2->val.i8 ) { bval = true; }  break; 
        case F4 : if ( s1->val.ui4  > s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.ui4  > s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    case UI8 : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.ui8  > s2->val.bl ) { bval = true; } break;
        case I1 : if ( s1->val.ui8  > s2->val.i1 ) { bval = true; }  break; 
        case I2 : if ( s1->val.ui8  > s2->val.i2 ) { bval = true; }  break; 
        case I4 : if ( s1->val.ui8  > s2->val.i4 ) { bval = true; }  break; 
        case I8 : if ( s1->val.ui8  > s2->val.i8 ) { bval = true; }  break; 
        case F4 : if ( s1->val.ui8  > s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.ui8  > s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    case F4 : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.f4  > s2->val.bl ) { bval = true; } break;
        case I1 : if ( s1->val.f4  > s2->val.i1 ) { bval = true; }  break; 
        case I2 : if ( s1->val.f4  > s2->val.i2 ) { bval = true; }  break; 
        case I4 : if ( s1->val.f4  > s2->val.i4 ) { bval = true; }  break; 
        case I8 : if ( s1->val.f4  > s2->val.i8 ) { bval = true; }  break; 
        case F4 : if ( s1->val.f4  > s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.f4  > s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    case F8 : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.f8  > s2->val.bl ) { bval = true; } break;
        case I1 : if ( s1->val.f8  > s2->val.i1 ) { bval = true; }  break; 
        case I2 : if ( s1->val.f8  > s2->val.i2 ) { bval = true; }  break; 
        case I4 : if ( s1->val.f8  > s2->val.i4 ) { bval = true; }  break; 
        case I8 : if ( s1->val.f8  > s2->val.i8 ) { bval = true; }  break; 
        case F4 : if ( s1->val.f8  > s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.f8  > s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    default : 
      go_BYE(-1);
      break;
  }
              
  lua_pushboolean(L, bval);
  return 1;
BYE:
  lua_pushboolean(L, false);
  lua_pushnumber(L, status);
  lua_pushstring(L, __FUNCTION__);
  return 3;
}
static int l_sclr_lt(lua_State *L)
{
  int status = 0;
  bool bval = false;
  int num_args = lua_gettop(L); if ( num_args != 2 )  { go_BYE(-1); }

  SCLR_REC_TYPE *s1 = (SCLR_REC_TYPE *)luaL_checkudata(L, 1, "Scalar");
  SCLR_REC_TYPE *s2 = (SCLR_REC_TYPE *)luaL_checkudata(L, 2, "Scalar");
  qtype_t qtype1 = s1->qtype;
  qtype_t qtype2 = s2->qtype;
  if ( qtype1 == SC ) {
    fprintf(stderr, "order not defined on strings\n"); go_BYE(-1); 
  }
  if ( ( qtype1 == TM ) || ( qtype1 == TM1 ) ) {
    // exact type match needed
    if ( qtype1 != qtype2 ) { go_BYE(-1); } 
  }
  if ( qtype1 == TM1 ) { printf("TODO \n"); go_BYE(-1); } 
  if ( qtype1 ==  TM ) { printf("TODO \n"); go_BYE(-1); } 
  // now handle number types 
  switch ( qtype1 ) {
    case BL : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.bl  < s2->val.bl ) { bval = true; } break;
        case I1 : if ( s1->val.bl  < s2->val.i1 ) { bval = true; }  break; 
        case I2 : if ( s1->val.bl  < s2->val.i2 ) { bval = true; }  break; 
        case I4 : if ( s1->val.bl  < s2->val.i4 ) { bval = true; }  break; 
        case I8 : if ( s1->val.bl  < s2->val.i8 ) { bval = true; }  break; 
        case F4 : if ( s1->val.bl  < s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.bl  < s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    case I1 : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.i1  < s2->val.bl ) { bval = true; } break;
        case I1 : if ( s1->val.i1  < s2->val.i1 ) { bval = true; }  break; 
        case I2 : if ( s1->val.i1  < s2->val.i2 ) { bval = true; }  break; 
        case I4 : if ( s1->val.i1  < s2->val.i4 ) { bval = true; }  break; 
        case I8 : if ( s1->val.i1  < s2->val.i8 ) { bval = true; }  break; 
        case UI1 : if ( s1->val.i1 < s2->val.ui1 ) { bval = true; }  break;
        case UI2 : if ( s1->val.i1 < s2->val.ui2 ) { bval = true; }  break;
        case UI4 : if ( s1->val.i1 < s2->val.ui4 ) { bval = true; }  break;
        case UI8 : if ( s1->val.i1 < s2->val.ui8 ) { bval = true; }  break;
        case F4 : if ( s1->val.i1  < s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.i1  < s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    case I2 : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.i2  < s2->val.bl ) { bval = true; } break;
        case I1 : if ( s1->val.i2  < s2->val.i1 ) { bval = true; }  break; 
        case I2 : if ( s1->val.i2  < s2->val.i2 ) { bval = true; }  break; 
        case I4 : if ( s1->val.i2  < s2->val.i4 ) { bval = true; }  break; 
        case I8 : if ( s1->val.i2  < s2->val.i8 ) { bval = true; }  break; 
        case UI1 : if ( s1->val.i2 < s2->val.ui1 ) { bval = true; }  break;
        case UI2 : if ( s1->val.i2 < s2->val.ui2 ) { bval = true; }  break;
        case UI4 : if ( s1->val.i2 < s2->val.ui4 ) { bval = true; }  break;
        case UI8 : if ( s1->val.i2 < s2->val.ui8 ) { bval = true; }  break;
        case F4 : if ( s1->val.i2  < s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.i2  < s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    case I4 : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.i4  < s2->val.bl ) { bval = true; } break;
        case I1 : if ( s1->val.i4  < s2->val.i1 ) { bval = true; }  break; 
        case I2 : if ( s1->val.i4  < s2->val.i2 ) { bval = true; }  break; 
        case I4 : if ( s1->val.i4  < s2->val.i4 ) { bval = true; }  break; 
        case I8 : if ( s1->val.i4  < s2->val.i8 ) { bval = true; }  break; 
        case UI1 : if ( s1->val.i4  < s2->val.ui1 ) { bval = true; }  break;
        case UI2 : if ( s1->val.i4  < s2->val.ui2 ) { bval = true; }  break;
        case UI4 : if ( s1->val.i4  < s2->val.ui4 ) { bval = true; }  break;
        case UI8 : if ( s1->val.i4  < s2->val.ui8 ) { bval = true; }  break;
        case F4 : if ( s1->val.i4  < s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.i4  < s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    case I8 : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.i8  < s2->val.bl ) { bval = true; } break;
        case I1 : if ( s1->val.i8  < s2->val.i1 ) { bval = true; }  break; 
        case I2 : if ( s1->val.i8  < s2->val.i2 ) { bval = true; }  break; 
        case I4 : if ( s1->val.i8  < s2->val.i4 ) { bval = true; }  break; 
        case I8 : if ( s1->val.i8  < s2->val.i8 ) { bval = true; }  break; 
        case UI1 : if ( s1->val.i8  < s2->val.ui1 ) { bval = true; }  break;
        case UI2 : if ( s1->val.i8  < s2->val.ui2 ) { bval = true; }  break;
        case UI4 : if ( s1->val.i8  < s2->val.ui4 ) { bval = true; }  break;
        case UI8 : if ( s1->val.i8  < s2->val.ui8 ) { bval = true; }  break;
        case F4 : if ( s1->val.i8  < s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.i8  < s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    case UI1 : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.ui1  < s2->val.bl ) { bval = true; } break;
        case I1 : if ( s1->val.ui1  < s2->val.i1 ) { bval = true; }  break; 
        case I2 : if ( s1->val.ui1  < s2->val.i2 ) { bval = true; }  break; 
        case I4 : if ( s1->val.ui1  < s2->val.i4 ) { bval = true; }  break; 
        case I8 : if ( s1->val.ui1  < s2->val.i8 ) { bval = true; }  break; 
        case F4 : if ( s1->val.ui1  < s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.ui1  < s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    case UI2 : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.ui2  < s2->val.bl ) { bval = true; } break;
        case I1 : if ( s1->val.ui2  < s2->val.i1 ) { bval = true; }  break; 
        case I2 : if ( s1->val.ui2  < s2->val.i2 ) { bval = true; }  break; 
        case I4 : if ( s1->val.ui2  < s2->val.i4 ) { bval = true; }  break; 
        case I8 : if ( s1->val.ui2  < s2->val.i8 ) { bval = true; }  break; 
        case F4 : if ( s1->val.ui2  < s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.ui2  < s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    case UI4 : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.ui4  < s2->val.bl ) { bval = true; } break;
        case I1 : if ( s1->val.ui4  < s2->val.i1 ) { bval = true; }  break; 
        case I2 : if ( s1->val.ui4  < s2->val.i2 ) { bval = true; }  break; 
        case I4 : if ( s1->val.ui4  < s2->val.i4 ) { bval = true; }  break; 
        case I8 : if ( s1->val.ui4  < s2->val.i8 ) { bval = true; }  break; 
        case F4 : if ( s1->val.ui4  < s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.ui4  < s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    case UI8 : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.ui8  < s2->val.bl ) { bval = true; } break;
        case I1 : if ( s1->val.ui8  < s2->val.i1 ) { bval = true; }  break; 
        case I2 : if ( s1->val.ui8  < s2->val.i2 ) { bval = true; }  break; 
        case I4 : if ( s1->val.ui8  < s2->val.i4 ) { bval = true; }  break; 
        case I8 : if ( s1->val.ui8  < s2->val.i8 ) { bval = true; }  break; 
        case F4 : if ( s1->val.ui8  < s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.ui8  < s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    case F4 : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.f4  < s2->val.bl ) { bval = true; } break;
        case I1 : if ( s1->val.f4  < s2->val.i1 ) { bval = true; }  break; 
        case I2 : if ( s1->val.f4  < s2->val.i2 ) { bval = true; }  break; 
        case I4 : if ( s1->val.f4  < s2->val.i4 ) { bval = true; }  break; 
        case I8 : if ( s1->val.f4  < s2->val.i8 ) { bval = true; }  break; 
        case F4 : if ( s1->val.f4  < s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.f4  < s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    case F8 : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.f8  < s2->val.bl ) { bval = true; } break;
        case I1 : if ( s1->val.f8  < s2->val.i1 ) { bval = true; }  break; 
        case I2 : if ( s1->val.f8  < s2->val.i2 ) { bval = true; }  break; 
        case I4 : if ( s1->val.f8  < s2->val.i4 ) { bval = true; }  break; 
        case I8 : if ( s1->val.f8  < s2->val.i8 ) { bval = true; }  break; 
        case F4 : if ( s1->val.f8  < s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.f8  < s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    default : 
      go_BYE(-1);
      break;
  }
              
  lua_pushboolean(L, bval);
  return 1;
BYE:
  lua_pushboolean(L, false);
  lua_pushnumber(L, status);
  lua_pushstring(L, __FUNCTION__);
  return 3;
}
static int l_sclr_geq(lua_State *L)
{
  int status = 0;
  bool bval = false;
  int num_args = lua_gettop(L); if ( num_args != 2 )  { go_BYE(-1); }

  SCLR_REC_TYPE *s1 = (SCLR_REC_TYPE *)luaL_checkudata(L, 1, "Scalar");
  SCLR_REC_TYPE *s2 = (SCLR_REC_TYPE *)luaL_checkudata(L, 2, "Scalar");
  qtype_t qtype1 = s1->qtype;
  qtype_t qtype2 = s2->qtype;
  if ( qtype1 == SC ) {
    fprintf(stderr, "order not defined on strings\n"); go_BYE(-1); 
  }
  if ( ( qtype1 == TM ) || ( qtype1 == TM1 ) ) {
    // exact type match needed
    if ( qtype1 != qtype2 ) { go_BYE(-1); } 
  }
  if ( qtype1 == TM1 ) { printf("TODO \n"); go_BYE(-1); } 
  if ( qtype1 ==  TM ) { printf("TODO \n"); go_BYE(-1); } 
  // now handle number types 
  switch ( qtype1 ) {
    case BL : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.bl  >= s2->val.bl ) { bval = true; } break;
        case I1 : if ( s1->val.bl  >= s2->val.i1 ) { bval = true; }  break; 
        case I2 : if ( s1->val.bl  >= s2->val.i2 ) { bval = true; }  break; 
        case I4 : if ( s1->val.bl  >= s2->val.i4 ) { bval = true; }  break; 
        case I8 : if ( s1->val.bl  >= s2->val.i8 ) { bval = true; }  break; 
        case F4 : if ( s1->val.bl  >= s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.bl  >= s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    case I1 : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.i1  >= s2->val.bl ) { bval = true; } break;
        case I1 : if ( s1->val.i1  >= s2->val.i1 ) { bval = true; }  break; 
        case I2 : if ( s1->val.i1  >= s2->val.i2 ) { bval = true; }  break; 
        case I4 : if ( s1->val.i1  >= s2->val.i4 ) { bval = true; }  break; 
        case I8 : if ( s1->val.i1  >= s2->val.i8 ) { bval = true; }  break; 
        case F4 : if ( s1->val.i1  >= s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.i1  >= s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    case I2 : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.i2  >= s2->val.bl ) { bval = true; } break;
        case I1 : if ( s1->val.i2  >= s2->val.i1 ) { bval = true; }  break; 
        case I2 : if ( s1->val.i2  >= s2->val.i2 ) { bval = true; }  break; 
        case I4 : if ( s1->val.i2  >= s2->val.i4 ) { bval = true; }  break; 
        case I8 : if ( s1->val.i2  >= s2->val.i8 ) { bval = true; }  break; 
        case F4 : if ( s1->val.i2  >= s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.i2  >= s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    case I4 : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.i4  >= s2->val.bl ) { bval = true; } break;
        case I1 : if ( s1->val.i4  >= s2->val.i1 ) { bval = true; }  break; 
        case I2 : if ( s1->val.i4  >= s2->val.i2 ) { bval = true; }  break; 
        case I4 : if ( s1->val.i4  >= s2->val.i4 ) { bval = true; }  break; 
        case I8 : if ( s1->val.i4  >= s2->val.i8 ) { bval = true; }  break; 
        case F4 : if ( s1->val.i4  >= s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.i4  >= s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    case I8 : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.i8  >= s2->val.bl ) { bval = true; } break;
        case I1 : if ( s1->val.i8  >= s2->val.i1 ) { bval = true; }  break; 
        case I2 : if ( s1->val.i8  >= s2->val.i2 ) { bval = true; }  break; 
        case I4 : if ( s1->val.i8  >= s2->val.i4 ) { bval = true; }  break; 
        case I8 : if ( s1->val.i8  >= s2->val.i8 ) { bval = true; }  break; 
        case F4 : if ( s1->val.i8  >= s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.i8  >= s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    case F4 : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.f4  >= s2->val.bl ) { bval = true; } break;
        case I1 : if ( s1->val.f4  >= s2->val.i1 ) { bval = true; }  break; 
        case I2 : if ( s1->val.f4  >= s2->val.i2 ) { bval = true; }  break; 
        case I4 : if ( s1->val.f4  >= s2->val.i4 ) { bval = true; }  break; 
        case I8 : if ( s1->val.f4  >= s2->val.i8 ) { bval = true; }  break; 
        case F4 : if ( s1->val.f4  >= s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.f4  >= s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    case F8 : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.f8  >= s2->val.bl ) { bval = true; } break;
        case I1 : if ( s1->val.f8  >= s2->val.i1 ) { bval = true; }  break; 
        case I2 : if ( s1->val.f8  >= s2->val.i2 ) { bval = true; }  break; 
        case I4 : if ( s1->val.f8  >= s2->val.i4 ) { bval = true; }  break; 
        case I8 : if ( s1->val.f8  >= s2->val.i8 ) { bval = true; }  break; 
        case F4 : if ( s1->val.f8  >= s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.f8  >= s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    default : 
      go_BYE(-1);
      break;
  }
              
  lua_pushboolean(L, bval);
  return 1;
BYE:
  lua_pushboolean(L, false);
  lua_pushnumber(L, status);
  lua_pushstring(L, __FUNCTION__);
  return 3;
}
static int l_sclr_leq(lua_State *L)
{
  int status = 0;
  bool bval = false;
  int num_args = lua_gettop(L); if ( num_args != 2 )  { go_BYE(-1); }

  SCLR_REC_TYPE *s1 = (SCLR_REC_TYPE *)luaL_checkudata(L, 1, "Scalar");
  SCLR_REC_TYPE *s2 = (SCLR_REC_TYPE *)luaL_checkudata(L, 2, "Scalar");
  qtype_t qtype1 = s1->qtype;
  qtype_t qtype2 = s2->qtype;
  if ( qtype1 == SC ) {
    fprintf(stderr, "order not defined on strings\n"); go_BYE(-1); 
  }
  if ( ( qtype1 == TM ) || ( qtype1 == TM1 ) ) {
    // exact type match needed
    if ( qtype1 != qtype2 ) { go_BYE(-1); } 
  }
  if ( qtype1 == TM1 ) { printf("TODO \n"); go_BYE(-1); } 
  if ( qtype1 ==  TM ) { printf("TODO \n"); go_BYE(-1); } 
  // now handle number types 
  switch ( qtype1 ) {
    case BL : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.bl  <= s2->val.bl ) { bval = true; } break;
        case I1 : if ( s1->val.bl  <= s2->val.i1 ) { bval = true; }  break; 
        case I2 : if ( s1->val.bl  <= s2->val.i2 ) { bval = true; }  break; 
        case I4 : if ( s1->val.bl  <= s2->val.i4 ) { bval = true; }  break; 
        case I8 : if ( s1->val.bl  <= s2->val.i8 ) { bval = true; }  break; 
        case F4 : if ( s1->val.bl  <= s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.bl  <= s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    case I1 : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.i1  <= s2->val.bl ) { bval = true; } break;
        case I1 : if ( s1->val.i1  <= s2->val.i1 ) { bval = true; }  break; 
        case I2 : if ( s1->val.i1  <= s2->val.i2 ) { bval = true; }  break; 
        case I4 : if ( s1->val.i1  <= s2->val.i4 ) { bval = true; }  break; 
        case I8 : if ( s1->val.i1  <= s2->val.i8 ) { bval = true; }  break; 
        case F4 : if ( s1->val.i1  <= s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.i1  <= s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    case I2 : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.i2  <= s2->val.bl ) { bval = true; } break;
        case I1 : if ( s1->val.i2  <= s2->val.i1 ) { bval = true; }  break; 
        case I2 : if ( s1->val.i2  <= s2->val.i2 ) { bval = true; }  break; 
        case I4 : if ( s1->val.i2  <= s2->val.i4 ) { bval = true; }  break; 
        case I8 : if ( s1->val.i2  <= s2->val.i8 ) { bval = true; }  break; 
        case F4 : if ( s1->val.i2  <= s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.i2  <= s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    case I4 : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.i4  <= s2->val.bl ) { bval = true; } break;
        case I1 : if ( s1->val.i4  <= s2->val.i1 ) { bval = true; }  break; 
        case I2 : if ( s1->val.i4  <= s2->val.i2 ) { bval = true; }  break; 
        case I4 : if ( s1->val.i4  <= s2->val.i4 ) { bval = true; }  break; 
        case I8 : if ( s1->val.i4  <= s2->val.i8 ) { bval = true; }  break; 
        case F4 : if ( s1->val.i4  <= s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.i4  <= s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    case I8 : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.i8  <= s2->val.bl ) { bval = true; } break;
        case I1 : if ( s1->val.i8  <= s2->val.i1 ) { bval = true; }  break; 
        case I2 : if ( s1->val.i8  <= s2->val.i2 ) { bval = true; }  break; 
        case I4 : if ( s1->val.i8  <= s2->val.i4 ) { bval = true; }  break; 
        case I8 : if ( s1->val.i8  <= s2->val.i8 ) { bval = true; }  break; 
        case F4 : if ( s1->val.i8  <= s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.i8  <= s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    case F4 : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.f4  <= s2->val.bl ) { bval = true; } break;
        case I1 : if ( s1->val.f4  <= s2->val.i1 ) { bval = true; }  break; 
        case I2 : if ( s1->val.f4  <= s2->val.i2 ) { bval = true; }  break; 
        case I4 : if ( s1->val.f4  <= s2->val.i4 ) { bval = true; }  break; 
        case I8 : if ( s1->val.f4  <= s2->val.i8 ) { bval = true; }  break; 
        case F4 : if ( s1->val.f4  <= s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.f4  <= s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    case F8 : 
      switch ( qtype2 )  {
        case BL : if ( s1->val.f8  <= s2->val.bl ) { bval = true; } break;
        case I1 : if ( s1->val.f8  <= s2->val.i1 ) { bval = true; }  break; 
        case I2 : if ( s1->val.f8  <= s2->val.i2 ) { bval = true; }  break; 
        case I4 : if ( s1->val.f8  <= s2->val.i4 ) { bval = true; }  break; 
        case I8 : if ( s1->val.f8  <= s2->val.i8 ) { bval = true; }  break; 
        case F4 : if ( s1->val.f8  <= s2->val.f4 ) { bval = true; }  break; 
        case F8 : if ( s1->val.f8  <= s2->val.f8 ) { bval = true; }  break; 
        default : go_BYE(-1); break;
      }
      break;
      //-------------------------------------------------------------
    default : 
      go_BYE(-1);
      break;
  }
              
  lua_pushboolean(L, bval);
  return 1;
BYE:
  lua_pushboolean(L, false);
  lua_pushnumber(L, status);
  lua_pushstring(L, __FUNCTION__);
  return 3;
}
