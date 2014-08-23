
#include "lua.h"
#include "lauxlib.h"
#include <windows.h>

static int keystate(lua_State *L){
  int tecla, estado;
    
  tecla = luaL_checknumber(L, 1);
  estado = GetAsyncKeyState(tecla);
  lua_pushnumber(L, estado);
  return 1;
}

// Registrar funciones//

static const luaL_reg toolslib[] = {
  {"keystate", keystate},
  {NULL, NULL}
};

//Abrir librería//

int __declspec(dllexport) luaopen_tools (lua_State *L) {
  luaL_openlib(L, "tools", toolslib, 0);
  return 1;
}
