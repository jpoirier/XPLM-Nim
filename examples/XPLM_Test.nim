# See license.txt for usage.

{.deadCodeElim: on.}

import xplm

# Flightloop Callback Interval
const FL_CB_INTERVAL = -1.0

proc XFlightLoopCallback(inElapsedSinceLastCall: cfloat,
                         inElapsedTimeSinceLastFlightLoop: cfloat,
                         inCounter: cint,
                         inRefcon: pointer): cfloat {.exportc: "XFlightLoopCallback", dynlib.} =
    XPLMDebugString("-- RadioPanelFlightLoopCallback called...\n")
    # us: int, strongAdvice = false
    # proc GC_step*(100)
    return 1.0

proc XPluginStart(outName: ptr cstring, outSig: ptr cstring, outDesc: ptr cstring): cint {.exportc: "XPluginStart", dynlib.} =
    var name: cstring = "XPLM-Nim_Test"
    var sig: cstring = "xplm.nim.test"
    var desc: cstring = "XPLM-Nim Test Plugin"

    copyMem(outName, name, len(name)+1)
    copyMem(outSig, sig, len(sig)+1)
    copyMem(outDesc, desc, len(desc)+1)

    XPLMDebugString(cast[cstring]("-- XPluginStart called...\n"))

    # XPLMRegisterFlightLoopCallback(cast[XPLMFlightLoop_f](XFlightLoopCallback), cfloat(FL_CB_INTERVAL), pointer(nil))

    # MaxPauseInUs, what's a good value?
    # proc GC_setMaxPause*(100)
    return 1

proc XPluginStop() {.exportc: "XPluginStop", dynlib.} =
     XPLMDebugString(cast[cstring]("-- XPluginStop called...\n"))

proc XPluginDisable() {.exportc: "XPluginDisable", dynlib.} =
    XPLMDebugString(cast[cstring]("-- XPluginDisable called...\n"))

proc XPluginEnable(): cint {.exportc: "XPluginEnable", dynlib.} =
    XPLMDebugString(cast[cstring]("-- XPluginEnable called...\n"))
    return 1

proc XPluginReceiveMessage(inFrom: int, inMsg: int, inParam: pointer) {.exportc: "XPluginReceiveMessage", dynlib.} =
    XPLMDebugString(cast[cstring]("-- XPluginReceiveMessage called...\n"))

