-- test ------------------------------------------------------------------------

local _run_test = false
local _console_mode = SetTimerCallback==nil
if _run_test and _console_mode then    
    function GetScreenX() return 1280 end
    function GetScreenY() return 1024 end
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