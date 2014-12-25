# See license.txt for usage.

{.deadCodeElim: on.}

import lib/XPLMDefs
import lib/XPLMCamera
import lib/XPLMDataAccess
import lib/XPLMDisplay
import lib/XPLMGraphics
import lib/XPLMMenus
import lib/XPLMNavigation
import lib/XPLMPlanes
import lib/XPLMPlugin
import lib/XPLMProcessing
import lib/XPLMScenery
import lib/XPLMUtilities as util

import lib/XPWidgetUtils
import lib/XPWidgets
import lib/XPWidgetDefs
import lib/XPUIGraphics
import lib/XPStandardWidgets

# Flightloop Callback Interval
const FL_CB_INTERVAL = -1.0

## ----------------------------------------------------------------------------
proc XFlightLoopCallback(inElapsedSinceLastCall: cfloat,
                         inElapsedTimeSinceLastFlightLoop: cfloat,
                         inCounter: cint,
                         inRefcon: pointer): cfloat {.exportc: "XFlightLoopCallback", dynlib.} =
    util.XPLMDebugString("-- RadioPanelFlightLoopCallback called...\n")
    # us: int, strongAdvice = false
    # proc GC_step*(100)
    return 1.0

## ----------------------------------------------------------------------------
proc XPluginStart(outName: ptr cstring, outSig: ptr cstring, outDesc: ptr cstring): cint {.exportc: "XPluginStart", dynlib.} =
    outName[] = "XPLM-Nim_Test"
    outSig[] = "xplm.nim.test"
    outDesc[] = "XPLM-Nim Test Plugin"
    util.XPLMDebugString("-- XPluginStart called...\n")
    util.XPLMDebugString("-- XPluginStart called...\n")

    XPLMRegisterFlightLoopCallback(cast[XPLMFlightLoop_f](XFlightLoopCallback), cfloat(FL_CB_INTERVAL), pointer(nil))

    # MaxPauseInUs, what's a good value?
    # proc GC_setMaxPause*(100)
    return 1

## ----------------------------------------------------------------------------
proc XPluginStop() {.exportc: "XPluginStop", dynlib.} =
    util.XPLMDebugString("-- XPluginStop called...\n")

## ----------------------------------------------------------------------------
proc XPluginDisable() {.exportc: "XPluginDisable", dynlib.} =
    util.XPLMDebugString("-- XPluginDisable called...\n")

## ----------------------------------------------------------------------------
proc XPluginEnable(): cint {.exportc: "XPluginEnable", dynlib.} =
    util.XPLMDebugString("-- XPluginEnable called...\n")
    return 1

## ----------------------------------------------------------------------------
proc XPluginReceiveMessage(inFrom: int, inMsg: int, inParam: pointer) {.exportc: "XPluginReceiveMessage", dynlib.} =
    util.XPLMDebugString("-- XPluginReceiveMessage called...\n")

