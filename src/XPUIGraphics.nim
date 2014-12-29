# See license.txt for usage.


when defined(windows):
    const xpwidgets_lib* = "./Resources/plugins/XPWidgets_64.dll"
elif defined(macosx):
    const xpwidgets_lib* = "./Resources/plugins/XPWidgets_64.dylib"
else:
    const xpwidgets_lib* = "./Resources/plugins/XPWidgets_64.so"


import XPWidgetDefs

#******************************************************************************
# UI GRAPHICS
# *****************************************************************************

# XPWindowStyle
#
# There are a few built-in window styles in X-Plane that you can use.
#
# Note that X-Plane 6 does not offer real shadow-compositing; you must make
# sure to put a window on top of another window of the right style to the
# shadows work, etc. This applies to elements with insets and shadows.  The
# rules are:
#
# Sub windows must go on top of main windows, and screens and list views on
# top of subwindows.  Only help and main windows can be over the main screen.
#
#
# With X-Plane 7 any window or element may be placed over any other element.
#
# Some windows are scaled by stretching, some by repeating.  The drawing
# routines know which scaling method to use.  The list view cannot be
# rescaled in x-plane 6 because it has both a repeating pattern and a
# gradient in one element.  All other elements can be rescaled.
#
const
    # An LCD screen that shows help.
    xpWindow_Help* = 0

    # A dialog box window.
    xpWindow_MainWindow* = 1

    # A panel or frame within a dialog box window.
    xpWindow_SubWindow* = 2

    # An LCD screen within a panel to hold text displays.
    xpWindow_Screen* = 4

    # A list view within a panel for scrolling file names, etc.
    xpWindow_ListView* = 5

type
    XPWindowStyle* = cint

# XPDrawWindow draws a window of the given dimensions at the given offset on
# the virtual screen in a given style.  The window is automatically scaled as
# appropriate using a bitmap scaling technique (scaling or repeating) as
# appropriate to the style.
proc XPDrawWindow*(inX1: cint,
                   inY1: cint,
                   inX2: cint,
                   inY2: cint,
                   inStyle: XPWindowStyle) {.cdecl, importc: "XPDrawWindow", dynlib: xpwidgets_lib}

# XPGetWindowDefaultDimensions returns the default dimensions for a window.
# Output is either a minimum or fixed value depending on whether the window
# is scalable. Note, outWidth and outHeight can be NULL.
proc XPGetWindowDefaultDimensions*(inStyle: XPWindowStyle,
                                   outWidth: ptr cint,
                                   outHeight: ptr cint) {.cdecl, importc: "XPGetWindowDefaultDimensions", dynlib: xpwidgets_lib}

# XPElementStyle
#
# Elements are individually drawable UI things like push buttons, etc. The
# style defines what kind of element you are drawing.  Elements can be
# stretched in one or two dimensions (depending on the element).  Some
# elements can be lit.
#
# In x-plane 6 some elements must be drawn over metal.  Some are scalable and
# some are not.  Any element can be drawn anywhere in x-plane 7.
#
# Scalable Axis			Required Background
#
const
    # x						metal
    xpElement_TextField* = 6

    # none					metal
    xpElement_CheckBox* = 9

    # none					metal
    xpElement_CheckBoxLit* = 10

    # none					window header
    xpElement_WindowCloseBox* = 14

    # none					window header
    xpElement_WindowCloseBoxPressed* = 15

    # x					metal
    xpElement_PushButton* = 16

    # x					metal
    xpElement_PushButtonLit* = 17

    # none					any
    xpElement_OilPlatform* = 24

    # none					any
    xpElement_OilPlatformSmall* = 25

    # none					any
    xpElement_Ship* = 26

    # none					any
    xpElement_ILSGlideScope* = 27

    # none					any
    xpElement_MarkerLeft* = 28

    # none					any
    xpElement_Airport* = 29

    # none					any
    xpElement_Waypoint* = 30

    # none					any
    xpElement_NDB* = 31

    # none					any
    xpElement_VOR* = 32

    # none					any
    xpElement_RadioTower* = 33

    # none					any
    xpElement_AircraftCarrier* = 34

    # none					any
    xpElement_Fire* = 35

    # none					any
    xpElement_MarkerRight* = 36

    # none					any
    xpElement_CustomObject* = 37

    # none					any
    xpElement_CoolingTower* = 38

    # none					any
    xpElement_SmokeStack* = 39

    # none					any
    xpElement_Building* = 40

    # none					any
    xpElement_PowerLine* = 41

    # none					metal
    xpElement_CopyButtons* = 45

    # none					metal
    xpElement_CopyButtonsWithEditingGrid* = 46

    # x, y					metal
    xpElement_EditingGrid* = 47

    # THIS CAN PROBABLY BE REMOVED
    xpElement_ScrollBar* = 48

    # none					any
    xpElement_VORWithCompassRose* = 49

    # none					metal
    xpElement_Zoomer* = 51

    # x, y					metal
    xpElement_TextFieldMiddle* = 52

    # none					metal
    xpElement_LittleDownArrow* = 53

    # none					metal
    xpElement_LittleUpArrow* = 54

    # none					metal
    xpElement_WindowDragBar* = 61

    # none					metal
    xpElement_WindowDragBarSmooth* = 62

type
    XPElementStyle* = cint

# XPDrawElement draws a given element at an offset on the virtual screen in
# set dimensions. EVEN if the element is not scalable, it will be scaled if
# the width and height do not match the preferred dimensions; it'll just look
# ugly.  Pass inLit to see the lit version of the element; if the element
# cannot be lit this is ignored.
proc XPDrawElement*(inX1: cint,
                    inY1: cint,
                    inX2: cint,
                    inY2: cint,
                    inStyle: XPElementStyle, inLit: cint) {.cdecl, importc: "XPDrawElement", dynlib: xpwidgets_lib}

# XPGetElementDefaultDimensions returns the recommended or minimum dimensions
# of a given UI element. outCanBeLit tells whether the element has both a lit
# and unlit state.  Pass NULL to not receive any of these parameters.
# Note, outWidth, outHeight, and outCanBeLit can be NULL.
proc XPGetElementDefaultDimensions*(inStyle: XPElementStyle,
                                    outWidth: ptr cint,
                                    outHeight: ptr cint,
                                    outCanBeLit: ptr cint) {.cdecl, importc: "XPGetElementDefaultDimensions", dynlib: xpwidgets_lib}

# XPTrackStyle
#
# A track is a UI element that displays a value vertically or horizontally.
# X-Plane has three kinds of tracks: scroll bars, sliders, and progress bars.
# Tracks can be displayed either horizontally or vertically; tracks will
# choose their own layout based on the larger dimension of their dimensions
# (e.g. they know if they are tall or wide).  Sliders may be lit or unlit
# (showing the user manipulating them).
#
# ScrollBar - this is a standard scroll bar with arrows and a thumb to drag.
# Slider -  this is a simple track with a ball in the middle that can be
# slid. Progress - this is a progress indicator showing how a long task is
# going.
#
const
    # not over metal	can be lit		can be rotated
    xpTrack_ScrollBar* = 0

    # over metal		can be lit		can be rotated
    xpTrack_Slider* = 1

    # over metal		cannot be lit	cannot be rotated
    xpTrack_Progress* = 2

type
    XPTrackStyle* = cint

# XPDrawTrack draws a track.  You pass in the track dimensions and size; the
# track picks the optimal orientation for these dimensions.  Pass in the
# track's minimum current and maximum values; the indicator will be
# positioned appropriately.  You can also specify whether the track is lit or
# not.
proc XPDrawTrack*(inX1: cint,
                  inY1: cint,
                  inX2: cint,
                  inY2: cint,
                  inMin: cint,
                  inMax: cint,
                  inValue: cint,
                  inTrackStyle: XPTrackStyle, inLit: cint) {.cdecl, importc: "XPDrawTrack", dynlib: xpwidgets_lib}

# XPGetTrackDefaultDimensions returns a track's default smaller dimension; all
# tracks are scalable in the larger dimension.  It also returns whether a track
# can be lit.
proc XPGetTrackDefaultDimensions*(inStyle: XPTrackStyle,
                                  outWidth: ptr cint,
                                  outCanBeLit: ptr cint) {.cdecl, importc: "XPGetTrackDefaultDimensions", dynlib: xpwidgets_lib}

# XPGetTrackMetrics returns the metrics of a track.  If you want to write UI code
# to manipulate a track, this routine helps you know where the mouse
# locations are. For most other elements, the rectangle the element is drawn
# in is enough information. However, the scrollbar drawing routine does some
# automatic placement; this routine lets you know where things ended up.  You
# pass almost everything you would pass to the draw routine.  You get out the
# orientation, and other useful stuff.
#
# Besides orientation, you get five dimensions for the five parts of a
# scrollbar, which are the down button, down area (area before the thumb),
# the thumb, and the up area and button.  For horizontal scrollers, the left
# button decreases; for vertical scrollers, the top button decreases.
proc XPGetTrackMetrics*(inX1: cint,
                        inY1: cint,
                        inX2: cint,
                        inY2: cint,
                        inMin: cint,
                        inMax: cint,
                        inValue: cint,
                        inTrackStyle: XPTrackStyle,
                        outIsVertical: ptr cint,
                        outDownBtnSize: ptr cint,
                        outDownPageSize: ptr cint,
                        outThumbSize: ptr cint,
                        outUpPageSize: ptr cint,
                        outUpBtnSize: ptr cint) {.cdecl, importc: "XPGetTrackMetrics", dynlib: xpwidgets_lib}

