#import XPLMDefs
#import XPLMProcessing

{.deadCodeElim: on.}

when defined(windows):
    const LibName = "XPLM_64.dll"
elif defined(macosx):
    const LibName = "XPLM_64.dylib"
else:
    const LibName = "XPLM_64.so"

type
  XPLMFlightLoop_CB* = proc (inElapsedSinceLastCall: cfloat, inElapsedTimeSinceLastFlightLoop: cfloat, inCounter: cint, inRefcon: pointer): cfloat {.stdcall.}

# .stdcall.
proc XPLMRegisterFlightLoopCallback(callback: XPLMFlightLoop_CB, inInterval: cfloat, inRefcon: pointer) {.stdcall, importc: "XPLMRegisterFlightLoopCallback", dynlib: LibName}
proc XPLMDebugString(inString: cstring)  {.stdcall, importc: "XPLMDebugString", dynlib: LibName}


# // Flightloop Callback INterval
# static const float FL_CB_INTERVAL = -1.0;

## ----------------------------------------------------------------------------
proc XFlightLoopCallback(inElapsedSinceLastCall: cfloat, inElapsedTimeSinceLastFlightLoop: cfloat, inCounter: cint, inRefcon: pointer): cfloat {.exportc: "XFlightLoopCallback", dynlib.} =

  XPLMDebugString("-- RadioPanelFlightLoopCallback called...\n")

  return 1.0

## ----------------------------------------------------------------------------
proc XPluginStart(outName: ptr cchar, outSig: ptr cchar, outDesc: ptr cchar): cint {.exportc: "XPluginStart", dynlib.} =

  #outName = "TestTest\0"
  #outSig = "TestTest\0"
  #outDesc = "TestTest\0"
  XPLMDebugString("-- XPluginStart called...\n")
  XPLMDebugString("-- err XPluginStart called...\n")

  XPLMRegisterFlightLoopCallback(cast[XPLMFlightLoop_CB](XFlightLoopCallback), cfloat(-1.0), pointer(nil))

  return 1

## ----------------------------------------------------------------------------
proc XPluginStop() {.exportc: "XPluginStop", dynlib.} =

  XPLMDebugString("-- XPluginStop called...\n")

## ----------------------------------------------------------------------------
proc XPluginDisable() {.exportc: "XPluginDisable", dynlib.} =

  XPLMDebugString("-- XPluginDisable called...\n")

## ----------------------------------------------------------------------------
proc XPluginEnable(): cint {.exportc: "XPluginEnable", dynlib.} =

  XPLMDebugString("-- XPluginEnable called...\n")

  return 1

## ----------------------------------------------------------------------------
proc XPluginReceiveMessage(inFrom: int, inMsg: int, inParam: pointer) {.exportc: "XPluginReceiveMessage", dynlib.} =

   XPLMDebugString("-- XPluginReceiveMessage called...\n")

