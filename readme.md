## SendInput

Send mouse and keyboard events with lua in Windows.

Requires a modified version of Steve Donovan's winapi module:

* https://github.com/stevedonovan/winapi/tree/master/examples
* http://stevedonovan.github.io/winapi/api.html

I added 2 functions:

* send_mouse_input
* send_keyboard_input

See: winapi-module-patch.c

## usage

All times are in milliseconds.

See: SKeys.lua/Keys.lua module for key scan codes
See: **SendInputScheduled.lua** for sleep-free event scheduling (async)
See: \_test\_* files for sample test code

## prior history

v00 - 5/3/2013 5:37:48 PM - Prerelease
v01 - 5/4/2013 12:04:39 PM - Changes to work with SendInputScheduled
v02 - 5/5/2013 5:41:04 PM - proper lua module
v03 - 7/5/2014 2:21 PM - only send if lol is the foreground window

