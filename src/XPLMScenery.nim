# See license.txt for usage.


# This package contains APIs to interact with X-Plane's scenery system.
#

#******************************************************************************
# Terrain Y-Testing
# *****************************************************************************
#
# The Y-testing API allows you to locate the physical scenery mesh.  This
# would be used to place dynamic  graphics on top of the ground in a
# plausible way or do physics interactions.
#
# The Y-test API works via probe objects, which are allocated by your plugin
# and used to query terrain. Probe objects exist both to capture which
# algorithm you have requested (see probe types) and also to cache query
# information.
#
# Performance guidelines: It is generally faster to use the same probe for
# nearby points and different probes for different points. Try not to
# allocate more than "hundreds" of probes at most.  Share probes if you need
# more. Generally, probing operations are expensive, and should be avoided
# via caching when possible.
#
# Y testing returns a location on the terrain, a normal vectory, and a
# velocity vector.  The normal vector tells you the slope of the terrain at
# that point.  The velocity vector tells you if that terrain is moving (and
# is in meters/second). For example, if your Y test hits the aircraft carrier
# deck, this tells you the velocity of that point on the deck.
#
# Note: the Y-testing API is limited to probing the loaded scenery area,
# which is approximately 300x300 km in X-Plane 9.  Probes outside this area
# will return the height of a 0 MSL sphere.
#

# XPLMProbeType defines the type of terrain probe - each probe has a
# different algorithm.  (Only one type of probe is provided right now, but
# future APIs will expose more flexible or poewrful or useful probes.
#
type
    XPLMProbeType* {.size: sizeof(int).} = enum
        # The Y probe gives you the location of the tallest physical scenery along
        # the Y axis going through the queried point.
        xplm_ProbeY = 0

# XPLMProbeResult
#
# Probe results - possible results from a probe query.
#
type
    XPLMProbeResult* {.size: sizeof(int).} = enum
        # The probe hit terrain and returned valid values.
        xplm_ProbeHitTerrain = 0

         # An error in the API call.  Either the probe struct size is bad, or the
         # probe is invalid or the type is mismatched for the specific query call.
        xplm_ProbeError = 1

         # The probe call succeeded but there is no terrain under this point (perhaps
         # it is off the side of the planet?)
        xplm_ProbeMissed = 2

# An XPLMProbeRef is an opaque handle to a probe, used for querying the
# terrain.
type
     XPLMProbeRef* = pointer

# XPLMProbeInfo_t contains the results of a probe call.  Make sure to set
# structSize to the size of the struct before using it.
type
    PXPLMProbeInfo_t* = ptr XPLMProbeInfo_t
    XPLMProbeInfo_t*{.final.} = object
        # Size of structure in bytes - always set this before calling the XPLM.
        structSize: int
        # Resulting X location of the terrain point we hit, in local OpenGL coordinates.
        locationX: float32
        # Resulting Y location of the terrain point we hit, in local OpenGL coordinates.
        locationY: float32
        # Resulting Z location of the terrain point we hit, in local OpenGL coordinates.
        locationZ: float32
        # X component of the normal vector to the terrain we found.
        normalX: float32
        # Y component of the normal vector to the terrain we found.
        normalY: float32
        # Z component of the normal vector to the terrain we found.
        normalZ: float32
        # X component of the velocity vector of the terrain we found.
        velocityX: float32
        # Y component of the velocity vector of the terrain we found.
        velocityY: float32
        # Z component of the velocity vector of the terrain we found.
        velocityZ: float32
        # Tells if the surface we hit is water (otherwise it is land).
        is_wet: int

# XPLMCreateProbe creates a new probe object of a given type and returns.
proc XPLMCreateProbe*(inProbeType: XPLMProbeType): XPLMProbeRef {.cdecl, importc: "XPLMCreateProbe", dynlib: xplm_lib.}

# XPLMDestroyProbe deallocates an existing probe object.
proc XPLMDestroyProbe*(inProbe: XPLMProbeRef) {.cdecl, importc: "XPLMDestroyProbe", dynlib: xplm_lib.}

# XPLMProbeTerrainXYZ probes the terrain.  Pass in the XYZ coordinate of the
# probe point, a probe object, and an XPLMProbeInfo_t struct that  has its
# structSize member set properly.  Other fields are filled in if we hit terrain,
# and a probe result is returned.
proc XPLMProbeTerrainXYZ*(inProbe: XPLMProbeRef,
                          inX: float32,
                          inY: float32,
                          inZ: float32,
                          outInfo: PXPLMProbeInfo_t): XPLMProbeResult {.cdecl, importc: "XPLMProbeTerrainXYZ", dynlib: xplm_lib.}

#******************************************************************************
# Object Drawing
# *****************************************************************************
#
# The object drawing routines let you load and draw X-Plane OBJ files.
# Objects are loaded by file path and managed via an opaque handle.  X-Plane
# naturally reference counts objects, so it is important that you balance
# every successful call to XPLMLoadObject with a call to XPLMUnloadObject!
#

# An XPLMObjectRef is a opaque handle to an .obj file that has been loaded
# into memory.
type
     XPLMObjectRef* = pointer

# The XPLMDrawInfo_t structure contains positioning info for one object that
# is to be drawn. Be sure to set structSize to the size of the structure for
# future expansion.
type
    PXPLMDrawInfo_t* = ptr XPLMDrawInfo_t
    XPLMDrawInfo_t*{.final.} = object
        # Set this to the size of this structure!
        structSize: int
        # X location of the object in local coordinates.
        x: float32
        # Y location of the object in local coordinates.
        y: float32
        # Z location of the object in local coordinates.
        z: float32
        # Pitch in degres to rotate the object, positive is up.
        pitch: float32
        # Heading in local coordinates to rotate the object, clockwise.
        heading: float32
        # Roll to rotate the object.
        roll: float32

# XPLMObjectLoaded_f
#
# You provide this callback when loading an object asynchronously; it will be
# called once the object is loaded.  Your refcon is passed back.  The object
# ref passed in is the newly loaded object (ready for use) or NULL if an
# error occured.
#
# If your plugin is disabled, this callback will be delivered as soon as the
# plugin is re-enabled.  If your plugin is unloaded before this callback is
# ever called, the SDK will release the object handle for you.
type
     XPLMObjectLoaded_f* = proc (inObject: XPLMObjectRef, inRefcon: pointer) {.cdecl.}

# XPLMLoadObject loads an OBJ file and returns a handle to it.  If X-plane has
# already loaded the object, the handle to the existing object is returned.
# Do not assume you will get the same handle back twice, but do make sure to
# call unload once for every load to avoid "leaking" objects.  The object
# will be purged from memory when no plugins and no scenery are using it.
#
# The path for the object must be relative to the X-System base folder.  If
# the path is in the root of the X-System folder you may need to prepend ./
# to it; loading objects in the root of the X-System folder is STRONGLY
# discouraged - your plugin should not dump art resources in the root folder!
#
#
# XPLMLoadObject will return NULL if the object cannot be loaded (either
# because it is not found or the file is misformatted). This routine will
# load any object that can be used in the X-Plane scenery system.
#
# It is important that the datarefs an object uses for animation already be
# loaded before you load the object.  For this reason it may be necessary to
# defer object loading until the sim has fully started.
proc XPLMLoadObject*(inPath: cstring): XPLMObjectRef {.cdecl, importc: "XPLMLoadObject", dynlib: xplm_lib.}

# XPLMLoadObjectAsync loads an object asynchronously; control is returned to you
# immediately while X-Plane loads the object.  The sim will not stop flying
# while the object loads.  For large objects, it may be several seconds
# before the load finishes.
#
# You provide a callback function that is called once the load has completed.
# Note that if the object cannot be loaded, you will not find out until the
# callback function is called with a NULL object handle.
#
# There is no way to cancel an asynchronous object load; you must wait for
# the load to complete and then release the object if it is no longer
# desired.
proc XPLMLoadObjectAsync*(inPath: cstring,
                          inCallback: XPLMObjectLoaded_f,
                          inRefcon: pointer) {.cdecl, importc: "XPLMLoadObjectAsync", dynlib: xplm_lib.}

# XPLMDrawObjects draws an object from an OBJ file one or more times.  You
# pass in the object and an array of  XPLMDrawInfo_t structs, one for each
# place you would like the object to be drawn.
#
# X-Plane will attempt to cull the objects based on LOD and visibility, and
# will pick the appropriate LOD.
#
# Lighting is a boolean; pass 1 to show the night version of object with
# night-only lights lit up.  Pass 0 to show the daytime version of the
# object.
#
# earth_relative controls the coordinate system.  If this is 1, the rotations
# you specify are applied to the object after its coordinate system is
# transformed from local to earth-relative coordinates -- that is, an object
# with no rotations will point toward true north and the Y axis will be up
# against gravity.  If this is 0, the object is drawn with your rotations
# from local coordanates -- that is, an object with no rotations is drawn
# pointing down the -Z axis and the Y axis of the object matches the local
# coordinate Y axis.
proc XPLMDrawObjects*(inObject: XPLMObjectRef,
                      inCount: int,
                      inLocations: PXPLMDrawInfo_t,
                      lighting: int,
                      earth_relative: int) {.cdecl, importc: "XPLMDrawObjects", dynlib: xplm_lib.}

# XPLMUnloadObject marks an object as no longer being used by your plugin.
# Objects are reference counted: once no plugins are using an object, it is
# purged from memory.  Make sure to call XPLMUnloadObject once for each
# successful call to XPLMLoadObject.
proc XPLMUnloadObject*(inObject: XPLMObjectRef) {.cdecl, importc: "XPLMUnloadObject", dynlib: xplm_lib.}

#******************************************************************************
# Library Access
# *****************************************************************************
#
# The library access routines allow you to locate scenery objects via the
# X-Plane library system.  Right now library access is only provided for
# objects, allowing plugin-drawn objects to be extended using the library
# system.
#

# An XPLMLibraryEnumerator_f is a callback you provide that is called once
# for each library element that is located. The returned paths will be
# relative to the X-System folder.
type
     XPLMLibraryEnumerator_f* = proc (inFilePath: cstring, inRef: pointer) {.cdecl.}

# XPLMLookupObjects looks up a virtual path in the library system and returns
# all matching elements.  You provide a callback -  one virtual path may match
# many objects in the library.  XPLMLookupObjects returns the number of
# objects found.
#
# The latitude and longitude parameters specify the location the object will
# be used.  The library system allows for scenery packages to only provide
# objects to certain local locations.  Only objects that are allowed at the
# latitude/longitude you provide will be returned.
proc XPLMLookupObjects*(inPath: cstring,
                        inLatitude: float32,
                        inLongitude: float32,
                        enumerator: XPLMLibraryEnumerator_f,
                        rref: pointer): int {.cdecl, importc: "XPLMLookupObjects", dynlib: xplm_lib.}

