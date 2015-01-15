# See license.txt for usage.


# XPWidgetUtils - USAGE NOTES
#
# The XPWidgetUtils library contains useful functions that make writing and
# using  widgets less of a pain.
#
# One set of functions are the widget behavior functions.  These functions
# each add specific useful behaviors to widgets.  They can be used in two
# manners:
#
# 1. You can add a widget behavior function to a widget as a callback proc
# using the XPAddWidgetCallback function.  The widget will gain that
# behavior.  Remember that the last function you add has highest priority.
# You can use this to change or augment the behavior of an existing finished
# widget.
#
# 2. You can call a widget function from inside your own widget function.
# This allows you to include useful behaviors in custom-built widgets.  A
# number of the standard widgets get their behavior from this library.  To do
# this, call the behavior function from your function first.  If it returns
# 1, that means it handled the event and you don't need to; simply return 1.
#


#
# Convenience accessors
#
# It can be clumsy accessing the variables passed in by pointer to a struct
# for mouse and reshape messages; these accessors let you simply pass in the param
# right from the arguments of your widget proc and get back the value you want.
#
# #define	MOUSE_X(param) (((XPMouseState_t *) (param))->x)
# #define	MOUSE_Y(param) (((XPMouseState_t *) (param))->y)

# #define DELTA_X(param) (((XPWidgetGeometryChange_t *) (param))->dx)
# #define DELTA_Y(param) (((XPWidgetGeometryChange_t *) (param))->dy)
# #define DELTA_W(param) (((XPWidgetGeometryChange_t *) (param))->dwidth)
# #define DELTA_H(param) (((XPWidgetGeometryChange_t *) (param))->dheight)

# #define KEY_CHAR(param) (((XPKeyState_t *) (param))->key)
# #define KEY_FLAGS(param) (((XPKeyState_t *) (param))->flags)
# #define KEY_VKEY(param) (((XPKeyState_t *) (param))->vkey)

# #define IN_RECT(x, y, l, t, r, b)	\
# 	(((x) >= (l)) && ((x) <= (r)) && ((y) >= (b)) && ((y) <= (t)))

# XPWidgetCreate_t contains all of the parameters needed to create a wiget. It
# is used with XPUCreateWidgets to create widgets in bulk from an array.  All
# parameters correspond to those of XPCreateWidget except for the container
# index. If the container index is equal to the index of a widget in the
# array, the widget in the array passed to XPUCreateWidgets is used as the
# parent of this widget.  Note that if you pass an index greater than your
# own position in the array, the parent you are requesting will not exist
# yet. If the container index is NO_PARENT, the parent widget is specified as
# NULL. If the container index is PARAM_PARENT, the widget passed into
# XPUCreateWidgets is used.
type
  PXPWidgetCreate_t* = ptr XPWidgetCreate_t
  XPWidgetCreate_t*{.final.} = object
    left*: int
    top*: int
    right*: int
    bottom*: int
    visible*: int
    descriptor*: cstring
    isRoot*: int
    containerIndex*: int
    widgetClass*: XPWidgetClass

const
  NO_PARENT* = -1
  PARAM_PARENT* = -2

##define WIDGET_COUNT(x)	((sizeof(x) / sizeof(XPWidgetCreate_t)))

# XPUCreateWidgets creates a series of widgets from a table...see
# XPCreateWidget_t above.  Pass in an array of widget creation structures and
# an array of widget IDs that will receive each widget.
#
# Widget parents are specified by index into the created widget table,
# allowing  you to create nested widget structures.  You can create multiple
# widget trees in one table.  Generally you should create widget trees from
# the top down.
#
# You can also pass in a widget ID that will be used when the widget's parent
# is listed as PARAM_PARENT; this allows you to embed widgets created with
# XPUCreateWidgets in a widget created previously.
proc XPUCreateWidgets*(inWidgetDefs: PXPWidgetCreate_t,
                       inCount: int,
                       inParamParent: XPWidgetID,
                       ioWidgets: ptr XPWidgetID)
                  {.cdecl, importc: "XPUCreateWidgets", dynlib: xpwidgets_lib.}

# XPUMoveWidgetBy simply moves a widget by an amount, +x = right, +y=up,
# without resizing the widget.
proc XPUMoveWidgetBy*(inWidget: XPWidgetID, inDeltaX: int, inDeltaY: int)
                    {.cdecl, importc: "XPUMoveWidgetBy", dynlib: xpwidgets_lib.}

#******************************************************************************
# LAYOUT MANAGERS
# *****************************************************************************
#
# The layout managers are widget behavior functions for handling where
# widgets move. Layout managers can be called from a widget function or
# attached to a widget later.
#

# XPUFixedLayout causes the widget to maintain its children in fixed position
# relative to itself as it is resized.  Use this on the top level 'window'
# widget for your window.
proc XPUFixedLayout*(inMessage: XPWidgetMessage,
                     inWidget: XPWidgetID,
                     inParam1: ptr int,
                     inParam2: ptr int): int
                    {.cdecl, importc: "XPUFixedLayout", dynlib: xpwidgets_lib.}

#******************************************************************************
# WIDGET PROC BEHAVIORS
# *****************************************************************************
#
# These widget behavior functions add other useful behaviors to widgets.
# These functions cannot be attached to a widget; they must be called from
# your widget function.
#

# XPUSelectIfNeeded causes the widget to bring its window to the foreground if
# it is not already. inEatClick specifies whether clicks in the background should
# be consumed by bringin the window to the foreground.
proc XPUSelectIfNeeded*(inMessage: XPWidgetMessage,
                        inWidget: XPWidgetID,
                        inParam1: ptr int,
                        inParam2: ptr int,
                        inEatClick: int): int
                  {.cdecl, importc: "XPUSelectIfNeeded", dynlib: xpwidgets_lib.}

# XPUDefocusKeyboard causes a click in the widget to send keyboard focus back
# to X-Plane. This stops editing of any text fields, etc.
proc XPUDefocusKeyboard*(inMessage: XPWidgetMessage,
                         inWidget: XPWidgetID,
                         inParam1: ptr int,
                         inParam2: ptr int,
                         inEatClick: int): int
                {.cdecl, importc: "XPUDefocusKeyboard", dynlib: xpwidgets_lib.}

# XPUDragWidget drags the widget in response to mouse clicks.  Pass in not
# only the event, but the global coordinates of the drag region, which might
# be a sub-region of your widget (for example, a title bar).
proc XPUDragWidget*(inMessage: XPWidgetMessage,
                    inWidget: XPWidgetID,
                    inParam1: ptr int,
                    inParam2: ptr int,
                    inLeft: int,
                    inTop: int,
                    inRight: int,
                    inBottom: int): int
                    {.cdecl, importc: "XPUDragWidget", dynlib: xpwidgets_lib.}

