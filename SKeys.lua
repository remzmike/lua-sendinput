-- yonderboi
--
-- hardware scan codes for keys, not the same as virtual key codes
--
-- v02 - 5/6/2013 1:12:10 PM - changed F12
-- v03 - 6/21/2013 12:37:43 AM - added Shift alias to LShift
--
-- http://www.nanobit.net/doxy/wolfenstein/ID__IN_8H_source.html
--
-- todo: later: MapVirtualKey - http://msdn.microsoft.com/en-us/library/windows/desktop/ms646306(v=vs.85).aspx
--
-- new stuff
-- * http://faydoc.tripod.com/structures/00/0006.htm
-- http://www.quadibloc.com/comp/scan.htm
-- http://philipstorr.id.au/pcbook/book3/scancode.htm
--
-- http://www.passmark.com/products/keytest.htm
--
-- The keyboard config file is here: \League of Legends\Config\input.ini
-- http://leagueoflegends.wikia.com/wiki/Hotkeys_and_commands
-- http://na.leagueoflegends.com/board/showthread.php?p=15644321#15644321

SKeys = {}

SKeys.None         = 0
SKeys.Bad          = 0xff
SKeys.Return       = 0x1c
SKeys.Enter        = SKeys.Return
SKeys.Escape       = 0x01
SKeys.Space        = 0x39
SKeys.BackSpace    = 0x0e
SKeys.Tab          = 0x0f
SKeys.Alt          = 0x38
SKeys.Control      = 0x1d
SKeys.CapsLock     = 0x3a
SKeys.LShift       = 0x2a
SKeys.Shift        = SKeys.LShift
SKeys.RShift       = 0x36
SKeys.UpArrow      = 0x48
SKeys.DownArrow    = 0x50
SKeys.LeftArrow    = 0x4b
SKeys.RightArrow   = 0x4d
SKeys.Insert       = 0x52
SKeys.Delete       = 0x53
SKeys.Home         = 0x47
SKeys.End          = 0x4f
SKeys.PgUp         = 0x49
SKeys.PgDn         = 0x51
SKeys.F1           = 0x3b
SKeys.F2           = 0x3c
SKeys.F3           = 0x3d
SKeys.F4           = 0x3e
SKeys.F5           = 0x3f
SKeys.F6           = 0x40
SKeys.F7           = 0x41
SKeys.F8           = 0x42
SKeys.F9           = 0x43
SKeys.F10          = 0x44
SKeys.F11          = 0x57
--SKeys.F12          = 0x59
SKeys.F12          = 0x58 -- this is what it is on my keyboard
--
SKeys.D1           = 0x02
SKeys.D2           = 0x03
SKeys.D3           = 0x04
SKeys.D4           = 0x05
SKeys.D5           = 0x06
SKeys.D6           = 0x07
SKeys.D7           = 0x08
SKeys.D8           = 0x09
SKeys.D9           = 0x0a
SKeys.D0           = 0x0b
--
SKeys.A            = 0x1e
SKeys.B            = 0x30
SKeys.C            = 0x2e
SKeys.D            = 0x20
SKeys.E            = 0x12
SKeys.F            = 0x21
SKeys.G            = 0x22
SKeys.H            = 0x23
SKeys.I            = 0x17
SKeys.J            = 0x24
SKeys.K            = 0x25
SKeys.L            = 0x26
SKeys.M            = 0x32
SKeys.N            = 0x31
SKeys.O            = 0x18
SKeys.P            = 0x19
SKeys.Q            = 0x10
SKeys.R            = 0x13
SKeys.S            = 0x1f
SKeys.T            = 0x14
SKeys.U            = 0x16
SKeys.V            = 0x2f
SKeys.W            = 0x11
SKeys.X            = 0x2d
SKeys.Y            = 0x15
SKeys.Z            = 0x2c
-- found on my keyboard:
-- pause 0x45 (also num lock?)
-- context menu key 0x5d
-- rwin 0x5c
-- backslash 0x2b