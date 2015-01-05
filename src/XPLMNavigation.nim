# See license.txt for usage.


# XPLMNavigation - THEORY OF OPERATION
#
# The XPLM Navigation APIs give you some access to the navigation databases
# inside X-Plane.  X-Plane stores all navigation information in RAM, so by
# using these APIs you can gain access to most information without having to
# go to disk or parse the files yourself.
#
# You can also use this API to program the FMS.  You must use the navigation
# APIs to find the nav-aids you want to program into the FMS, since the FMS
# is powered internally by x-plane's navigation database.
#

#******************************************************************************
# Navigation Database Access
# *****************************************************************************
#

# XPLMNavType
#
# These enumerations define the different types of navaids.  They are each
# defined with a separate bit so that they may be bit-wise added together to
# form sets of nav-aid types.
#
# NOTE: xplm_Nav_LatLon is a specific lat-lon coordinate entered into the
# FMS. It will not exist in the database, and cannot be programmed into the
# FMS. Querying the FMS for navaids will return it.  Use
# XPLMSetFMSEntryLatLon to set a lat/lon waypoint.
type
    XPLMNavType* = enum
      xplm_Nav_Unknown = 0
      xplm_Nav_Airport = 1
      xplm_Nav_NDB = 2
      xplm_Nav_VOR = 4
      xplm_Nav_ILS = 8
      xplm_Nav_Localizer = 16
      xplm_Nav_GlideSlope = 32
      xplm_Nav_OuterMarker = 64
      xplm_Nav_MiddleMarker = 128
      xplm_Nav_InnerMarker = 256
      xplm_Nav_Fix = 512
      xplm_Nav_DME = 1024
      xplm_Nav_LatLon = 2048

# XPLMNavRef is an iterator into the navigation database.  The navigation
# database is essentially an array, but it is not necessarily densely
# populated. The only assumption you can safely make is that like-typed
# nav-aids are  grouped together.
#
# Use XPLMNavRef to refer to a nav-aid.
#
# XPLM_NAV_NOT_FOUND is returned by functions that return an XPLMNavRef when
# the iterator must be invalid.
#
# typedef int XPLMNavRef;
#
type
    XPLMNavRef* = int

const
    XPLM_NAV_NOT_FOUND* = -1

# XPLMGetFirstNavAid returns the very first navaid in the database.  Use this
# to traverse the entire database.  Returns XPLM_NAV_NOT_FOUND if the nav
# database is empty.
proc XPLMGetFirstNavAid*(): XPLMNavRef {.cdecl, importc: "XPLMGetFirstNavAid", dynlib: xplm_lib.}

# XPLMGetNextNavAid this routine returns the next navaid.  It returns
# XPLM_NAV_NOT_FOUND if the nav aid passed in was invalid or if the navaid
# passed in was the last one in the database.  Use this routine to iterate
# across all like-typed navaids or the entire database.
#
# WARNING: due to a bug in the SDK, when fix loading is disabled in the
# rendering settings screen, calling this routine with the last airport
# returns a bogus nav aid.  Using this nav aid can crash x-plane.
proc XPLMGetNextNavAid*(inNavAidRef: XPLMNavRef): XPLMNavRef {.cdecl, importc: "XPLMGetNextNavAid", dynlib: xplm_lib.}

# XPLMFindFirstNavAidOfType returns the ref of the first navaid of the given
# type in the database or XPLM_NAV_NOT_FOUND if there are no navaids of that
# type in the database. You must pass exactly one nav aid type to this routine.
#
# WARNING: due to a bug in the SDK, when fix loading is disabled in the
# rendering settings screen, calling this routine with fixes returns a bogus
# nav aid.  Using this nav aid can crash x-plane.
proc XPLMFindFirstNavAidOfType*(inType: XPLMNavType): XPLMNavRef {.cdecl, importc: "XPLMFindFirstNavAidOfType", dynlib: xplm_lib.}

# XPLMFindLastNavAidOfType returns the ref of the last navaid of the given type
# in the database or XPLM_NAV_NOT_FOUND if there are no navaids of that type in the
# database.  You must pass exactly one nav aid type to this routine.
#
# WARNING: due to a bug in the SDK, when fix loading is disabled in the
# rendering settings screen, calling this routine with fixes returns a bogus
# nav aid.  Using this nav aid can crash x-plane.
proc XPLMFindLastNavAidOfType*(inType: XPLMNavType): XPLMNavRef {.cdecl, importc: "XPLMFindLastNavAidOfType", dynlib: xplm_lib.}

# XPLMFindNavAid provides a number of searching capabilities for the nav
# database. XPLMFindNavAid will search through every nav aid whose type is
# within inType (multiple types may be added together) and return any
# nav-aids found based  on the following rules:
#
# If inLat and inLon are not NULL, the navaid nearest to that lat/lon will be
# returned, otherwise the last navaid found will be returned.
#
# If inFrequency is not NULL, then any navaids considered must match this
# frequency.  Note that this will screen out radio beacons that do not have
# frequency data published (like inner markers) but not fixes and airports.
#
# If inNameFragment is not NULL, only navaids that contain the fragment in
# their name will be returned.
#
# If inIDFragment is not NULL, only navaids that contain the fragment in
# their IDs will be returned.
#
# This routine provides a simple way to do a number of useful searches:
#
# Find the nearest navaid on this frequency. Find the nearest airport. Find
# the VOR whose ID is "KBOS". Find the nearest airport whose name contains
# "Chicago".
proc XPLMFindNavAid*(inNameFragment: cstring,
                     inIDFragment: cstring,
                     inLat: ptr float32,
                     inLon: ptr float32,
                     inFrequency: ptr int,
                     inType: XPLMNavType): XPLMNavRef {.cdecl, importc: "XPLMFindNavAid", dynlib: xplm_lib.}

# XPLMGetNavAidInfo returns information about a navaid.  Any non-null field is
# filled out with information if it is available.
#
# Frequencies are in the nav.dat convention as described in the X-Plane nav
# database FAQ: NDB frequencies are exact, all others are multiplied by 100.
#
# The buffer for IDs should be at least 6 chars and the buffer for names
# should be at least 41 chars, but since these values are likely to go up, I
# recommend passing at least 32 chars for IDs and 256 chars for names when
# possible.
#
# The outReg parameter tells if the navaid is within the local "region" of
# loaded DSFs.  (This information may not be particularly useful to plugins.)
# The parameter is a single byte value 1 for true or 0 for false, not a C
# string.
proc XPLMGetNavAidInfo*(inRef: XPLMNavRef,
                        outType: ptr XPLMNavType,
                        outLatitude: ptr float32,
                        outLongitude: ptr float32,
                        outHeight: ptr float32,
                        outFrequency: ptr int,
                        outHeading: ptr float32,
                        outID: cstring,
                        outName: cstring,
                        outReg: cstring) {.cdecl, importc: "XPLMGetNavAidInfo", dynlib: xplm_lib.}


#******************************************************************************
# Flight Management Computer
# *****************************************************************************
#
# Note: the FMS works based on an array of entries.  Indices into the array
# are zero-based.  Each entry is a nav-aid plus an altitude.  The FMS tracks
# the currently displayed entry and the entry that it is flying to.
#
# The FMS must be programmed with contiguous entries, so clearing an entry at
# the end shortens the effective flight plan.  There is a max of 100
# waypoints in the flight plan.
#

# XPLMCountFMSEntries returns the number of entries in the FMS.
proc XPLMCountFMSEntries*(): int {.cdecl, importc: "XPLMCountFMSEntries", dynlib: xplm_lib.}


# XPLMGetDisplayedFMSEntry returns the index of the entry the pilot is viewing.
proc XPLMGetDisplayedFMSEntry*(): int {.cdecl, importc: "XPLMGetDisplayedFMSEntry", dynlib: xplm_lib.}

# XPLMGetDestinationFMSEntry returns the index of the entry the FMS is flying to.
proc XPLMGetDestinationFMSEntry*(): int {.cdecl, importc: "XPLMGetDestinationFMSEntry", dynlib: xplm_lib.}

# XPLMSetDisplayedFMSEntry changes which entry the FMS is showing to the index specified.
proc XPLMSetDisplayedFMSEntry*(inIndex: int) {.cdecl, importc: "XPLMSetDisplayedFMSEntry", dynlib: xplm_lib.}

# XPLMSetDestinationFMSEntry changes which entry the FMS is flying the aircraft toward.
proc XPLMSetDestinationFMSEntry*(inIndex: int) {.cdecl, importc: "XPLMSetDestinationFMSEntry", dynlib: xplm_lib.}

# XPLMGetFMSEntryInfo returns information about a given FMS entry.  A reference
# to a navaid can be returned allowing you to find additional information (such
# as a frequency, ILS heading, name, etc.).  Some information is available
# immediately.  For a lat/lon entry, the lat/lon is returned by this routine
# but the navaid cannot be looked up (and the reference will be
# XPLM_NAV_NOT_FOUND. FMS name entry buffers should be at least 256 chars in
# length.
proc XPLMGetFMSEntryInfo*(inIndex: int,
                          outType: ptr XPLMNavType,
                          outID: cstring,
                          outRef: ptr XPLMNavRef,
                          outAltitude: ptr int,
                          outLat: ptr float32,
                          outLon: ptr float32) {.cdecl, importc: "XPLMGetFMSEntryInfo", dynlib: xplm_lib.}

# XPLMSetFMSEntryInfo changes an entry in the FMS to have the destination navaid
# passed in and the altitude specified.  Use this only for airports, fixes,
# and radio-beacon navaids.  Currently of radio beacons, the FMS can only
# support VORs and NDBs. Use the routines below to clear or fly to a lat/lon.
proc XPLMSetFMSEntryInfo*(inIndex: int,
                          inRef: XPLMNavRef,
                          inAltitude: int) {.cdecl, importc: "XPLMSetFMSEntryInfo", dynlib: xplm_lib.}

# XPLMSetFMSEntryLatLon changes the entry in the FMS to a lat/lon entry with
# the given coordinates.
proc XPLMSetFMSEntryLatLon*(inIndex: int,
                            inLat: float32,
                            inLon: float32,
                            inAltitude: int) {.cdecl, importc: "XPLMSetFMSEntryLatLon", dynlib: xplm_lib.}

# XPLMClearFMSEntry clears the given entry, potentially shortening the flight
# plan.
proc XPLMClearFMSEntry*(inIndex: int) {.cdecl, importc: "XPLMClearFMSEntry", dynlib: xplm_lib.}


#******************************************************************************
# GPS Receiver
# *****************************************************************************
# These APIs let you read data from the GPS unit.
#

# XPLMGetGPSDestinationType returns the type of the currently selected GPS
# destination, one of fix, airport, VOR or NDB.
proc XPLMGetGPSDestinationType*(): XPLMNavType {.cdecl, importc: "XPLMGetGPSDestinationType", dynlib: xplm_lib.}

# XPLMGetGPSDestination returns the current GPS destination.
proc XPLMGetGPSDestination*(): XPLMNavRef {.cdecl, importc: "XPLMGetGPSDestination", dynlib: xplm_lib.}

