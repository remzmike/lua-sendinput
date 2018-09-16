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

* See: SKeys.lua/Keys.lua module for key scan codes
* See: **SendInputScheduled.lua** for sleep-free event scheduling (async)
* See: \_test\_* files for sample test code