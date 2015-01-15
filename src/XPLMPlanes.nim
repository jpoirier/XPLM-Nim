# See license.txt for usage.


# The XPLMPlanes APIs allow you to control the various aircraft in x-plane,
# both the user's and the sim's.
#

#******************************************************************************
# USER AIRCRAFT ACCESS
# *****************************************************************************

# XPLMSetUsersAircraft changes the user's aircraft.  Note that this will reinitialize
# the user to be on the nearest airport's first runway.  Pass in a full path
# (hard drive and everything including the .acf extension) to the .acf file.
proc XPLMSetUsersAircraft*(inAircraftPath: cstring)
                    {.cdecl, importc: "XPLMSetUsersAircraft", dynlib: xplm_lib.}

# XPLMPlaceUserAtAirport places the user at a given airport.  Specify the
# airport by its ICAO code (e.g. 'KBOS').
proc XPLMPlaceUserAtAirport*(inAirportCode; cstring)
                  {.cdecl, importc: "XPLMPlaceUserAtAirport", dynlib: xplm_lib.}

#******************************************************************************
# GLOBAL AIRCRAFT ACCESS
# *****************************************************************************
#
# The user's aircraft is always index 0.
const
  XPLM_USER_AIRCRAFT* = 0

# XPLMPlaneDrawState_t contains additional plane parameter info to be passed to
# draw plane.  Make sure to fill in the size of the structure field with
# sizeof(XPLMDrawPlaneState_t) so that the XPLM can tell how many fields you
# knew about when compiling your plugin (since more fields may be added
# later).
#
# Most of these fields are ratios from 0 to 1 for control input.  X-Plane
# calculates what the actual controls look like based on the .acf file for
# that airplane.  Note for the yoke inputs, this is what the pilot of the
# plane has commanded (post artificial stability system if there were one)
# and affects aelerons, rudder, etc.  It is not  necessarily related to the
# actual position of the plane!
type
  PXPLMPlaneDrawState_t* = ptr XPLMPlaneDrawState_t
  XPLMPlaneDrawState_t*{.final.} = object
    # The size of the draw state struct.
    structSize*: int
    # A ratio from [0..1] describing how far the landing gear is extended.
    gearPosition*: float32
    # Ratio of flap deployment, 0 = up, 1 = full deploy.
    flapRatio*: float32
    # Ratio of spoiler deployment, 0 = none, 1 = full deploy.
    spoilerRatio*: float32
    # Ratio of speed brake deployment, 0 = none, 1 = full deploy.
    speedBrakeRatio*: float32
    # Ratio of slat deployment, 0 = none, 1 = full deploy.
    slatRatio*: float32
    # Wing sweep ratio, 0 = forward, 1 = swept.
    wingSweep*: float32
    # Thrust power, 0 = none, 1 = full fwd, -1 = full reverse.
    thrust*: float32
    # Total pitch input for this plane.
    yokePitch*: float32
    # Total Heading input for this plane.
    yokeHeading*: float32
    # Total Roll input for this plane.
    yokeRoll*: float32

# XPLMCountAircraft returns the number of aircraft X-Plane is capable of having,
# as well as the number of aircraft that are currently active.  These numbers
# count the user's aircraft.  It can also return the plugin that is currently
# controlling aircraft.  In X-Plane 7, this routine reflects the number of
# aircraft the user has enabled in the rendering options window.
proc XPLMCountAircraft*(outTotalAircraft: int,
                        outActiveAircraft: int,
                        outController: ptr XPLMPluginID)
                      {.cdecl, importc: "XPLMCountAircraft", dynlib: xplm_lib.}

# XPLMGetNthAircraftModel returns the aircraft model for the Nth aircraft.
# Indices are zero based, with zero being the user's aircraft.  The file name
# should be at least 256 chars in length; the path should be at least 512 chars
# in length.
proc XPLMGetNthAircraftModel*(inIndex: int,
                              outFileName: ptr cstring,
                              outPath: ptr cstring)
                {.cdecl, importc: "XPLMGetNthAircraftModel", dynlib: xplm_lib.}

#******************************************************************************
# EXCLUSIVE AIRCRAFT ACCESS
# *****************************************************************************
#
# The following routines require exclusive access to the airplane APIs. Only
# one plugin may have this access at a time.
#

# XPLMPlanesAvailable_f
#
# Your airplanes available callback is called when another plugin gives up
# access to the multiplayer planes.  Use this to wait for access to
# multiplayer.
type
    XPLMPlanesAvailable_f* = proc (inRefcon: pointer) {.cdecl.}

# XPLMAcquirePlanes grants your plugin exclusive access to the aircraft.  It
# returns 1 if you gain access, 0 if you do not. inAircraft - pass in an
# array of pointers to strings specifying the planes you want loaded.  For
# any plane index you do not want loaded, pass a 0-length string.  Other
# strings should be full paths with the .acf extension.  NULL terminates this
# array, or pass NULL if there are no planes you want loaded. If you pass in
# a callback and do not receive access to the planes your callback will be
# called when the airplanes are available. If you do receive airplane access,
# your callback will not be called.
proc XPLMAcquirePlanes*(inAircraft: cstringArray,  # (cstringArray -> char**) Can be NULL
                        inCallback: XPLMPlanesAvailable_f,
                        inRefcon: pointer): int
                      {.cdecl, importc: "XPLMAcquirePlanes", dynlib: xplm_lib.}

# XPLMReleasePlanes releases access to the planes.  Note that if you are
# disabled, access to planes is released for you and you must reacquire it.
proc XPLMReleasePlanes*() {.cdecl, importc: "XPLMReleasePlanes", dynlib: xplm_lib.}

# XPLMSetActiveAircraftCount sets the number of active planes.  If you pass in
# a number higher than the total number of planes availables, only the total
# number of planes available is actually used.
proc XPLMSetActiveAircraftCount*(inCount: int)
              {.cdecl, importc: "XPLMSetActiveAircraftCount", dynlib: xplm_lib.}

# XPLMSetAircraftModel loads an aircraft model.  It may only be called if you
# have exclusive access to the airplane APIs.  Pass in the path of the  model
# with the .acf extension.  The index is zero based, but you  may not pass in 0
# (use XPLMSetUsersAircraft to load the user's aircracft).
proc XPLMSetAircraftModel*(inIndex: int, inAircraftPath: cstring)
                    {.cdecl, importc: "XPLMSetAircraftModel", dynlib: xplm_lib.}

# XPLMDisableAIForPlane turns off X-Plane's AI for a given plane.  The plane
# will continue to draw and be a real plane in X-Plane, but will not  move itself.
proc XPLMDisableAIForPlane*(inPlaneIndex: int)
                  {.cdecl, importc: "XPLMDisableAIForPlane", dynlib: xplm_lib.}

# XPLMDrawAircraft draws an aircraft.  It can only be called from a 3-d drawing
# callback.  Pass in the position of the plane in OpenGL local coordinates
# and the orientation of the plane.  A 1 for full drawing indicates that the
# whole plane must be drawn; a 0 indicates you only need the nav lights
# drawn. (This saves rendering time when planes are far away.)
proc XPLMDrawAircraft*(inPlaneIndex: int,
                       inX: float32,
                       inY: float32,
                       inZ: float32,
                       inPitch: float32,
                       inRoll: float32,
                       inYaw: float32,
                       inFullDraw: int,
                       inDrawStateInfo: PXPLMPlaneDrawState_t)
                        {.cdecl, importc: "XPLMDrawAircraft", dynlib: xplm_lib.}

# XPLMReinitUsersPlane recomputes the derived flight model data from the aircraft
# structure in memory.  If you have used the data access layer to modify the
# aircraft structure, use this routine to resynchronize x-plane; since
# X-plane works at least partly from derived values, the sim will not behave
# properly until this is called.
#
# WARNING: this routine does not necessarily place the airplane at the
# airport; use XPLMSetUsersAircraft to be compatible.  This routine is
# provided to do special experimentation with flight models without resetting
# flight.
proc XPLMReinitUsersPlane*()
                    {.cdecl, importc: "XPLMReinitUsersPlane", dynlib: xplm_lib.}


