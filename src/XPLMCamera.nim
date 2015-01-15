# See license.txt for usage.


# XPLMCamera - THEORY OF OPERATION The XPLMCamera APIs allow plug-ins to
# control the camera angle in X-Plane.  This has a number of applications,
# including but not limited to:
#
# - Creating new views (including dynamic/user-controllable views) for the
# user.
#
# - Creating applications that use X-Plane as a renderer of scenery,
# aircrafts, or both.
#
# The camera is controlled via six parameters: a location in OpenGL
# coordinates and pitch, roll and yaw, similar to an airplane's position.
# OpenGL coordinate info is described in detail in the XPLMGraphics
# documentation; generally you should use the XPLMGraphics routines to
# convert from world to local coordinates.  The camera's orientation starts
# facing level with the ground directly up the negative-Z axis
# (approximately north) with the horizon horizontal.  It is then rotated
# clockwise for yaw, pitched up for positive pitch, and rolled clockwise
# around the vector it is looking along for roll.
#
# You control the camera either either until the user selects a new view or
# permanently (the later being similar to how UDP camera control works).  You
# control the camera by registering a callback per frame from which you
# calculate the new camera positions.  This guarantees smooth camera motion.
#
# Use the XPLMDataAccess APIs to get information like the position of the
# aircraft, etc. for complex camera positioning.
#

#******************************************************************************
# Camera Control
# *****************************************************************************
#

# XPLMCameraControlDuration
#
# This enumeration states how long you want to retain control of the camera.
# You can retain it indefinitely or until the user selects a new view.
type
  XPLMCameraControlDuration* {.size: sizeof(int).} = enum
    # Control the camera until the user picks a new view.
    xplm_ControlCameraUntilViewChanges = 1

    # Control the camera until your plugin is disabled or another plugin
    # forcably takes control.
    xplm_ControlCameraForever = 2

# XPLMCameraPosition_t
#
# This structure contains a full specification of the camera.  X, Y, and Z
# are the camera's position in OpenGL coordiantes; pitch, roll, and yaw are
# rotations from a camera facing flat north in degrees.  Positive pitch means
# nose up, positive roll means roll right, and positive yaw means yaw right,
# all in degrees. Zoom is a zoom factor, with 1.0 meaning normal zoom and 2.0
# magnifying by 2x (objects appear larger).
type
  PXPLMCameraPosition_t* = ptr XPLMCameraPosition_t
  XPLMCameraPosition_t*{.final.} = object
    x*: float32
    y*: float32
    z*: float32
    pitch*: float32
    heading*: float32
    roll*: float32
    zoom*: float32

# XPLMCameraControl provides continuous control over
# the camera.  You are passed in a structure in which to put the new camera
# position; modify it and return 1 to reposition the camera.  Return 0 to
# surrender control of the camera; camera control will be handled by X-Plane
# on this draw loop. The contents of the structure as you are called are
# undefined.
#
# If X-Plane is taking camera control away from you, this function will be
# called with inIsLosingControl set to 1 and ioCameraPosition NULL.
type
  XPLMCameraControl_f* = proc (outCameraPosition: PXPLMCameraPosition_t,
                               inIsLosingControl: int,
                               inRefcon: pointer): int {.cdecl.}

# XPLMControlCamera repositions the camera on the next drawing cycle.  You must
# pass a non-null control function.  Specify in inHowLong how long you'd like
# control  (indefinitely or until a key is pressed).
proc XPLMControlCamera*(inHowLong: XPLMCameraControlDuration,
                        inControlFunc: XPLMCameraControl_f,
                        inRefcon: pointer)
                        {.cdecl, importc: "XPLMControlCamera", dynlib: xplm_lib.}

# XPLMDontControlCamera stops you from controlling the camera.  If you have a
# camera control function, it will not be called with an inIsLosingControl flag.
# X-Plane will control the camera on the next cycle.
#
# For maximum compatibility you should not use this routine unless you are in
# posession of the camera.
proc XPLMDontControlCamera*() {.cdecl, importc: "XPLMDontControlCamera", dynlib: xplm_lib.}


# XPLMIsCameraBeingControlled returns 1 if the camera is being controlled, zero
# if it is not.  If it is and you pass in a pointer to a camera control duration,
# the current control duration will be returned.
proc XPLMIsCameraBeingControlled*(outCameraControlDuration: ptr XPLMCameraControlDuration):
                        int {.cdecl, importc: "XPLMIsCameraBeingControlled", dynlib: xplm_lib.}

# XPLMReadCameraPosition reads the current camera position.
proc XPLMReadCameraPosition*(outCameraPosition: PXPLMCameraPosition_t)
                            {.cdecl, importc: "XPLMReadCameraPosition", dynlib: xplm_lib.}
