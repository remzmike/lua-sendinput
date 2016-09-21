-- SendInputScheduled - yonderboi - sleep-free mouse/keyboard scheduling
--
-- Times are in milliseconds.
-- 
-- Mirrors and wraps my SendInput.lua api. Adds one function, wait(ms),
-- which delays all subsequently scheduled events.
--
-- All functions return a reference to the table they insert to the buffer.
-- That table can be modified after the call if desired or needed.
-- eg. key_down(SKeys.P).countdown = 100; -- keydown in 100ms
--
-- Requires SendInput.lua v02+.
--
-- Differences between SendInput and SendInputScheduled?
--
--   SendInput:
--     - sleep delays sometimes required for event detection in game
--     - sleep blocks the script, that might be a hindrance for some
--     + event resolution is the same as win32 Sleep, ~1ms in Windows 7
--   SendInputScheduled:
--     + no sleeping, no blocking, input is buffered
--     - you still have to use wait(), but it doesnt block, so no big deal
--     - event resolution is ~0 to ~50ms, where ~50ms is the LB tick resolution
--
-- v01 - 5/4/2013 12:21:54 PM
-- v02 - 5/4/2013 1:27:39 PM - buffer has a max size now
-- v03 - 5/5/2013 5:48:40 PM - proper lua module, removed automatic tick, scripts must call tick() now
-- v04 - 5/6/2013 5:21:59 PM - simple convenience change: wrap s2m function
-- v05 - 5/6/2013 5:47:34 PM - automatically keep down/up events together when using *_press functions
-- v06 - 5/11/2013 11:17:57 AM - added scary block_input, requires winapi v04
-- v07 - 5/18/2013 1:38:41 AM - added on_async_key_change callback for block_input, added get_keystate_scancode_delta function, requires winapi v06
-- v08 - 5/19/2013 10:24:12 AM - fixed bug from v07 where nil block context threw error when ending block_input, made _default_holdtime the default param to wait()
-- v09 - 6/4/2013 12:28:17 PM - added send.text, send.callback and prints warning when buffer is full
--
-- See also: SKeys.lua module for key scan codes
-- See also: SendInput.lua, obviously

-- todo: separate buffers for each calling script? maybe not, because that would mean keys could get interspersed
-- todo: more granular event cancelling (right now the dev just doesnt call tick()), but we could do better
--       better idea, you pass the check function with the call to tick, easy
--       this would cut the chance of leaking keys to other window from 1% to 0.1%?
--       maybe not worth it because we should spend time on dealing with leak, as with lolBlurDetected
-- todo: code to draw the buffer :-)
-- todo: send.tick() takes params that filters what it will run on, mostly for block_input i suppose

local M = {}

local send = require 'SendInput'

function M.s2m(...)
    return send.s2m(...)
end

function M.key_down(...)
    local t = {fn=send.key_down, args={...}, countdown=0}
    M._insert(t)
    return t
end

function M.key_up(...)
    local t = {fn=send.key_up, args={...}, countdown=0}
    M._insert(t)
    return t
end

function M.key_press(...)    
    if M.is_buffer_full() then return {}, {} end
    local holdtime
    local n = select('#',...)
    if n<2 then
        holdtime = M._default_holdtime
    else
        holdtime = select(2,...)
    end    
    local t1 = {fn=send.key_down, args={...}, countdown=0}    
    local t2 = {fn=send.key_up, args={...}, countdown=holdtime}
    M.disable_max_buffer() -- keep these two events together
    M._insert(t1)
    M._insert(t2)
    M.enable_max_buffer()
    return t1, t2
end

function M.text(...)
    local t = {fn=winapi.send_to_window, args={...}, countdown=0}
    M._insert(t)
    return t
end

function M.mouse_move(...)
    local t = {fn=send.mouse_move, args={...}, countdown=0}
    M._insert(t)
    return t
end

function M.mouse_move_relative(...)
    local t = {fn=send.mouse_move_relative, args={...}, countdown=0}
    M._insert(t)
    return t
end

function M.mouse_down(...)
    local t = {fn=send.mouse_down, args={...}, countdown=0}
    M._insert(t)
    return t
end

function M.mouse_up(...)
    local t = {fn=send.mouse_up, args={...}, countdown=0}
    M._insert(t)
    return t
end

function M.mouse_press(...)
    if M.is_buffer_full() then return {}, {} end
    local holdtime
    local n = select('#',...)
    if n<2 then
        holdtime = M._default_holdtime
    else
        holdtime = select(2,...)
    end    
    local t1 = {fn=send.mouse_down, args={...}, countdown=0}    
    local t2 = {fn=send.mouse_up, args={...}, countdown=holdtime}
    M.disable_max_buffer() -- keep these two events together
    M._insert(t1)
    M._insert(t2)
    M.enable_max_buffer()
    return t1, t2
end

-- insert a hard wait, delays subsequently inserted events
function M.wait(ms)
    if ms == nil then
        ms = M._default_holdtime
    end
    local t = {wait=true, countdown=ms}
    M._insert(t)
    return t
end

function M.callback(fn, ...)
    local t = {fn=fn, args={...}, countdown=0}
    M._insert(t)
    return t
end

-- disable/enable max buffer, to make sure you don't lose ups for downs, like transactions
function M.disable_max_buffer()
    M._buffer_max_enabled = false
end

function M.enable_max_buffer()
    M._buffer_max_enabled = true
end

function M.is_buffer_full()
    local result = #M._buffer>=M._buffer_max
    if result then
        print('WARNING: Scripts have filled the SendInputScheduled buffer. This is usually the scripts fault.')
    end
    return result
end

function M.is_max_buffer_enabled()
    return M._buffer_max_enabled
end

-- block input, trying to be safe, since this is a dangerous function
-- flag true blocks, flag false unblocks
-- timeout is the maximum block time, in ms, default: 10 seconds
--[[ 
-- complicated:
--
-- the timeout slides with each new block, so if you keep blocking the timeout wont happen
-- ie. do block #1, do block #2, timeout for block #1 wont stop block #2
-- this is better than having no timeout mechanism at all
-- a sliding timeout avoids the problem of:
--     block #1, then block #2 9.8 seconds later
--     then block #1 timeout unblocks @ 10 seconds
--     breaking the intent of block #2
]]--
function M.block_input(flag, timeout, on_async_key_change)
    --print('\nblock_input')
    local t
    if flag then 
        if timeout==nil then timeout=10*1000 end
        t = {fn=M._begin_block_input, args={timeout, on_async_key_change}, countdown=0}        
    else
        t = {fn=M._end_block_input, args={}, countdown=0}        
    end
    M._insert(t)
    return t    
end

function M.tick()
    local now = os.clock()
    local dt = (now - M._lasttick)*1000
    --print('dt', dt, '#M._buffer', #M._buffer)
    -- loop all, if wait encountered and still waiting then break
    -- this still allows previously scheduled press holdtimes to work because the up event will be before the wait
    -- presses scheduled after the wait have not even started yet
    local i = 1
    local remove
    while i <= #M._buffer do
        t = M._buffer[i]
        remove = false
        t.countdown = t.countdown - dt        
        --print('new countdown', t.countdown)
        if t.wait then
            if t.countdown > 0 then
                break
            else
                remove = true
            end
        else
            if t.countdown > 0 then
                --print('waiting', t.countdown)
                -- pass
            else
                --print('running', t.countdown)
                t.fn(unpack(t.args))
                remove = true
            end
        end
        if remove then
            table.remove(M._buffer, i)
            --print('remaining #', #M._buffer)
        else
            i = i + 1
        end
    end
    M._lasttick = os.clock()
end

-- return differences between two keystates, as scan codes
function M.get_keystate_scancode_delta(before, after)
    local changes = {}    
    local changed = false
    for vk=0,255 do
        if before[vk] ~= after[vk] then
            -- map to scan code
            local scode = winapi.map_virtual_key(vk, 0)
            changes[scode] = after[vk]
            changed = true
        end
    end
    return changes, changed
end

-- private ---------------------------------------------------------------------

M._buffer = {}
M._buffer_max = 40
M._buffer_max_enabled = true
M._tick_enabled = true
M._lasttick = os.clock()
M._default_holdtime = 100
M._input_blocked_at = nil
M._block_context = {}

function M._insert(t)
    local do_insert = true
    if M._buffer_max_enabled and M.is_buffer_full() then
        do_insert = false
    end
    if do_insert then
        table.insert(M._buffer, t)
    end
end

function M._begin_block_input(timeout, on_async_key_change)
    print('\n_begin_block_input')
    local now = os.clock()
    M._input_blocked_at = now
    M.disable_max_buffer() -- always schedule the timeout
    local t = {fn=M._timeout_block_input, args={now}, countdown=timeout}
    M._insert(t)
    M.enable_max_buffer()
    winapi.block_input(true) -- block after timeout scheduled
    if on_async_key_change ~= nil then
        local async_keystate_before = winapi.get_async_keyboard_state()
        table.insert(M._block_context, {on_async_key_change=on_async_key_change, async_keystate_before=async_keystate_before})
    end
end

function M._end_block_input()
    print('\n_end_block_input')
    local context = table.remove(M._block_context)
    local after
    if context ~= nil and context.on_async_key_change ~= nil then
        after = winapi.get_async_keyboard_state()
    end
    winapi.block_input(false)    
    M._input_blocked_at = nil
    
    if context ~= nil and context.on_async_key_change ~= nil then
        local changes, changed = M.get_keystate_scancode_delta(context.async_keystate_before, after)
        if changed then    
            context.on_async_key_change(changes)
        end
    end    
end

-- only ends if block_start matches _input_blocked_at
function M._timeout_block_input(block_start)
    print('\n_timeout_block_input')
    if block_start == M._input_blocked_at then
        winapi.block_input(false)
    end
end

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

-- module ----------------------------------------------------------------------

return M