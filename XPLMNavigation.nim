
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
#
# enum {
#      xplm_Nav_Unknown                         = 0
#     ,xplm_Nav_Airport                         = 1
#     ,xplm_Nav_NDB                             = 2
#     ,xplm_Nav_VOR                             = 4
#     ,xplm_Nav_ILS                             = 8
#     ,xplm_Nav_Localizer                       = 16
#     ,xplm_Nav_GlideSlope                      = 32
#     ,xplm_Nav_OuterMarker                     = 64
#     ,xplm_Nav_MiddleMarker                    = 128
#     ,xplm_Nav_InnerMarker                     = 256
#     ,xplm_Nav_Fix                             = 512
#     ,xplm_Nav_DME                             = 1024
#     ,xplm_Nav_LatLon                          = 2048
# };
#
const
    xplm_Nav_Unknown* = 0
    xplm_Nav_Airport* = 1
    xplm_Nav_NDB* = 2
    xplm_Nav_VOR* = 4
    xplm_Nav_ILS* = 8
    xplm_Nav_Localizer* = 16
    xplm_Nav_GlideSlope* = 32
    xplm_Nav_OuterMarker* = 64
    xplm_Nav_MiddleMarker* = 128
    xplm_Nav_InnerMarker* = 256
    xplm_Nav_Fix* = 512
    xplm_Nav_DME* = 1024
    xplm_Nav_LatLon* = 2048

# typedef int XPLMNavType;
type
    XPLMNavType: cint

# XPLMNavRef
#
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
type
    XPLMNavRef: cint

#define XPLM_NAV_NOT_FOUND   -1
const
    XPLM_NAV_NOT_FOUND* = -1

# XPLMGetFirstNavAid
#
# This returns the very first navaid in the database.  Use this to traverse
# the entire database.  Returns XPLM_NAV_NOT_FOUND if the nav database is
# empty.
#
# XPLM_API XPLMNavRef XPLMGetFirstNavAid(void);
proc XPLMGetFirstNavAid*(): XPLMNavRef {importc: "XPLMGetFirstNavAid", dynlib.}

# XPLMGetNextNavAid
#
# Given a nav aid ref, this routine returns the next navaid.  It returns
# XPLM_NAV_NOT_FOUND if the nav aid passed in was invalid or if the navaid
# passed in was the last one in the database.  Use this routine to iterate
# across all like-typed navaids or the entire database.
#
# WARNING: due to a bug in the SDK, when fix loading is disabled in the
# rendering settings screen, calling this routine with the last airport
# returns a bogus nav aid.  Using this nav aid can crash x-plane.
#
# XPLM_API XPLMNavRef XPLMGetNextNavAid(XPLMNavRef inNavAidRef);
proc XPLMGetNextNavAid*(inNavAidRef: XPLMNavRef): XPLMNavRef {importc: "XPLMGetNextNavAid", dynlib.}

# XPLMFindFirstNavAidOfType
#
# This routine returns the ref of the first navaid of the given type in the
# database or XPLM_NAV_NOT_FOUND if there are no navaids of that type in the
# database.  You must pass exactly one nav aid type to this routine.
#
# WARNING: due to a bug in the SDK, when fix loading is disabled in the
# rendering settings screen, calling this routine with fixes returns a bogus
# nav aid.  Using this nav aid can crash x-plane.
#
# XPLM_API XPLMNavRef XPLMFindFirstNavAidOfType(XPLMNavType inType);
proc XPLMFindFirstNavAidOfType*(inType: XPLMNavType): XPLMNavRef {importc: "XPLMFindFirstNavAidOfType", dynlib.}

# XPLMFindLastNavAidOfType
#
# This routine returns the ref of the last navaid of the given type in the
# database or XPLM_NAV_NOT_FOUND if there are no navaids of that type in the
# database.  You must pass exactly one nav aid type to this routine.
#
# WARNING: due to a bug in the SDK, when fix loading is disabled in the
# rendering settings screen, calling this routine with fixes returns a bogus
# nav aid.  Using this nav aid can crash x-plane.
#
# XPLM_API XPLMNavRef XPLMFindLastNavAidOfType(XPLMNavType inType);
proc XPLMFindLastNavAidOfType*(inType: XPLMNavType): XPLMNavRef {importc: "XPLMFindLastNavAidOfType", dynlib.}


# XPLMFindNavAid
#
# This routine provides a number of searching capabilities for the nav
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
#
# XPLM_API XPLMNavRef XPLMFindNavAid(const char* inNameFragment,
#                                    const char* inIDFragment,
#                                    float* inLat,
#                                    float* inLon,
#                                    int* inFrequency,
#                                    XPLMNavType inType);
proc XPLMFindNavAid*(inNameFragment: ptr cchar,
                     inIDFragment: ptr cchar,
                     inLat: ptr cfloat,
                     inLon: ptr cfloat,
                     inFrequency: ptr cint,
                     inType: cint): XPLMNavRef {importc: "XPLMFindNavAid", dynlib.}

# XPLMGetNavAidInfo
#
# This routine returns information about a navaid.  Any non-null field is
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
#
# XPLM_API void XPLMGetNavAidInfo(XPLMNavRef inRef,
#                                 XPLMNavType* outType,
#                                 float* outLatitude,
#                                 float* outLongitude,
#                                 float* outHeight,
#                                 int* outFrequency,
#                                 float* outHeading,
#                                 char* outID,
#                                 char* outName,
#                                 char* outReg);
proc XPLMGetNavAidInfo*(inRef: XPLMNavRef,
                        outType: ptr XPLMNavType,
                        outLatitude: ptr cfloat,
                        outLongitude: ptr cfloat,
                        outHeight: ptr cfloat,
                        outHeading: ptr cfloat,
                        outFrequency: ptr cint,
                        outID: ptr cchar,
                        outName: ptr cchar,
                        outReg: ptr cchar) {importc: "XPLMGetNavAidInfo", dynlib.}


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

# XPLMCountFMSEntries
#
# This routine returns the number of entries in the FMS.
#
# XPLM_API int XPLMCountFMSEntries(void);
proc XPLMCountFMSEntries*(): cint {importc: "XPLMCountFMSEntries", dynlib.}

# XPLMGetDisplayedFMSEntry
#
# This routine returns the index of the entry the pilot is viewing.
#
# XPLM_API int XPLMGetDisplayedFMSEntry(void);
proc XPLMGetDisplayedFMSEntry*(): cint {importc: "XPLMGetDisplayedFMSEntry", dynlib.}

#
# This routine returns the index of the entry the FMS is flying to.
#
# XPLM_API int XPLMGetDestinationFMSEntry(void);
proc XPLMGetDestinationFMSEntry*(): cint {importc: "XPLMGetDestinationFMSEntry", dynlib.}

# XPLMSetDisplayedFMSEntry
#
# This routine changes which entry the FMS is showing to the index specified.
#
# XPLM_API void XPLMSetDisplayedFMSEntry(int inIndex);
proc XPLMSetDisplayedFMSEntry*(inIndex: cint) {importc: "XPLMSetDisplayedFMSEntry", dynlib.}

# XPLMSetDestinationFMSEntry
#
# This routine changes which entry the FMS is flying the aircraft toward.
#
# XPLM_API void XPLMSetDestinationFMSEntry(int inIndex);
proc XPLMSetDestinationFMSEntry*(inIndex: cint) {importc: "XPLMSetDestinationFMSEntry", dynlib.}

# XPLMGetFMSEntryInfo
#
# This routine returns information about a given FMS entry.  A reference to a
# navaid can be returned allowing you to find additional information (such as
# a frequency, ILS heading, name, etc.).  Some information is available
# immediately.  For a lat/lon entry, the lat/lon is returned by this routine
# but the navaid cannot be looked up (and the reference will be
# XPLM_NAV_NOT_FOUND. FMS name entry buffers should be at least 256 chars in
# length.
#
# XPLM_API void XPLMGetFMSEntryInfo(int inIndex, XPLMNavType* outType, char* outID, XPLMNavRef* outRef, int* outAltitude, float* outLat, float* outLon);
proc XPLMGetFMSEntryInfo*(inIndex: cint,
                          outType: ptr cint,
                          outRef: ptr cint,
                          outAltitude: ptr cint,
                          outID: ptr cchar,
                          outLat: ptr cchar,
                          outLon: ptr cflout) {importc: "XPLMGetFMSEntryInfo", dynlib.}

# XPLMSetFMSEntryInfo
#
# This routine changes an entry in the FMS to have the destination navaid
# passed in and the altitude specified.  Use this only for airports, fixes,
# and radio-beacon navaids.  Currently of radio beacons, the FMS can only
# support VORs and NDBs. Use the routines below to clear or fly to a lat/lon.
#
# XPLM_API void XPLMSetFMSEntryInfo(int inIndex, XPLMNavRef inRef, int inAltitude);
proc XPLMSetFMSEntryInfo*(inIndex: cint, inRef: XPLMNavRef, inAltitude: cint) {importc: "XPLMSetFMSEntryInfo", dynlib.}

# XPLMSetFMSEntryLatLon
#
# This routine changes the entry in the FMS to a lat/lon entry with the given
# coordinates.
#
# XPLM_API void XPLMSetFMSEntryLatLon(int inIndex, float inLat, float inLon, int inAltitude);
proc XPLMSetFMSEntryLatLon*(inIndex: cint, inLat: cfloat, inLon: cfloat, inAltitude: cint) {importc: "XPLMSetFMSEntryLatLon", dynlib.}

# XPLMClearFMSEntry
#
# This routine clears the given entry, potentially shortening the flight
# plan.
#
# XPLM_API void XPLMClearFMSEntry(int inIndex);
proc XPLMClearFMSEntry*(inIndex: cint) {importc: "XPLMClearFMSEntry", dynlib.}


#******************************************************************************
# GPS Receiver
# *****************************************************************************
# These APIs let you read data from the GPS unit.
#

# XPLMGetGPSDestinationType
#
# This routine returns the type of the currently selected GPS destination,
# one of fix, airport, VOR or NDB.
#
# XPLM_API XPLMNavType XPLMGetGPSDestinationType(void);
proc XPLMGetGPSDestinationType*(): cint {importc: "XPLMGetGPSDestinationType", dynlib.}

# XPLMGetGPSDestination
#
# This routine returns the current GPS destination.
#
# XPLM_API XPLMNavRef XPLMGetGPSDestination(void);
proc XPLMGetGPSDestination*(): XPLMNavRef {importc: "XPLMGetGPSDestination", dynlib.}

