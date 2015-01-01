# See license.txt for usage.


#******************************************************************************
# Graphics routines for X-Plane and OpenGL.
# *****************************************************************************
#
# A few notes on coordinate systems:
#
# X-Plane uses three kinds of coordinates.  Global coordinates are specified
# as latitude, longitude and elevation.  This coordinate system never changes
# but is not very precise.
#
# OpenGL (or 'local') coordinates are cartesian and shift with the plane.
# They offer more precision and are used for 3-d OpenGL drawing.  The X axis
# is aligned east-west with positive X meaning east.  The Y axis is aligned
# straight up and down at the point 0,0,0 (but since the earth is round it is
# not truly straight up and down at other points).  The Z axis is aligned
# north-south at 0, 0, 0 with positive Z pointing south (but since the earth
# is round it isn't exactly north-south as you move east or west of 0, 0, 0).
# One unit is one meter and the point 0,0,0 is on the surface of the  earth
# at sea level for some latitude and longitude picked by the sim such that
# the  user's aircraft is reasonably nearby.
#
# Cockpit coordinates are 2d, with the X axis horizontal and the Y axis
# vertical. The point 0,0 is the bottom left and 1024,768 is the upper right
# of the screen. This is true no matter what resolution the user's monitor is
# in; when running in higher resolution, graphics will be scaled.
#
# Use X-Plane's routines to convert between global and local coordinates.  Do
# not attempt to do this conversion yourself; the precise 'roundness' of
# X-Plane's  physics model may not match your own, and (to make things
# weirder) the user can potentially customize the physics of the current
# planet.
#

#******************************************************************************
# X-PLANE GRAPHICS
# *****************************************************************************
#
# These routines allow you to use OpenGL with X-Plane.
#

# XPLMTextureID
#
# XPLM Texture IDs name well-known textures in the sim for you to use. This
# allows you to recycle textures from X-Plane, saving VRAM.
#
const
    # The bitmap that contains window outlines, button outlines, fonts, etc.
    xplm_Tex_GeneralInterface* = 0

    # The exterior paint for the user's aircraft (daytime).
    xplm_Tex_AircraftPaint* = 1

    # The exterior light map for the user's aircraft.
    xplm_Tex_AircraftLiteMap* = 2

type
    XPLMTextureID* = int32

# XPLMSetGraphicsState changes OpenGL's graphics state in a number of ways:
#
# inEnableFog - enables or disables fog, equivalent to: glEnable(GL_FOG);
#
# inNumberTexUnits - enables or disables a number of multitexturing units. If
# the number is 0, 2d texturing is disabled entirely, as in
# glDisable(GL_TEXTURE_2D);  Otherwise, 2d texturing is enabled, and  a
# number of multitexturing units are enabled sequentially, starting  with
# unit 0, e.g. glActiveTextureARB(GL_TEXTURE0_ARB);  glEnable
# (GL_TEXTURE_2D);
#
# inEnableLighting - enables or disables OpenGL lighting, e.g.
# glEnable(GL_LIGHTING); glEnable(GL_LIGHT0);
#
# inEnableAlphaTesting - enables or disables the alpha test per pixel, e.g.
# glEnable(GL_ALPHA_TEST);
#
# inEnableAlphaBlending - enables or disables alpha blending per pixel, e.g.
# glEnable(GL_BLEND);
#
# inEnableDepthTesting - enables per pixel depth testing, as in
# glEnable(GL_DEPTH_TEST);
#
# inEnableDepthWriting - enables writing back of depth information to the
# depth bufffer, as in glDepthMask(GL_TRUE);
#
# The purpose of this function is to change OpenGL state while keeping
# X-Plane aware of the state changes; this keeps X-Plane from getting
# surprised by OGL state changes, and prevents X-Plane and plug-ins from
# having to set all state before all draws; XPLMSetGraphicsState internally
# skips calls to change state that is already properly enabled.
#
# X-Plane does not have a 'default' OGL state to plug-ins; plug-ins should
# totally set OGL state before drawing.  Use XPLMSetGraphicsState instead of
# any of the above OpenGL calls.
#
# WARNING: Any routine that performs drawing (e.g. XPLMDrawString or widget
# code) may change X-Plane's state.  Always set state before drawing after
# unknown code has executed.
proc XPLMSetGraphicsState*(inEnableFog: int32,
                           inNumberTexUnits: int32,
                           inEnableLighting: int32,
                           inEnableAlphaTesting: int32,
                           inEnableAlphaBlending: int32,
                           inEnableDepthTesting: int32,
                           inEnableDepthWriting: int32) {.cdecl, importc: "XPLMSetGraphicsState", dynlib: xplm_lib}

# XPLMBindTexture2d changes what texture is bound to the 2d texturing target.
# This routine caches the current 2d texture across all texturing units in
# the sim and plug-ins, preventing extraneous binding.  For example, consider
# several plug-ins running in series; if they all use the 'general interface'
# bitmap to do UI, calling this function will skip the rebinding of the
# general interface texture on all but the first plug-in, which can provide
# better frame rate son some graphics cards.
#
# inTextureID is the ID of the texture object to bind; inTextureUnit is a
# zero-based  texture unit (e.g. 0 for the first one), up to a maximum of 4
# units.  (This number may increase in future versions of x-plane.)
#
# Use this routine instead of glBindTexture(GL_TEXTURE_2D, ....);
proc XPLMBindTexture2d*(inTextureNum: int32, inTextureUnit; int32) {.cdecl, importc: "XPLMBindTexture2d", dynlib: xplm_lib}

# XPLMGenerateTextureNumbers generates unused texture numbers that a plug-in
# can use to safely bind textures. Use this routine instead of glGenTextures;
# glGenTextures will allocate texture numbers in ranges that X-Plane reserves
# for its own use but does not always use; for example, it might provide an
# ID within the range of textures reserved for terrain...loading a new .env
# file as the plane flies might then cause X-Plane to use this texture ID.
# X-Plane will then  overwrite the plug-ins texture.  This routine returns
# texture IDs that are out of X-Plane's usage range.
proc XPLMGenerateTextureNumbers*(outTextureIDs: ptr int32, inCount: int32) {.cdecl, importc: "XPLMGenerateTextureNumbers", dynlib: xplm_lib}

# XPLMGetTexture returns the OpenGL texture enumeration of an X-Plane texture
# based on a  generic identifying code.  For example, you can get the texture
# for X-Plane's UI bitmaps.  This allows you to build new gauges that take
# advantage of x-plane's textures, for smooth artwork integration and also
# saving texture  memory.  Note that the texture might not be loaded yet,
# depending on what the  plane's panel contains.
#
# OPEN ISSUE: We really need a way to make sure X-Plane loads this texture if
# it isn't around, or at least a way to find out whether it is loaded or not.
proc XPLMGetTexture*(inTexture: XPLMTextureID): int32 {.cdecl, importc: "XPLMGetTexture", dynlib: xplm_lib}

# XPLMWorldToLocal translates coordinates from latitude, longitude, and altitude
# to local scene coordinates. Latitude and longitude are in decimal degrees,
# and altitude is in meters MSL (mean sea level).  The XYZ coordinates are in
# meters in the local OpenGL coordinate system.
proc XPLMWorldToLocal*(inLatitude: float64,
                       inLongitude: float64,
                       inAltitude: float64,
                       outX: ptr float64,
                       outY: ptr float64,
                       outZ: ptr float64) {.cdecl, importc: "XPLMWorldToLocal", dynlib: xplm_lib}

# XPLMLocalToWorld translates a local coordinate triplet back into latitude,
# longitude, and altitude.  Latitude and longitude are in decimal degrees,
# and altitude is in meters MSL (mean sea level).  The XYZ coordinates are in
# meters in the local OpenGL coordinate system.
#
# NOTE: world coordinates are less precise than local coordinates; you should
# try to avoid round tripping from local to world and back.
proc XPLMLocalToWorld*(inX: float64,
                       inY: float64,
                       inZ: float64,
                       outLatitude: ptr float64,
                       outLongitude: ptr float64,
                       outAltitude: ptr float64) {.cdecl, importc: "XPLMLocalToWorld", dynlib: xplm_lib}

# XPLMDrawTranslucentDarkBox draws a translucent dark box, partially obscuring
# parts of the screen but making text easy to read.  This is the same graphics
# primitive used by X-Plane to show text files and ATC info.
proc XPLMDrawTranslucentDarkBox*(inLeft: int32,
                                 inTop: int32,
                                 inRight: int32,
                                 inBottom: int32) {.cdecl, importc: "XPLMDrawTranslucentDarkBox", dynlib: xplm_lib}

#******************************************************************************
# X-PLANE TEXT
# *****************************************************************************

# XPLMFontID
#
# X-Plane features some fixed-character fonts.  Each font may have its own
# metrics.
#
# WARNING: Some of these fonts are no longer supported or may have changed
# geometries. For maximum copmatibility, see the comments below.
#
# Note: X-Plane 7 supports proportional-spaced fonts.  Since no measuring
# routine is available yet, the SDK will normally draw using a fixed-width
# font.  You can use a dataref to enable proportional font drawing on XP7 if
# you want to.
#
type
    XPLMFontIDEnums* = enum
        # Mono-spaced font for user interface.
        xplmFont_Basic
        xplmFont_Menus              # Deprecated, do not use.
        xplmFont_Metal              # Deprecated, do not use.
        xplmFont_Led                # Deprecated, do not use.
        xplmFont_LedWide            # Deprecated, do not use.
        xplmFont_PanelHUD           # Deprecated, do not use.
        xplmFont_PanelEFIS          # Deprecated, do not use.
        xplmFont_PanelGPS           # Deprecated, do not use.
        xplmFont_RadiosGA           # Deprecated, do not use.
        xplmFont_RadiosBC           # Deprecated, do not use.
        xplmFont_RadiosHM           # Deprecated, do not use.
        xplmFont_RadiosGANarrow     # Deprecated, do not use.
        xplmFont_RadiosBCNarrow     # Deprecated, do not use.
        xplmFont_RadiosHMNarrow     # Deprecated, do not use.
        xplmFont_Timer              # Deprecated, do not use.
        xplmFont_FullRound          # Deprecated, do not use.
        xplmFont_SmallRound         # Deprecated, do not use.
        xplmFont_Menus_Localized    # Deprecated, do not use.
        xplmFont_Proportional       # Deprecated, do not use.

type
    XPLMFontID* = int32

# XPLMDrawString draws a NULL termianted string in a given font.  Pass in the
# lower left pixel that the character is to be drawn onto.  Also pass the
# character and font ID. This function returns the x offset plus the width of
# all drawn characters. The color to draw in is specified as a pointer to an
# array of three floating point colors, representing RGB intensities from 0.0
# to 1.0.
proc XPLMDrawString*(inColorRGB: ptr float32,
                     inXOffset: int32,
                     inYOffset: int32,
                     inChar: cstring,
                     inWordWrapWidth: ptr int32,  # Can be NULL
                     inFontID: XPLMFontID) {.cdecl, importc: "XPLMDrawString", dynlib: xplm_lib}

# XPLMDrawNumber draws a number similar to the digit editing fields in
# PlaneMaker and data output display in X-Plane.  Pass in a color, a
# position, a floating point value, and formatting info.  Specify how many
# integer and how many decimal digits to show and  whether to show a sign, as
# well as a character set. This routine returns the xOffset plus width of the
# string drawn.
proc XPLMDrawNumber*(inColorRGB: ptr float32,
                     inXOffset: int32,
                     inYOffset: int32,
                     inValue: float64,
                     inDigits: int32,
                     inDecimals: int32,
                     inShowSign: int32,
                     inFontID: XPLMFontID) {.cdecl, importc: "XPLMDrawNumber", dynlib: xplm_lib}

# XPLMGetFontDimensions returns the width and height of a character in a given
# font. It also tells you if the font only supports numeric digits.  Pass NULL
# if you don't need a given field.  Note that for a proportional font the width
# will be an arbitrary, hopefully average width.
proc XPLMGetFontDimensions*(inFontID: XPLMFontID,
                            outCharWidth: ptr int32,
                            outCharHeight: ptr int32,
                            outDigitsOnly: ptr int32) {.cdecl, importc: "XPLMGetFontDimensions", dynlib: xplm_lib}

# XPLMMeasureString returns the width in pixels of a string using a given font.
# The string is passed as a pointer plus length (and does not need to be null
# terminated); this is used to allow for measuring substrings. The return
# value is floating point; it is possible that future font drawing may allow
# for fractional pixels.
proc XPLMMeasureString*(inFontID; XPLMFontID, inChar: cstring, inNumChars: int32) {.cdecl, importc: "XPLMMeasureString", dynlib: xplm_lib}