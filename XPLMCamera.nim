

{.deadCodeElim: on.}


#******************************************************************************
# Camera Control
# *****************************************************************************

# XPLMCameraControlDuration
#
# This enumeration states how long you want to retain control of the camera.
# You can retain it indefinitely or until the user selects a new view.
#
const
    xplm_ControlCameraUntilViewChanges* = 1
    xplm_ControlCameraForever* = 2

# typedef int XPLMCameraControlDuration;

# XPLMCameraPosition_t
#
# This structure contains a full specification of the camera.  X, Y, and Z
# are the camera's position in OpenGL coordiantes; pitch, roll, and yaw are
# rotations from a camera facing flat north in degrees.  Positive pitch means
# nose up, positive roll means roll right, and positive yaw means yaw right,
# all in degrees. Zoom is a zoom factor, with 1.0 meaning normal zoom and 2.0
# magnifying by 2x (objects appear larger).
#
type
    PXPLMCameraPosition_t* = ptr XPLMCameraPosition_t
    XPLMCameraPosition_t*{.final.} = object
        x*: cfloat
        y*: cfloat
        z*: cfloat
        pitch*: cfloat
        heading*: cfloat
        roll*: cfloat
        zoom*: cfloat

# XPLMCameraControl_f
#
# You use an XPLMCameraControl function to provide continuous control over
# the camera.  You are passed in a structure in which to put the new camera
# position; modify it and return 1 to reposition the camera.  Return 0 to
# surrender control of the camera; camera control will be handled by X-Plane
# on this draw loop. The contents of the structure as you are called are
# undefined.
#
# If X-Plane is taking camera control away from you, this function will be
# called with inIsLosingControl set to 1 and ioCameraPosition NULL.
#
# typedef int (* XPLMCameraControl_f)(XPLMCameraPosition_t* outCameraPosition, int inIsLosingControl, void* inRefcon);
XPLMCameraControl_f* = proc(outCameraPosition: PXPLMCameraPosition_t, inIsLosingControl: cint, inRefcon: ptr cvoid): cint {.stdcall.}

# XPLMControlCamera
#
# This function repositions the camera on the next drawing cycle.  You must
# pass a non-null control function.  Specify in inHowLong how long you'd like
# control  (indefinitely or until a key is pressed).
#
# XPLM_API void XPLMControlCamera(XPLMCameraControlDuration inHowLong, XPLMCameraControl_f inControlFunc, void *inRefcon);
proc XPLMControlCamera(inHowLong: cint, inControlFunc: PXPLMCameraPosition_t, inRefcon: ptr cvoid) {importc: "XPLMControlCamera", nodecl.}

# XPLMDontControlCamera
#
# This function stops you from controlling the camera.  If you have a camera
# control function, it will not be called with an inIsLosingControl flag.
# X-Plane will control the camera on the next cycle.
#
# For maximum compatibility you should not use this routine unless you are in
# posession of the camera.
#
# XPLM_API void XPLMDontControlCamera(void);
proc XPLMDontControlCamera*() {importc: "XPLMDontControlCamera", nodecl.}

# XPLMIsCameraBeingControlled
#
# This routine returns 1 if the camera is being controlled, zero if it is
# not.  If it is and you pass in a pointer to a camera control duration, the
# current control duration will be returned.
#
# XPLM_API int XPLMIsCameraBeingControlled(XPLMCameraControlDuration *outCameraControlDuration);
proc XPLMIsCameraBeingControlled*(outCameraControlDuration: ptr cint): cint {importc: "XPLMIsCameraBeingControlled", nodecl.}

# XPLMReadCameraPosition
#
# This function reads the current camera position.
#
# XPLM_API void XPLMReadCameraPosition(XPLMCameraPosition_t *outCameraPosition);
proc XPLMReadCameraPosition*(outCameraPosition: PXPLMCameraPosition_t) {importc: "XPLMReadCameraPosition", nodecl.}
