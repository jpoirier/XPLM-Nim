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
import lib/XPLMUtilities

import lib/XPWidgetUtils
import lib/XPWidgets
import lib/XPWidgetDefs
import lib/XPUIGraphics
import lib/XPStandardWidgets


type
  XPLMFlightLoop_CB* = proc (inElapsedSinceLastCall: cfloat,
                             inElapsedTimeSinceLastFlightLoop: cfloat,
                             inCounter: cint, inRefcon: pointer): cfloat
                                                                    {.stdcall.}

## ----------------------------------------------------------------------------
# imports
proc XPLMRegisterFlightLoopCallback(callback: XPLMFlightLoop_CB,
                                    inInterval: cfloat,
                                    inRefcon: pointer)
         {.stdcall, importc: "XPLMRegisterFlightLoopCallback", dynlib: LibName}

proc XPLMDebugString(inString: cstring)
                        {.stdcall, importc: "XPLMDebugString", dynlib: LibName}


# // Flightloop Callback INterval
# static const float FL_CB_INTERVAL = -1.0;

## ----------------------------------------------------------------------------
proc XFlightLoopCallback(inElapsedSinceLastCall: cfloat,
                         inElapsedTimeSinceLastFlightLoop: cfloat,
                         inCounter: cint,
                         inRefcon: pointer): cfloat
                                  {.exportc: "XFlightLoopCallback", dynlib.} =

    XPLMDebugString("-- RadioPanelFlightLoopCallback called...\n")

    # us: int, strongAdvice = false
    # proc GC_step*(100)

    return 1.0

## ----------------------------------------------------------------------------
proc XPluginStart(outName: ptr cstring,
                  outSig: ptr cstring,
                  outDesc: ptr cstring): cint
                                          {.exportc: "XPluginStart", dynlib.} =

    outName[] = "XPLM-Nim_Test"
    outSig[] = "xplm.nim.test"
    outDesc[] = "XPLM-Nim Test Plugin"
    XPLMDebugString("-- XPluginStart called...\n")
    XPLMDebugString("-- err XPluginStart called...\n")

    XPLMRegisterFlightLoopCallback(cast[XPLMFlightLoop_CB](XFlightLoopCallback),
                                    cfloat(-1.0),
                                    pointer(nil))

    # MaxPauseInUs, what's a good value?
    # proc GC_setMaxPause*(100)

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
proc XPluginReceiveMessage(inFrom: int,
                           inMsg: int,
                           inParam: pointer)
                                {.exportc: "XPluginReceiveMessage", dynlib.} =

    XPLMDebugString("-- XPluginReceiveMessage called...\n")

