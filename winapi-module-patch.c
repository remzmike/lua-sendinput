static int l_send_mouse_input(lua_State *L) {
  if (lua_isnumber(L,1) && lua_isnumber(L,2) && lua_isnumber(L,3)) {
    LONG dx = (LONG)lua_tonumber(L,1);
    LONG dy = (LONG)lua_tonumber(L,2);
    DWORD flags = (DWORD)lua_tonumber(L,3);
    //        
    INPUT inp;
    memset(&inp, 0, sizeof(INPUT));
    inp.type = INPUT_MOUSE;
    inp.mi.dx = dx;
    inp.mi.dy = dy;
    inp.mi.dwFlags = flags;
    SendInput(1, &inp, sizeof(INPUT));
    return 0;
  } else {
    return push_error_msg(L,"bad params to send_mouse_input");
  }
  return 0;  
}

static int l_send_keyboard_input(lua_State *L) {
  if (lua_isnumber(L,1) && lua_isnumber(L,2) && lua_isnumber(L,3)) {
    WORD vk = (WORD)lua_tonumber(L,1);
    WORD scan = (WORD)lua_tonumber(L,2);
    DWORD flags = (DWORD)lua_tonumber(L,3);
    //        
    INPUT inp;
    memset(&inp, 0, sizeof(INPUT));
    inp.type = INPUT_KEYBOARD;
    inp.ki.wVk = vk;
    inp.ki.wScan = scan;
    inp.ki.dwFlags = flags;    
    SendInput(1, &inp, sizeof(INPUT));
    return 0;
  } else {
    return push_error_msg(L,"bad params to send_keyboard_input");
  }
  return 0;  
}

static int l_block_input(lua_State *L) {
    if (lua_isboolean(L,1)) {
        BOOL flag = lua_toboolean(L,1);        
        BlockInput(flag);
    } else {
        return push_error_msg(L,"bad params to block_input");    
    }
    return 0;   
}

static int l_get_async_key_state(lua_State *L) {
    if (lua_isnumber(L,1)) {
        int vk = (int)lua_tonumber(L,1);
        SHORT state = GetAsyncKeyState(vk);
        BOOL down = state < 0; // msb 1
        BOOL toggle = (state & 1) != 0; // lsb 1
        lua_pushboolean(L, down); 
        lua_pushboolean(L, toggle);
        return 2;
    } else {
        return push_error_msg(L,"bad params to get_async_key_state");
    }
}

static int l_get_key_state(lua_State *L) {
    if (lua_isnumber(L,1)) {
        int vk = (int)lua_tonumber(L,1);
        SHORT state = GetKeyState(vk);
        BOOL down = state < 0;
        BOOL toggle = (state & 1) != 0;
        lua_pushboolean(L, down); 
        lua_pushboolean(L, toggle);
        return 2;
    } else {
        return push_error_msg(L,"bad params to get_key_state");
    }
}

static int l_get_keyboard_state(lua_State *L) {
    int i;
    BYTE state[256];
    BOOL result = GetKeyboardState(state);
    lua_newtable(L);    
    for (i=0; i<256; i++) {
        BOOL down = state[i] < 0;
        // wish: does not handle low order bit toggles (caps lock etc, num lock, whatever, dont care)
        lua_pushboolean(L, down);
        lua_rawseti(L, -2, i+1);
    }
    lua_pushboolean(L, result);
    return 2;
}

static int l_map_virtual_key(lua_State *L) {
    if (lua_isnumber(L,1) && lua_isnumber(L,2)) {
        UINT code = (UINT)lua_tonumber(L,1);
        UINT maptype = (UINT)lua_tonumber(L,2);
        UINT result = MapVirtualKey(code, maptype);
        lua_pushnumber(L, result);
        return 1;
    } else {
        return push_error_msg(L,"bad params to map_virtual_key");   
    }
}