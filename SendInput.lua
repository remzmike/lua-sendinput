-- SendInput - yonderboi - send mouse and keyboard events
--
-- Times are in milliseconds.
--
-- Requires my winapi.dll, a modified version of this lua module:
--   https://github.com/stevedonovan/winapi/tree/master/examples
--   http://stevedonovan.github.io/winapi/api.html
--   I added 2 functions: send_mouse_input and send_keyboard_input
--
-- v00 - 5/3/2013 5:37:48 PM - Prerelease
-- v01 - 5/4/2013 12:04:39 PM - Changes to work with SendInputScheduled
-- v02 - 5/5/2013 5:41:04 PM - proper lua module
-- v03 - 7/5/2014 2:21 PM - only send if lol is the foreground window
--
-- See also: SKeys.lua module for key scan codes
-- See also: SendInputScheduled.lua for sleep-free event scheduling (preferred)

require 'winapi'

local function is_window_active(window_class_name)
    local w = winapi.get_foreground_window()
    return w:get_class_name() == window_class_name
end

local M = {}

function M.key_down(vk)
    flags = 0
    winapi.send_keyboard_input(vk, 0, flags)
end

function M.key_up(vk)
    flags = M._KE_KEYUP
    winapi.send_keyboard_input(vk, 0, flags)
end

function M.skey_down(sc)
    flags = M._KE_SCANCODE
    winapi.send_keyboard_input(0, sc, flags)
end

function M.skey_up(vk)
    flags = M._KE_SCANCODE_KEYUP
    winapi.send_keyboard_input(0, sc, flags)
end

function M.skey_press(sc, holdtime)
    M.skey_down(sc)
    if holdtime then
        winapi.sleep(holdtime)
    end
    M.skey_up(sc)
end

function M.key_press(vk, holdtime)
    M.key_down(vk)
    if holdtime then
        winapi.sleep(holdtime)
    end
    M.key_up(vk)
end

function M.mouse_move(x, y, absolute)
    if absolute == nil then absolute = true end
    local flags = M._ME_MOVE
    if absolute then
        flags = bit.bor(flags, M._ME_ABSOLUTE)
        x, y = M.s2m(x, y)
    end
    winapi.send_mouse_input(x, y, flags)
end

-- note: actual x, y movement depends on mouse acceleration settings
-- read the microsoft docs to see why
function M.mouse_move_relative(x, y)
    return M.mouse_move(x, y, false)
end

function M.mouse_down(lr)
    local down, up = M._get_button_constants(lr)
    local flags = down
    winapi.send_mouse_input(0, 0, flags)
end

function M.mouse_up(lr)
    local down, up = M._get_button_constants(lr)
    local flags = up
    winapi.send_mouse_input(0, 0, flags)
end

function M.mouse_press(lr, holdtime)
    M.mouse_down(lr)
    if holdtime ~= nil then
        winapi.sleep(holdtime)
    end
    M.mouse_up(lr)
end

-- convert screen coordinates to magical absolute mouse coordinates [0-65535]
-- todo: does getscreenx return screen resolution or window size? we need resolution
function M.s2m(x, y)
    local use_old = false
    if use_old then
        local sx = GetScreenX()
        local sy = GetScreenY()
        local rx = (x / sx) * 65536
        local ry = (y / sy) * 65536
        return rx, ry
    else
        local sx = GetScreenX()
        local sy = GetScreenY()
        local rx = (x / sx)
        local ry = (y / sy)
        return rx, ry
    end
end

-- private ---------------------------------------------------------------------

-- key event
-- http://msdn.microsoft.com/en-us/library/windows/desktop/ms646271(v=vs.85).aspx
M._KE_KEYUP = 0x0002
M._KE_SCANCODE = 0x0008
M._KE_SCANCODE_KEYUP = bit.bor(M._KE_KEYUP, M._KE_SCANCODE)
-- mouse event
-- http://msdn.microsoft.com/en-us/library/windows/desktop/ms646273(v=vs.85).aspx
M._ME_MOVE = 0x0001
M._ME_LEFTDOWN = 0x0002
M._ME_LEFTUP = 0x0004
M._ME_RIGHTDOWN = 0x0008
M._ME_RIGHTUP = 0x0010
M._ME_MIDDLEDOWN = 0x0020
M._ME_MIDDLEUP = 0x0040
M._ME_ABSOLUTE = 0x8000

function M._get_button_constants(lr)
    if lr ~= nil then lr = lr:lower() end
    if lr=='right' then return M._ME_RIGHTDOWN, M._ME_RIGHTUP
    elseif lr=='mid' then return M._ME_MIDDLEDOWN, M._ME_MIDDLEUP
    else return M._ME_LEFTDOWN, M._ME_LEFTUP
    end
end

-- test ------------------------------------------------------------------------

local _run_test = false
if _run_test then
    function GetScreenX() return 1920 end
    function GetScreenY() return 1080 end
    require 'SKeys'
    print('testing...')
    local p = winapi.spawn_process('notepad')
    p:wait_for_input_idle()
    local w = winapi.find_window_match('Untitled')
    w:show()
    w:set_foreground()
    winapi.send_to_window('testing...')
    M.key_press(SKeys.Return)
    M.key_down(SKeys.LShift)
    M.key_press(SKeys.H)
    M.key_up(SKeys.LShift)
    M.key_press(SKeys.E, 200)
    M.key_press(SKeys.L, 200)
    M.key_press(SKeys.L, 200)
    winapi.send_to_window('o')
    M.key_press(SKeys.Return)
    --key_up(SKeys.H)
    --key_press(SKeys.E)
    M.mouse_move(0, 0)
    -- todo: actual mouse_move_relative movement changes based on mouse accel settings
    for i=0,10 do
        winapi.sleep(10)
        M.mouse_move_relative(10,10)
        M.mouse_press('right', 200)
    end
    -- todo: better mouse testing
    winapi.sleep(200)
    M.mouse_move(0, 0)
    winapi.sleep(200)
    M.mouse_move(100, 100)
    M.mouse_press('right', 600)
    --mouse_up()
    --mouse_press()
end

-- module ----------------------------------------------------------------------

return M