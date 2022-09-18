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
  qtype_t qtype = s1->qtype;
  if ( s2->qtype != qtype ) { goto BYE; }
  switch ( qtype ) { 
    case B1 : if ( s1->val.b1  == s2->val.b1 ) { bval = true; } break; 
    case BL : if ( s1->val.b1  == s2->val.b1 ) { bval = true; } break;
    case I1 : if ( s1->val.i1  == s2->val.i1 ) { bval = true; }  break; 
    case I2 : if ( s1->val.i2  == s2->val.i2 ) { bval = true; }  break; 
    case I4 : if ( s1->val.i4  == s2->val.i4 ) { bval = true; }  break; 
    case I8 : if ( s1->val.i8  == s2->val.i8 ) { bval = true; }  break; 
    case F4 : if ( s1->val.f4  == s2->val.f4 ) { bval = true; }  break; 
    case F8 : if ( s1->val.f8  == s2->val.f8 ) { bval = true; }  break; 
    case SC : 
              {
                char *str1 = s1->val.str;
                char *str2 = s2->val.str;
                if ( str1 == NULL ) { go_BYE(-1); }
                if ( str2 == NULL ) { go_BYE(-1); }
                if ( strcmp(str1, str2) == 0 ) { bval = true; } 
              }
              break;
    default : go_BYE(-1); break; 
  }
  lua_pushboolean(L, bval);
  return 1;
BYE:
  lua_pushboolean(L, bval);
  return 1;
}
static int l_sclr_neq(lua_State *L)
{
  int status = 0;
  bool bval = false;
  int num_args = lua_gettop(L); if ( num_args != 2 )  { go_BYE(-1); }

  SCLR_REC_TYPE *s1 = (SCLR_REC_TYPE *)luaL_checkudata(L, 1, "Scalar");
  SCLR_REC_TYPE *s2 = (SCLR_REC_TYPE *)luaL_checkudata(L, 2, "Scalar");
  qtype_t qtype = s1->qtype;
  if ( s2->qtype != qtype ) { goto BYE; }
  switch ( qtype ) { 
    case B1 : if ( s1->val.b1  != s2->val.b1 ) { bval = true; } break; 
    case BL : if ( s1->val.b1  != s2->val.b1 ) { bval = true; } break;
    case I1 : if ( s1->val.i1  != s2->val.i1 ) { bval = true; }  break; 
    case I2 : if ( s1->val.i2  != s2->val.i2 ) { bval = true; }  break; 
    case I4 : if ( s1->val.i4  != s2->val.i4 ) { bval = true; }  break; 
    case I8 : if ( s1->val.i8  != s2->val.i8 ) { bval = true; }  break; 
    case F4 : if ( s1->val.f4  != s2->val.f4 ) { bval = true; }  break; 
    case F8 : if ( s1->val.f8  != s2->val.f8 ) { bval = true; }  break; 
    case SC : 
              {
                char *str1 = s1->val.str;
                char *str2 = s2->val.str;
                if ( str1 == NULL ) { go_BYE(-1); }
                if ( str2 == NULL ) { go_BYE(-1); }
                if ( strcmp(str1, str2) != 0 ) { bval = true; } 
              }
              break;
    default : go_BYE(-1); break; 
  }
  lua_pushboolean(L, bval);
  return 1;
BYE:
  lua_pushboolean(L, bval);
  return 1;
}
static int l_sclr_leq(lua_State *L)
{
  int status = 0;
  bool bval = false;
  int num_args = lua_gettop(L); if ( num_args != 2 )  { go_BYE(-1); }

  SCLR_REC_TYPE *s1 = (SCLR_REC_TYPE *)luaL_checkudata(L, 1, "Scalar");
  SCLR_REC_TYPE *s2 = (SCLR_REC_TYPE *)luaL_checkudata(L, 2, "Scalar");
  qtype_t qtype = s1->qtype;
  if ( s2->qtype != qtype ) { goto BYE; }
  switch ( qtype ) { 
    case I1 : if ( s1->val.i1  <= s2->val.i1 ) { bval = true; }  break; 
    case I2 : if ( s1->val.i2  <= s2->val.i2 ) { bval = true; }  break; 
    case I4 : if ( s1->val.i4  <= s2->val.i4 ) { bval = true; }  break; 
    case I8 : if ( s1->val.i8  <= s2->val.i8 ) { bval = true; }  break; 
    case F4 : if ( s1->val.f4  <= s2->val.f4 ) { bval = true; }  break; 
    case F8 : if ( s1->val.f8  <= s2->val.f8 ) { bval = true; }  break; 
    default : go_BYE(-1); break; 
  }
  lua_pushboolean(L, bval);
  return 1;
BYE:
  lua_pushboolean(L, bval);
  return 1;
}
static int l_sclr_geq(lua_State *L)
{
  int status = 0;
  bool bval = false;
  int num_args = lua_gettop(L); if ( num_args != 2 )  { go_BYE(-1); }

  SCLR_REC_TYPE *s1 = (SCLR_REC_TYPE *)luaL_checkudata(L, 1, "Scalar");
  SCLR_REC_TYPE *s2 = (SCLR_REC_TYPE *)luaL_checkudata(L, 2, "Scalar");
  qtype_t qtype = s1->qtype;
  if ( s2->qtype != qtype ) { goto BYE; }
  switch ( qtype ) { 
    case I1 : if ( s1->val.i1  >= s2->val.i1 ) { bval = true; }  break; 
    case I2 : if ( s1->val.i2  >= s2->val.i2 ) { bval = true; }  break; 
    case I4 : if ( s1->val.i4  >= s2->val.i4 ) { bval = true; }  break; 
    case I8 : if ( s1->val.i8  >= s2->val.i8 ) { bval = true; }  break; 
    case F4 : if ( s1->val.f4  >= s2->val.f4 ) { bval = true; }  break; 
    case F8 : if ( s1->val.f8  >= s2->val.f8 ) { bval = true; }  break; 
    default : go_BYE(-1); break; 
  }
  lua_pushboolean(L, bval);
  return 1;
BYE:
  lua_pushboolean(L, bval);
  return 1;
  return 3;
}
static int l_sclr_lt(lua_State *L)
{
  int status = 0;
  bool bval = false;
  int num_args = lua_gettop(L); if ( num_args != 2 )  { go_BYE(-1); }

  SCLR_REC_TYPE *s1 = (SCLR_REC_TYPE *)luaL_checkudata(L, 1, "Scalar");
  SCLR_REC_TYPE *s2 = (SCLR_REC_TYPE *)luaL_checkudata(L, 2, "Scalar");
  qtype_t qtype = s1->qtype;
  if ( s2->qtype != qtype ) { goto BYE; }
  switch ( qtype ) { 
    case I1 : if ( s1->val.i1  < s2->val.i1 ) { bval = true; }  break; 
    case I2 : if ( s1->val.i2  < s2->val.i2 ) { bval = true; }  break; 
    case I4 : if ( s1->val.i4  < s2->val.i4 ) { bval = true; }  break; 
    case I8 : if ( s1->val.i8  < s2->val.i8 ) { bval = true; }  break; 
    case F4 : if ( s1->val.f4  < s2->val.f4 ) { bval = true; }  break; 
    case F8 : if ( s1->val.f8  < s2->val.f8 ) { bval = true; }  break; 
    default : go_BYE(-1); break; 
  }
  lua_pushboolean(L, bval);
  return 1;
BYE:
  lua_pushboolean(L, bval);
  return 1;
}
static int l_sclr_gt(lua_State *L)
{
  int status = 0;
  bool bval = false;
  int num_args = lua_gettop(L); if ( num_args != 2 )  { go_BYE(-1); }

  SCLR_REC_TYPE *s1 = (SCLR_REC_TYPE *)luaL_checkudata(L, 1, "Scalar");
  SCLR_REC_TYPE *s2 = (SCLR_REC_TYPE *)luaL_checkudata(L, 2, "Scalar");
  qtype_t qtype = s1->qtype;
  if ( s2->qtype != qtype ) { goto BYE; }
  switch ( qtype ) { 
    case I1 : if ( s1->val.i1  > s2->val.i1 ) { bval = true; }  break; 
    case I2 : if ( s1->val.i2  > s2->val.i2 ) { bval = true; }  break; 
    case I4 : if ( s1->val.i4  > s2->val.i4 ) { bval = true; }  break; 
    case I8 : if ( s1->val.i8  > s2->val.i8 ) { bval = true; }  break; 
    case F4 : if ( s1->val.f4  > s2->val.f4 ) { bval = true; }  break; 
    case F8 : if ( s1->val.f8  > s2->val.f8 ) { bval = true; }  break; 
    default : go_BYE(-1); break; 
  }
  lua_pushboolean(L, bval);
  return 1;
BYE:
  lua_pushboolean(L, bval);
  return 1;
}
