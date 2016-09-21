-- test ------------------------------------------------------------------------

local _run_test = false
local _console_mode = SetTimerCallback==nil
if _run_test and _console_mode then
    assert(M.key_press ~= send.key_press)
    require 'winapi'
    --
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
    M.tick()
    print('H done')

    if true then
        M.key_press(SKeys.E, 800)
        M.key_press(SKeys.LShift, 2000) -- 2 capital L's
        M.key_press(SKeys.L, 800)
        M.key_press(SKeys.L, 800)
        for i=0,25 do
            winapi.sleep(100)
            M.tick()
        end
    end
    M.key_press(SKeys.L, 500) -- 2 lower L's
    M.key_press(SKeys.L, 500)    
    for i=0,11 do
        winapi.sleep(100)
        M.tick()
    end
    winapi.send_to_window('o')
    
    M.key_press(SKeys.Return)
    M.tick()
    M.key_press(SKeys.A, 200)
    M.wait(2000)
    M.key_press(SKeys.S)
    M.tick()
    for i=0,25 do
        winapi.sleep(100)
        M.tick()
    end
    M.key_press(SKeys.D)
    M.key_press(SKeys.F)
    M.tick()
    
    if true then        
        M.key_press(SKeys.Return)
        M.tick()
        --key_up(SKeys.H)
        --key_press(SKeys.E)
        M.mouse_move(0, 0)
        M.tick()

        for i=0,100 do
            winapi.sleep(10)
            M.mouse_move_relative(1,1)
            M.mouse_press('right', 200)
            M.tick()
        end
        -- todo: better mouse testing
        winapi.sleep(800)
        M.mouse_move(0, 0)
        M.tick()
        winapi.sleep(800)
        M.mouse_move(100, 100)
        M.tick()
        M.mouse_press('right', 600)
        for i=0,10 do
            winapi.sleep(100)
            M.tick()
        end
        --mouse_up()
        --mouse_press()
    end
end