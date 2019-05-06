#include<stdlib.h>
#include<inttypes.h>

#include "luaconf.h"
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

#include "add.h"
int luaopen_libvec (lua_State *L);
int l_add(lua_State *L) {
  uint64_t result = 0;
  uint64_t input = lua_tonumber(L, -1);
  result = add(input);
  lua_pushnumber(L, result);
  return 1;
}

int luaopen_add(lua_State *L){
  lua_register(L, "add", l_add);
  return 0;
}
