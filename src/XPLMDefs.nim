# See license.txt for usage.


# This file is contains the cross-platform and basic definitions for the
# X-Plane SDK.
#
# The preprocessor macros APL and IBM must be defined to specify the
# compilation target; define APL to 1 and IBM 0 to compile on Macintosh and
# APL to 0 and IBM to 1 for Windows. You must specify these macro definitions
# before including XPLMDefs.h or any other XPLM headers.  You can do this
# using the -D command line option or a preprocessor header.
#

#******************************************************************************
#  GLOBAL DEFINITIONS
# *****************************************************************************
#
#  These definitions are used in all parts of the SDK.
#

#  XPLMPluginID
#
#  Each plug-in is identified by a unique integer ID.  This ID can be used to
#  disable or enable a plug-in, or discover what plug-in is 'running' at the
#  time.  A plug-in ID is unique within the currently running instance of
#  X-Plane unless plug-ins are reloaded.  Plug-ins may receive a different
#  unique ID each time they are loaded.
#
#  For persistent identification of plug-ins, use XPLMFindPluginBySignature in
#  XPLMUtiltiies.h
#
#  -1 indicates no plug-in.
type
  XPLMPluginID* = int

# No plugin.
const
  XPLM_NO_PLUGIN_ID* = -1

# X-Plane itself
const
  XPLM_PLUGIN_XPLANE* = 0

# The current XPLM revision is 2.10 (210).
const
  kXPLM_Version* = 210

##
#  XPLMKeyFlags
#
#  These bitfields define modifier keys in a platform independent way. When a
#  key is pressed, a series of messages are sent to your plugin.  The down
#  flag is set in the first of these messages, and the up flag in the last.
#  While the key is held down, messages are sent with neither to indicate that
#  the key is being held down as a repeated character.
#
#  The control flag is mapped to the control flag on Macintosh and PC.
#  Generally X-Plane uses the control key and not the command key on
#  Macintosh, providing a consistent interface across platforms that does not
#  necessarily match the Macintosh user interface guidelines.  There is not
#  yet a way for plugins to access the Macintosh control keys without using
#  #ifdefed code.
type
  XPLMKeyFlags* {.size: sizeof(int).} = enum
    xplm_ShiftFlag = 1       # The shift key is down
    xplm_OptionAltFlag = 2   # The option or alt key is down
    xplm_ControlFlag = 4     # The control key is down
    xplm_DownFlag = 8        # The key is being pressed down
    xplm_UpFlag = 16         # The key is being released

#******************************************************************************
#  ASCII CONTROL KEY CODES
# *****************************************************************************
#
#  These definitions define how various control keys are mapped to ASCII key
#  codes. Not all key presses generate an ASCII value, so plugin code should
#  be prepared to see null characters come from the keyboard...this usually
#  represents a key stroke that has no equivalent ASCII, like a page-down
#  press.  Use virtual key codes to find these key strokes. ASCII key codes
#  take into account modifier keys; shift keys will affect capitals and
#  punctuation; control key combinations may have no vaild ASCII and produce
#  NULL.  To detect control-key combinations, use virtual key codes, not ASCII
#  keys.
const
  XPLM_KEY_RETURN* = 13
  XPLM_KEY_ESCAPE* = 27
  XPLM_KEY_TAB* = 9
  XPLM_KEY_DELETE* = 8
  XPLM_KEY_LEFT* = 28
  XPLM_KEY_RIGHT* = 29
  XPLM_KEY_UP* = 30
  XPLM_KEY_DOWN* = 31
  XPLM_KEY_0* = 48
  XPLM_KEY_1* = 49
  XPLM_KEY_2* = 50
  XPLM_KEY_3* = 51
  XPLM_KEY_4* = 52
  XPLM_KEY_5* = 53
  XPLM_KEY_6* = 54
  XPLM_KEY_7* = 55
  XPLM_KEY_8* = 56
  XPLM_KEY_9* = 57
  XPLM_KEY_DECIMAL* = 46

#******************************************************************************
#  VIRTUAL KEY CODES
# *****************************************************************************
#
#  These are cross-platform defines for every distinct keyboard press on the
#  computer. Every physical key on the keyboard has a virtual key code.  So
#  the "two" key on the  top row of the main keyboard has a different code
#  from the "two" key on the numeric key pad.  But the 'w' and 'W' character
#  are indistinguishable by virtual key code  because they are the same
#  physical key (one with and one without the shift key).
#
#  Use virtual key codes to detect keystrokes that do not have ASCII
#  equivalents, allow the user to map the numeric keypad separately from the
#  main keyboard, and detect control key and other modifier-key combinations
#  that generate ASCII control key sequences (many of which are not available
#  directly via character keys in the SDK).
#
#  To assign virtual key codes we started with the Microsoft set but made some
#  additions and changes.  A few differences:
#
#  1. Modifier keys are not available as virtual key codes.  You cannot get
#  distinct modifier press and release messages.  Please do not try to use
#  modifier keys as regular keys; doing so will almost certainly interfere
#  with users' abilities to use the native x-plane key bindings.
#
#  2. Some keys that do not exist on both Mac and PC keyboards are removed.
#
#  3. Do not assume that the values of these keystrokes are interchangeable
#  with MS v-keys.
const
  XPLM_VK_BACK* = 0x00000008
  XPLM_VK_TAB* = 0x00000009
  XPLM_VK_CLEAR* = 0x0000000C
  XPLM_VK_RETURN* = 0x0000000D
  XPLM_VK_ESCAPE* = 0x0000001B
  XPLM_VK_SPACE* = 0x00000020
  XPLM_VK_PRIOR* = 0x00000021
  XPLM_VK_NEXT* = 0x00000022
  XPLM_VK_END* = 0x00000023
  XPLM_VK_HOME* = 0x00000024
  XPLM_VK_LEFT* = 0x00000025
  XPLM_VK_UP* = 0x00000026
  XPLM_VK_RIGHT* = 0x00000027
  XPLM_VK_DOWN* = 0x00000028
  XPLM_VK_SELECT* = 0x00000029
  XPLM_VK_PRINT* = 0x0000002A
  XPLM_VK_EXECUTE* = 0x0000002B
  XPLM_VK_SNAPSHOT* = 0x0000002C
  XPLM_VK_INSERT* = 0x0000002D
  XPLM_VK_DELETE* = 0x0000002E
  XPLM_VK_HELP* = 0x0000002F

# XPLM_VK_0 thru XPLM_VK_9 are the same as ASCII '0' thru '9' (0x30 - 0x39)
const
  XPLM_VK_0* = 0x00000030
  XPLM_VK_1* = 0x00000031
  XPLM_VK_2* = 0x00000032
  XPLM_VK_3* = 0x00000033
  XPLM_VK_4* = 0x00000034
  XPLM_VK_5* = 0x00000035
  XPLM_VK_6* = 0x00000036
  XPLM_VK_7* = 0x00000037
  XPLM_VK_8* = 0x00000038
  XPLM_VK_9* = 0x00000039

# XPLM_VK_A thru XPLM_VK_Z are the same as ASCII 'A' thru 'Z' (0x41 - 0x5A)
const
  XPLM_VK_A* = 0x00000041
  XPLM_VK_B* = 0x00000042
  XPLM_VK_C* = 0x00000043
  XPLM_VK_D* = 0x00000044
  XPLM_VK_E* = 0x00000045
  XPLM_VK_F* = 0x00000046
  XPLM_VK_G* = 0x00000047
  XPLM_VK_H* = 0x00000048
  XPLM_VK_I* = 0x00000049
  XPLM_VK_J* = 0x0000004A
  XPLM_VK_K* = 0x0000004B
  XPLM_VK_L* = 0x0000004C
  XPLM_VK_M* = 0x0000004D
  XPLM_VK_N* = 0x0000004E
  XPLM_VK_O* = 0x0000004F
  XPLM_VK_P* = 0x00000050
  XPLM_VK_Q* = 0x00000051
  XPLM_VK_R* = 0x00000052
  XPLM_VK_S* = 0x00000053
  XPLM_VK_T* = 0x00000054
  XPLM_VK_U* = 0x00000055
  XPLM_VK_V* = 0x00000056
  XPLM_VK_W* = 0x00000057
  XPLM_VK_X* = 0x00000058
  XPLM_VK_Y* = 0x00000059
  XPLM_VK_Z* = 0x0000005A
  XPLM_VK_NUMPAD0* = 0x00000060
  XPLM_VK_NUMPAD1* = 0x00000061
  XPLM_VK_NUMPAD2* = 0x00000062
  XPLM_VK_NUMPAD3* = 0x00000063
  XPLM_VK_NUMPAD4* = 0x00000064
  XPLM_VK_NUMPAD5* = 0x00000065
  XPLM_VK_NUMPAD6* = 0x00000066
  XPLM_VK_NUMPAD7* = 0x00000067
  XPLM_VK_NUMPAD8* = 0x00000068
  XPLM_VK_NUMPAD9* = 0x00000069
  XPLM_VK_MULTIPLY* = 0x0000006A
  XPLM_VK_ADD* = 0x0000006B
  XPLM_VK_SEPARATOR* = 0x0000006C
  XPLM_VK_SUBTRACT* = 0x0000006D
  XPLM_VK_DECIMAL* = 0x0000006E
  XPLM_VK_DIVIDE* = 0x0000006F
  XPLM_VK_F1* = 0x00000070
  XPLM_VK_F2* = 0x00000071
  XPLM_VK_F3* = 0x00000072
  XPLM_VK_F4* = 0x00000073
  XPLM_VK_F5* = 0x00000074
  XPLM_VK_F6* = 0x00000075
  XPLM_VK_F7* = 0x00000076
  XPLM_VK_F8* = 0x00000077
  XPLM_VK_F9* = 0x00000078
  XPLM_VK_F10* = 0x00000079
  XPLM_VK_F11* = 0x0000007A
  XPLM_VK_F12* = 0x0000007B
  XPLM_VK_F13* = 0x0000007C
  XPLM_VK_F14* = 0x0000007D
  XPLM_VK_F15* = 0x0000007E
  XPLM_VK_F16* = 0x0000007F
  XPLM_VK_F17* = 0x00000080
  XPLM_VK_F18* = 0x00000081
  XPLM_VK_F19* = 0x00000082
  XPLM_VK_F20* = 0x00000083
  XPLM_VK_F21* = 0x00000084
  XPLM_VK_F22* = 0x00000085
  XPLM_VK_F23* = 0x00000086
  XPLM_VK_F24* = 0x00000087

# The following definitions are extended and are not based on the Microsoft
# key set.
const
  XPLM_VK_EQUAL* = 0x000000B0
  XPLM_VK_MINUS* = 0x000000B1
  XPLM_VK_RBRACE* = 0x000000B2
  XPLM_VK_LBRACE* = 0x000000B3
  XPLM_VK_QUOTE* = 0x000000B4
  XPLM_VK_SEMICOLON* = 0x000000B5
  XPLM_VK_BACKSLASH* = 0x000000B6
  XPLM_VK_COMMA* = 0x000000B7
  XPLM_VK_SLASH* = 0x000000B8
  XPLM_VK_PERIOD* = 0x000000B9
  XPLM_VK_BACKQUOTE* = 0x000000BA
  XPLM_VK_ENTER* = 0x000000BB
  XPLM_VK_NUMPAD_ENT* = 0x000000BC
  XPLM_VK_NUMPAD_EQ* = 0x000000BD

