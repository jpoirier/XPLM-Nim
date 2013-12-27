


## Navigation Database Access
## ----------------------------------------------------------------------------
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
# typedef int XPLMNavType;

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

# typedef int XPLMNavRef;

const
    #define XPLM_NAV_NOT_FOUND   -1
    XPLM_NAV_NOT_FOUND* = -1


# XPLM_API XPLMNavRef XPLMGetFirstNavAid(void);
proc XPLMGetFirstNavAid*(): cint {importc: "XPLMGetFirstNavAid", nodecl.}

# XPLM_API XPLMNavRef XPLMGetNextNavAid(XPLMNavRef inNavAidRef);
proc XPLMGetNextNavAid*(inNavAidRef: cint): cint {importc: "XPLMGetNextNavAid", nodecl.}

# XPLM_API XPLMNavRef XPLMFindFirstNavAidOfType(XPLMNavType inType);
proc XPLMFindFirstNavAidOfType*(inType: cint): cint {importc: "XPLMFindFirstNavAidOfType", nodecl.}

# XPLM_API XPLMNavRef XPLMFindLastNavAidOfType(XPLMNavType inType);
proc XPLMFindLastNavAidOfType*(inType: cint): cint {importc: "XPLMFindLastNavAidOfType", nodecl.}


# XPLM_API XPLMNavRef XPLMFindNavAid(const char* inNameFragment, const char* inIDFragment, float* inLat,
#                                   float* inLon, int* inFrequency, XPLMNavType inType);
proc XPLMFindNavAid*(inNameFragment, inIDFragment: ptr cchar, inLat, inLon: ptr cfloat, inFrequency: ptr cint, inType: cint)
                    {importc: "XPLMFindNavAid", nodecl.}


# XPLM_API void XPLMGetNavAidInfo(XPLMNavRef inRef, XPLMNavType* outType, float* outLatitude,
#                                   float* outLongitude, float* outHeight, int* outFrequency,
#                                   float* outHeading, char* outID,  char* outName,  char* outReg);
proc XPLMGetNavAidInfo*(inRef: cint, outType: ptr cint, outLatitude, outLongitude, outHeight, outHeading: ptr cfloat,
                       outFrequency: ptr cint, outID, outName, outReg: ptr cchar) {importc: "XPLMGetNavAidInfo", nodecl.}


## Flight Management Computer
## ----------------------------------------------------------------------------
# XPLM_API int XPLMCountFMSEntries(void);
proc XPLMCountFMSEntries*(): cint {importc: "XPLMCountFMSEntries", nodecl.}

# XPLM_API int XPLMGetDisplayedFMSEntry(void);
proc XPLMGetDisplayedFMSEntry*(): cint {importc: "XPLMGetDisplayedFMSEntry", nodecl.}

# XPLM_API int XPLMGetDestinationFMSEntry(void);
proc XPLMGetDestinationFMSEntry*(): cint {importc: "XPLMGetDestinationFMSEntry", nodecl.}

# XPLM_API void XPLMSetDisplayedFMSEntry(int inIndex);
proc XPLMSetDisplayedFMSEntry*(inIndex: cint) {importc: "XPLMSetDisplayedFMSEntry", nodecl.}

# XPLM_API void XPLMSetDestinationFMSEntry(int inIndex);
proc XPLMSetDestinationFMSEntry*(inIndex: cint) {importc: "XPLMSetDestinationFMSEntry", nodecl.}

# XPLM_API void XPLMGetFMSEntryInfo(int inIndex, XPLMNavType* outType, char* outID, XPLMNavRef* outRef, int* outAltitude, float* outLat, float* outLon);
proc XPLMGetFMSEntryInfo*(inIndex: cint, outType, outRef, outAltitude: ptr cint, outID: ptr cchar, outLat, outLon: ptr cflout) {importc: "XPLMGetFMSEntryInfo", nodecl.}

# XPLM_API void XPLMSetFMSEntryInfo(int inIndex, XPLMNavRef inRef, int inAltitude);
proc XPLMSetFMSEntryInfo*(inIndex, inRef, inAltitude: cint) {importc: "XPLMSetFMSEntryInfo", nodecl.}

# XPLM_API void XPLMSetFMSEntryLatLon(int inIndex, float inLat, float inLon, int inAltitude);
proc XPLMSetFMSEntryLatLon*(inIndex, inAltitude: cint, inLat, inLon: cfloat) {importc: "XPLMSetFMSEntryLatLon", nodecl.}

# XPLM_API void XPLMClearFMSEntry(int inIndex);
proc XPLMClearFMSEntry*(inIndex: cint) {importc: "XPLMClearFMSEntry", nodecl.}


## GPS Receiver
## ----------------------------------------------------------------------------
# XPLM_API XPLMNavType XPLMGetGPSDestinationType(void);
proc XPLMGetGPSDestinationType*(): cint {importc: "XPLMGetGPSDestinationType", nodecl.}

# XPLM_API XPLMNavRef XPLMGetGPSDestination(void);
proc XPLMGetGPSDestination*(): cint {importc: "XPLMGetGPSDestination", nodecl.}

